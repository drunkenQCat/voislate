import 'dart:async';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_android_volume_keydown/flutter_android_volume_keydown.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:voislate/models/slate_log_item.dart';
import 'package:voislate/models/slate_schedule.dart';
import 'package:voislate/providers/slate_log_notifier.dart';
import 'package:voislate/widgets/scene_schedule_page/note_editor.dart';

import '../models/recorder_file_num.dart';
import '../providers/slate_picker_notifier.dart';
import '../providers/slate_status_notifier.dart';
import '../providers/value_scroll_control.dart';
import '../widgets/record_page/file_counter.dart';
import '../widgets/record_page/prev_note_editor.dart';
import '../widgets/record_page/quick_view_log_dialog.dart';
import '../widgets/record_page/recorder_joystick.dart';
import '../widgets/record_page/shot_ok_dial.dart';
import '../widgets/record_page/slate_picker.dart';
import '../widgets/record_page/take_ok_dial.dart';

/* 
TODO:
1x 轮盘绑定拍摄计划
2x 调整UI布局，删除一些输入框
3x 删除场镜相关悬浮按钮（本来就是用来验证功能的）
4x 调整轮盘高度
5x 考虑特殊录音（补录对白、补录环境音）
6x 跑条按钮
7x 想办法让文件名可以长按修改
~~8. "准备录音"不要那么高~~
9x "本场内容"注意schedule的数据结构
10. (备选方案)可以考虑加入急行军模式
11x *记得修改按键布局保证交互操作可以正常使用.某种意义上说，就是要足够的大
12x 增加振动交互
13x *修一下减了之后再加的问题
14x 把加减号改成方形的
15x *把currentScn改成prevScene
16x 保存配置的功能
17x *****场景次与文件名的逻辑
18. 思考音量键/录音信号绑定情况下跑条的设置
19. 修复Prefix相关问题
*/
class SlateRecord extends StatefulWidget {
  const SlateRecord({super.key});

  @override
  State<SlateRecord> createState() => _SlateRecordState();
}

enum TakeType { normal, fake, end, wild }

class _SlateRecordState extends State<SlateRecord> with WidgetsBindingObserver {
  // Some variables don't need to be in the state

  late List<SceneSchedule> totalScenes;
  // the indicator of wildtrack
  late bool isLinked;
  final int _counterInit = 1;
  // about the logs
  late TextEditingController shotNoteController;
  late TextEditingController descController;
  // about the slate picker
  var titles = ['Scene', 'Shot', 'Take'];
  final sceneCol = SlateColumnOne();
  final shotCol = SlateColumnTwo();
  final takeCol = SlateColumnThree();
  final num = RecordFileNum();
  // controller for volume key
  late ScrollValueController<SlateColumnThree> scrl3;
  // final TextEditingController descEditingController = TextEditingController();
  bool _isAbsorbing = false;

  // 手动跑一条录音
  // drawback the last note, and decrease the file number,but not the take number
  // vibration feedback related
  bool _canVibrate = true;

  /// 0: not checked, 1: ok, 2: not ok
  var okTk = TkStatus.notChecked;
  var okSht = ShtStatus.notChecked;

  bool shotChanged = false;

  StreamSubscription<HardwareButton>? subscription;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var horizonPadding = 30.0;
    var pickerHistory = Hive.box('picker_history');
    // everytime setState, the build method will be called again

    return Consumer2<SlateStatusNotifier, SlateLogNotifier>(
        builder: (context, slateNotifier, logNotifier, child) {
      /// Subscribe the notes on this page
      descController
          .addListener(() => slateNotifier.setNote(desc: descController.text));
      shotNoteController.addListener(
          () => slateNotifier.setNote(note: shotNoteController.text));

      /// The IconButtons on bottom area to pending last take
      var takeOkDial = TakeOkDial(
        context: context,
        tkStatus: okTk,
      );
      var shotOkDial = ShotOkDial(
        context: context,
        shtStatus: okSht,
      );
      void resetOkEnum() {
        setState(() {
          okTk = TkStatus.notChecked;
          okSht = ShtStatus.notChecked;
        });
        slateNotifier.setOkStatus(doReset: true);
      }

      String getCurrentTakeKeyWord(TakeType type) {
        if (type == TakeType.end) return 'OK';
        if (type == TakeType.normal) return takeCol.selected;
        if (type == TakeType.fake) return 'F';
        if (type == TakeType.wild) return 'W';
        return 'F';
      }

      /// The desc/note editor area
      List<String> getPrevTakeInfo() {
        if (pickerHistory.isEmpty) return [];
        var prevTake = pickerHistory.getAt(pickerHistory.length - 1);
        List<String> prevTakeList = prevTake.cast<String>();
        return prevTakeList;
      }

      String getPrevScn() => getPrevTakeInfo()[0];
      String getPrevSht() => getPrevTakeInfo()[1];
      String getPrevTk() => getPrevTakeInfo()[2];
      List<String> getPrevObjs() =>
          getPrevTakeInfo().length > 3 ? getPrevTakeInfo().sublist(3) : [];

      var prevTakeEditor = PrevTakeEditor(
        num: num,
        descEditingController: descController,
      );
      var prevShotNote = PrevShotNote(
        currentScn: pickerHistory.isNotEmpty ? getPrevScn() : '0',
        currentSht: pickerHistory.isNotEmpty ? getPrevSht() : '0',
        currentTk: pickerHistory.isNotEmpty ? getPrevTk() : '0',
        controller: shotNoteController,
      );

      void addNewLog([TakeType currentTkType = TakeType.normal]) {
        var prevTakeInfo = getPrevTakeInfo();
        String prevScn = prevTakeInfo.isNotEmpty ? getPrevScn() : '0';
        String prevSht = prevTakeInfo.isNotEmpty ? getPrevSht() : '0';
        String prevTkSign = prevTakeInfo.isNotEmpty ? getPrevTk() : '0';
        if (prevTkSign == 'OK') return;
        var isFake = prevTkSign == 'F';
        var isWild = prevTkSign == 'W';
        // obj list is the rest part of prevTake
        String trackLogs = getPrevObjs().map((obj) => "<$obj/>").join();
        // check if the shot is changed or if current take is the end take
        if (shotCol.selected != prevSht || currentTkType == TakeType.end) {
          // if shotCol changed, the status of current take
          // automatically turn to best
          takeOkDial.tkStatus = TkStatus.ok;
          shotOkDial.shtStatus = ShtStatus.nice;
        }
        var newLogItem = SlateLogItem(
          scn: prevScn,
          sht: prevSht,
          tk: isFake
              ? 999
              : isWild
                  ? 0
                  : int.parse(prevTkSign),
          filenamePrefix: num.prefix,
          filenameLinker: num.intervalSymbol,
          filenameNum: num.prevFileNum(),
          tkNote: !isFake
              ? (descController.text.isEmpty
                  ? 'S$prevScn Sh$prevSht Tk$prevTkSign'
                  : descController.text)
              : 'Fake Take',
          shtNote: "${shotNoteController.text}$trackLogs",
          scnNote: totalScenes[sceneCol.selectedIndex].info.note.append,
          currentOkTk: !isFake ? takeOkDial.tkStatus : TkStatus.bad,
          currentOkSht: !isFake ? shotOkDial.shtStatus : ShtStatus.notChecked,
        );

        if (isWild) {
          newLogItem.tkNote = "wild track ${newLogItem.tkNote}";
        }
        logNotifier.add(num.prevFileName(), newLogItem);
      }

      void setDescNewText(TakeType currentTkType) {
        currentTkType == TakeType.fake
            ? descController.text = "跑条"
            : currentTkType == TakeType.end
                ? descController.text = "收工了,这一镜结束了"
                : descController.clear();
      }

      void addItem([TakeType currentTkType = TakeType.normal]) {
        if (num.prevFileName().isNotEmpty) {
          addNewLog(currentTkType);
        }
        if (!isLinked && currentTkType != TakeType.end) {
          currentTkType = TakeType.wild;
        }
        List currentTakeInfo = [
          sceneCol.selected,
          shotCol.selected,
          getCurrentTakeKeyWord(currentTkType)
        ];
        var objList = totalScenes[sceneCol.selectedIndex][shotCol.selectedIndex]
            .note
            .objects;
        currentTakeInfo.addAll(objList);
        pickerHistory.add(currentTakeInfo);
        setState(() {
          if (currentTkType != TakeType.end) num.increment();
          resetOkEnum();
          slateNotifier.setIndex(count: num.number);
          setDescNewText(currentTkType);
        });
        if (_canVibrate) {
          currentTkType == TakeType.fake
              ? Vibrate.feedback(FeedbackType.error)
              : Vibrate.feedback(FeedbackType.heavy);
        }
      }

      ElevatedButton col3IncBtn = ElevatedButton(
          onPressed: () {
            addItem();
            takeCol.scrollToNext(isLinked);
          },
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(56, 58),
              foregroundColor: Colors.white,
              backgroundColor: Colors.purple.shade900),
          child: const Icon(
            Icons.add,
          ));

      Future<void> removeLastPickerHistory() =>
          pickerHistory.deleteAt(pickerHistory.length - 1);
      void drawBackNotes() {
        descController.text = logNotifier.logToday.last.tkNote;
        var lastShtNote = logNotifier.logToday.last.shtNote.split('<').first;
        shotNoteController.text = lastShtNote;
      }

      void drawBackItem() {
        if (getPrevTk() == "OK") {
          setState(() => drawBackNotes());
          removeLastPickerHistory();
          return;
        }
        try {
          setState(() {
            num.decrement();
          });
          slateNotifier.setIndex(count: num.number);
          setState(() => drawBackNotes());
          removeLastPickerHistory();
          logNotifier.removeLast();
          // ignore: empty_catches
        } catch (e) {}
        // remove the last note
        if (_canVibrate) {
          Vibrate.feedback(FeedbackType.warning);
        }
      }

      ElevatedButton col3DecBtn = ElevatedButton(
        onPressed: () {},
        onLongPress: () {
          if (getPrevTk() != "OK") {
            takeCol.scrollToPrev(isLinked);
          }
          drawBackItem();
        },
        style: ElevatedButton.styleFrom(
          maximumSize: const Size(87, 50),
          foregroundColor: Colors.red,
        ),
        child: const Icon(Icons.remove),
      );

      /// The function of volumekey
      scrl3 = ScrollValueController<SlateColumnThree>(
        context: context,
        textCon: descController,
        inc: () => addItem(),
        dec: () => drawBackItem(),
        col: takeCol,
      );

      ElevatedButton shotEndBtn = ElevatedButton(
        onPressed: () {
          List<String> prevTake = getPrevTakeInfo();
          if (num.prevFileName().isEmpty ||
              prevTake.isEmpty ||
              prevTake[2] == 'OK' ||
              prevTake[2] == 'F') return;
          addItem(TakeType.end);
        },
        style: ElevatedButton.styleFrom(
          // minimumSize: const Size(87, 50),
          maximumSize: const Size(87, 50),
          foregroundColor: Colors.green,
        ),
        // child: const Image(image: AssetImage('lib/assets/bookmark.png')),
        child: const Icon(Icons.save),
      );

      void pickerNumSync() {
        setState(() {
          var shotList = totalScenes[sceneCol.selectedIndex]
              .data
              .map((e) => e.name.toString())
              .toList();
          // if the scene is changed manually
          if (sceneCol.selectedIndex != slateNotifier.selectedSceneIndex) {
            shotCol.init(0, shotList);
            takeCol.init();
            shotChanged = true;
          }
          // if the shot is changed manually
          if (shotCol.selectedIndex != slateNotifier.selectedShotIndex) {
            takeCol.init();
            shotChanged = true;
          }
          if (shotCol.selectedIndex == slateNotifier.selectedShotIndex) {
            shotChanged = false;
          }
          slateNotifier.setIndex(
            scene: sceneCol.selectedIndex,
            shot: shotCol.selectedIndex,
            take: takeCol.selectedIndex,
          );
        });
      }

      List<MapEntry<String, String>> exportQuickNotes() {
        var logs = logNotifier.logToday;
        var notes = logs.map((log) {
          return MapEntry(log.fileName, log.tkNote);
        }).toList();
        if (notes.length > 40) return notes.sublist(40);
        return notes;
      }

      const nextTakeTrailer = ListTile(
        visualDensity: VisualDensity(vertical: -4),
        leading: Icon(
          Icons.fast_forward_outlined,
          color: Colors.blue,
        ),
        title: Text('下一条:'),
      );
      var nextPicker = Column(
        children: [
          Text((shotChanged) ? "长按修改当前镜" : ""),
          SlatePicker(
            titles: titles,
            stateOne: sceneCol,
            stateTwo: shotCol,
            stateThree: takeCol,
            width: screenWidth - 2 * horizonPadding,
            height: screenHeight * 0.17,
            itemHeight: screenHeight * 0.13 - 48,
            resultChanged: ({v1, v2, v3}) {
              if (v3.toString() == "2") {
                shotNoteController.text = totalScenes[sceneCol.selectedIndex]
                        [shotCol.selectedIndex]
                    .note
                    .append;
              }
              pickerNumSync();
              debugPrint('v1: , v2: , v3: ');
            },
          ),
        ],
      );
      var nextTakeScrolls = GestureDetector(
        onTap: () {},
        onLongPress: () {
          editCurrentShot(context);
        },
        child: Card(elevation: 3, child: nextPicker),
      );
      var scrollCounterLinkButton = Transform.rotate(
        angle: 1.5708,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isLinked = !isLinked;
              slateNotifier.setLink(isLinked);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isLinked ? Colors.white60 : Colors.grey,
            elevation: 5,
          ),
          child: Icon(isLinked ? Icons.link : Icons.link_off),
        ),
      );
      Widget nextTakeMonitor = Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Card(
            color: Colors.grey.shade100,
            child: Column(
              children: [
                nextTakeTrailer,
                nextTakeScrolls,
                // add an input box to have a note about the number
                const SizedBox(
                  height: 10,
                ),
                FileCounter(
                  init: _counterInit,
                  num: num,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 131.0),
            child: scrollCounterLinkButton,
          ),
        ],
      );

      return Scaffold(
        body: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                // because of the Title of scaffold,
                // the width of the card is 80% of the screen height
                height: screenHeight * 0.85,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    AbsorbPointer(
                        absorbing: _isAbsorbing, child: nextTakeMonitor),
                    Stack(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: AbsorbPointer(
                                    absorbing: _isAbsorbing, child: col3IncBtn))
                          ],
                        ),
                        // A button to add Fake Take
                        AbsorbPointer(
                          absorbing: _isAbsorbing,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: IconButton(
                              onPressed: () {
                                addItem(TakeType.fake);
                              },
                              icon: const Icon(Icons.redo),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        AbsorbPointer(
                          absorbing: _isAbsorbing,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              prevTakeEditor,
                              prevShotNote,
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: RecorderJoystick(
                            width: 120,
                            sliderButtonContent: const Icon(Icons.mic),
                            backgroundColor: Colors.red.shade200,
                            backgroundColorEnd: Colors.green.shade200,
                            foregroundColor: Colors.purple.shade50,
                            onLeftEdge: () {},
                            onRightEdge: () {},
                            leftTextController: descController,
                            rightTextController: shotNoteController,
                          ),
                        ),
                      ],
                    ),
                    AbsorbPointer(
                      absorbing: _isAbsorbing,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          col3DecBtn,
                          // Complish Button
                          shotEndBtn
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DisplayNotesButton(
                          notes: exportQuickNotes(),
                          num: num,
                        ),
                        takeOkDial,
                        shotOkDial,
                        AnimatedToggleSwitch.dual(
                          dif: 5,
                          current: _isAbsorbing,
                          first: false,
                          second: true,
                          onChanged: (value) {
                            setState(() => _isAbsorbing = value);
                          },
                          colorBuilder: (bool isLocked) =>
                              !isLocked ? Colors.green : Colors.red,
                          iconBuilder: (bool isLocked) =>
                              Icon(!isLocked ? Icons.lock_open : Icons.lock),
                          textBuilder: (bool isLocked) =>
                              Text(!isLocked ? '触控' : '锁定'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void editCurrentShot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return NoteEditor(
            context: context,
            scenes: totalScenes,
            scnIndex: sceneCol.selectedIndex,
            shotIndex: shotCol.selectedIndex,
            isRecordPage: true);
      },
    ).then((value) {
      var shotList = totalScenes[sceneCol.selectedIndex]
          .data
          .map((e) => e.name.toString())
          .toList();
      setState(() => shotCol.init(shotCol.selectedIndex, shotList));
      Hive.box('scenes_box')
          .putAt(sceneCol.selectedIndex, totalScenes[sceneCol.selectedIndex]);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    stopListening();
    var linkTest = Hive.box('scn_sht_tk').get('oktk') as TkStatus;
    debugPrint(linkTest.toString());
    var linkTest2 = Hive.box('scn_sht_tk').get('oksht') as ShtStatus;
    debugPrint(linkTest2.toString());
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _initVibrate();
    startListening();
    var box = Hive.box('scenes_box');
    totalScenes = box.values.toList().cast();

    var initValueProvider =
        Provider.of<SlateStatusNotifier>(context, listen: false);
    var sceneList = totalScenes.map((e) => e.info.name.toString()).toList();
    var shotList = totalScenes[initValueProvider.selectedSceneIndex]
        .data
        .map((e) => e.name.toString())
        .toList();
    var takeList = List.generate(200, (index) => (index + 1).toString());
    isLinked = initValueProvider.isLinked;
    okTk = initValueProvider.okTk;
    okSht = initValueProvider.okSht;
    sceneCol.init(0, sceneList);
    shotCol.init(0, shotList);
    takeCol.init(0, takeList);
    String initDesc = initValueProvider.currentDesc;
    String initNote = initValueProvider.currentNote;
    descController = TextEditingController(text: initDesc);
    shotNoteController = TextEditingController(text: initNote);
    WidgetsBinding.instance.endOfFrame.then((_) {
      var initS = initValueProvider.selectedSceneIndex;
      var initSh = initValueProvider.selectedShotIndex;
      var initTk = initValueProvider.selectedTakeIndex;
      var initCount = initValueProvider.recordCount;
      var initRecordLinker = initValueProvider.recordLinker;
      var initPrefixType = initValueProvider.prefixType;
      var initCustomPrefix = initValueProvider.customPrefix;
      sceneCol.init(initS);
      shotCol.init(initSh);
      takeCol.init(initTk);
      num.setValue(initCount);
      num.intervalSymbol = initRecordLinker;
      num.recorderType = initPrefixType;
      num.customPrefix = initCustomPrefix;
    });
  }

  void startListening() {
    subscription = FlutterAndroidVolumeKeydown.stream.listen((event) {
      if (event == HardwareButton.volume_down) {
        scrl3.valueDec(isLinked);
      } else if (event == HardwareButton.volume_up) {
        scrl3.valueInc(isLinked);
      }
    });
  }

  void stopListening() {
    subscription?.cancel();
  }

  Future<void> _initVibrate() async {
    // init the vibration
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
      _canVibrate
          ? debugPrint('This device can vibrate')
          : debugPrint('This device cannot vibrate');
    });
  }

  // @override
  // bool get wantKeepAlive => true;
}
/*
 * 
 */

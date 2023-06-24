import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:voislate/models/slate_log_item.dart';
//TODO:RecoverAndroid
// when just build for web, disable this package
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:flutter_android_volume_keydown/flutter_android_volume_keydown.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:voislate/providers/slate_log_notifier.dart';
import 'package:voislate/models/slate_schedule.dart';
import 'package:voislate/widgets/scene_schedule_page/note_editor.dart';

import '../providers/slate_num_notifier.dart';
import '../providers/value_scroll_control.dart';
import '../models/recorder_file_num.dart';
import '../providers/slate_status_notifier.dart';

import '../widgets/record_page/prev_note_editor.dart';
import '../widgets/record_page/slate_picker.dart';
import '../widgets/record_page/take_ok_dial.dart';
import '../widgets/record_page/shot_ok_dial.dart';
import '../widgets/record_page/quick_view_log_dialog.dart';
import '../widgets/record_page/file_counter.dart';
import '../widgets/record_page/recorder_joystick.dart';

/* 
这一页要做的事：
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
*/
class SlateRecord extends StatefulWidget {
  const SlateRecord({super.key});

  @override
  State<SlateRecord> createState() => _SlateRecordState();
}

class _SlateRecordState extends State<SlateRecord>
    with WidgetsBindingObserver{
  // Some variables don't need to be in the state

  late List<SceneSchedule> totalScenes;
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

//TODO:RecoverAndroid
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

  StreamSubscription<HardwareButton>? subscription;
  void startListening() {
    subscription = FlutterAndroidVolumeKeydown.stream.listen((event) {
      if (event == HardwareButton.volume_down) {
        // debugPrint("Volume down received");
        scrl3.valueDec(isLinked);
      } else if (event == HardwareButton.volume_up) {
        // debugPrint("Volume up received");
        // drawbackItem();
        scrl3.valueInc(isLinked);
      }
    });
  }

  void stopListening() {
    subscription?.cancel();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
//TODO:RecoverAndroid
    _initVibrate();
    // AndroidPhysicalButtons.listen((key) {
    //   debugPrint(key.toString());
    //   });
//TODO:RecoverAndroid
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
      sceneCol.init(initS);
      shotCol.init(initSh);
      takeCol.init(initTk);
      num.setValue(initCount);
      num.intervalSymbol = initRecordLinker;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
//TODO:RecoverAndroid
    stopListening();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var horizonPadding = 30.0;
    var pickerHistory = Hive.box('picker_history');
    // everytime setState, the build method will be called again

    var takeOkDial = TakeOkDial(
      context: context,
      tkStatus: okTk,
    );
    var shotOkDial = ShotOkDial(
      context: context,
      shtStatus: okSht,
    );
    var prevTakeEditor = PrevTakeEditor(
      num: num,
      descEditingController: descController,
    );
    var prevShotNote = PrevShotNote(
      currentScn: pickerHistory.isNotEmpty
          ? pickerHistory.getAt(pickerHistory.length - 1)[0]
          : '0',
      currentSht: pickerHistory.isNotEmpty
          ? pickerHistory.getAt(pickerHistory.length - 1)[1]
          : '0',
      currentTk: pickerHistory.isNotEmpty
          ? pickerHistory.getAt(pickerHistory.length - 1)[2]
          : '0',
      controller: shotNoteController,
    );

    return Consumer2<SlateStatusNotifier, SlateLogNotifier>(
        builder: (context, slateNotifier, logNotifier, child) {
      descController
          .addListener(() => slateNotifier.setNote(desc: descController.text));
      shotNoteController.addListener(
          () => slateNotifier.setNote(note: shotNoteController.text));
      void resetOkEnum() {
        takeOkDial.tkStatus = TkStatus.notChecked;
        shotOkDial.shtStatus = ShtStatus.notChecked;
      }

      void drawBackItem() {
        setState(() {
          num.decrement();
          try {
            logNotifier.removeLast();
            pickerHistory.deleteAt(pickerHistory.length - 1);
            // ignore: empty_catches
          } catch (e) {}
          // remove the last note
//TODO:RecoverAndroid
          if (_canVibrate) {
            Vibrate.feedback(FeedbackType.warning);
          }
        });
      }

      void addItem([bool isFake = false]) {
        List<String> prevTake = (pickerHistory.isNotEmpty)
            ? pickerHistory.getAt(pickerHistory.length - 1) as List<String>
            : [];
        if (num.prevName().isNotEmpty) {
          String currentScn = pickerHistory.isNotEmpty
              ? pickerHistory.getAt(pickerHistory.length - 1)[0]
              : '0';
          String currentSht = pickerHistory.isNotEmpty
              ? pickerHistory.getAt(pickerHistory.length - 1)[1]
              : '0';
          String currentTk = pickerHistory.isNotEmpty
              ? pickerHistory.getAt(pickerHistory.length - 1)[2]
              : '0';
          var newLogItem = SlateLogItem(
            scn: prevTake[0],
            sht: prevTake[1],
            tk: int.parse(prevTake[2]),
            filenamePrefix: num.prefix,
            filenameLinker: num.intervalSymbol,
            filenameNum: num.prevFileNum(),
            tkNote: !isFake
                ? (descController.text.isEmpty
                    ? 'S$currentScn Sh$currentSht Tk$currentTk'
                    : descController.text)
                : 'Fake Take',
            shtNote: shotNoteController.text,
            scnNote: totalScenes[sceneCol.selectedIndex].info.note.append,
            okTk: !isFake ? takeOkDial.tkStatus : TkStatus.bad,
            okSht: !isFake ? shotOkDial.shtStatus : ShtStatus.notChecked,
          );
          if (!isLinked)
            newLogItem.tkNote = "wild track after ${newLogItem.tkNote}";
          logNotifier.add(num.prevName(), newLogItem);
        }
        List<String> prevTakePickerData = [
          sceneCol.selected,
          shotCol.selected,
          takeCol.selected
        ];
        pickerHistory.add(prevTakePickerData);
        setState(() {
          shotChanged = false;
          num.increment();
          resetOkEnum();
//TODO:RecoverAndroid
          if (_canVibrate) {
            isFake
                ? Vibrate.feedback(FeedbackType.error)
                : Vibrate.feedback(FeedbackType.heavy);
          }
          descController.clear();
        });
      }

      var col3IncBtn = ElevatedButton(
          onPressed: () {
            addItem();
            takeCol.scrollToNext(isLinked);
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(70, 60)),
          child: const Icon(Icons.add));

      var bottomButtonStyleFrom =
          ElevatedButton.styleFrom(minimumSize: const Size(87, 50));
      var col3DecBtn = ElevatedButton(
        onPressed: () {
          drawBackItem();
          prevTakeEditor.descEditingController.clear();
          takeCol.scrollToPrev(isLinked);
        },
        style: bottomButtonStyleFrom,
        child: const Icon(Icons.remove),
      );

      scrl3 = ScrollValueController<SlateColumnThree>(
        context: context,
        textCon: descController,
        inc: () => addItem(),
        dec: () => drawBackItem(),
        col: takeCol,
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
          slateNotifier.setIndex(
            scene: sceneCol.selectedIndex,
            shot: shotCol.selectedIndex,
            take: takeCol.selectedIndex,
            count: num.number,
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

      var nextTakeMonitor = Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Card(
            child: Column(
              children: [
                const ListTile(
                  visualDensity: VisualDensity(vertical: -4),
                  leading: Icon(
                    Icons.fast_forward_outlined,
                    color: Colors.blue,
                  ),
                  title: Text('下一条:'),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.list),
                  //   onPressed: () {
                  //   },
                  // ),
                ),
                GestureDetector(
                  onTap: () {},
                  onLongPress: () {
                    showModalBottomSheet(
                    context: context, 
                    builder:(context){
                      return NoteEditor(
                        context: context,
                        scenes: totalScenes, 
                        scnIndex: sceneCol.selectedIndex,
                        shotIndex: shotCol.selectedIndex,
                        isRecordPage: true
                        );
                    } ,);
                    Hive.box('scenes_box').putAt(sceneCol.selectedIndex, totalScenes[sceneCol.selectedIndex]);
                  },
                  child: Column(
                    children: [
                      Text((shotChanged)?"长按修改当前镜":""),
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
                            shotNoteController.text =
                                totalScenes[sceneCol.selectedIndex]
                                        [shotCol.selectedIndex]
                                    .note
                                    .append;
                          }
                          pickerNumSync();
                          debugPrint('v1: , v2: , v3: ');
                        },
                      ),
                    ],
                  ),
                ),
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
          Transform.rotate(
            angle: 1.5708,
            child: IconButton(
              onPressed: () {
                setState(() {
                  isLinked = !isLinked;
                  slateNotifier.setLink(isLinked);
                });
              },
              icon: Icon(isLinked ? Icons.link : Icons.link_off),
              tooltip: '链接场次与录音编号',
            ),
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
                        AbsorbPointer(
                          absorbing: _isAbsorbing,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: IconButton(
                              onPressed: () {
                                addItem(true);
                              },
                              icon: Icon(Icons.redo),
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
                          ElevatedButton(
                              onPressed: () {},
                              style: bottomButtonStyleFrom,
                              child: const Icon(Icons.check_rounded))
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
        // floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        // floatingActionButton: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     DisplayNotesButton(
        //       notes: exportQuickNotes(),
        //       num: num,
        //     ),
        //     // takeOkDial,
        //     shotOkDial,
        //     AnimatedToggleSwitch.dual(
        //       dif: 5,
        //       current: _isAbsorbing,
        //       first: false,
        //       second: true,
        //       onChanged: (value) {
        //         setState(() => _isAbsorbing = value);
        //       },
        //       colorBuilder: (bool isLocked) =>
        //           !isLocked ? Colors.green : Colors.red,
        //       iconBuilder: (bool isLocked) =>
        //           Icon(!isLocked ? Icons.lock_open : Icons.lock),
        //       textBuilder: (bool isLocked) => Text(!isLocked ? '触控' : '锁定'),
        //     ),
        //   ],
        // ),
        //   Stack(alignment: AlignmentDirectional.bottomStart, children: [
        //   Positioned(
        //     top: MediaQuery.of(context).size.height * 0.3,
        //     child: DisplayNotesButton(
        //       notes: exportQuickNotes(),
        //       num: num,
        //     ),
        //   ),
        // ]),
      );
    });
  }

  // @override
  // bool get wantKeepAlive => true;
}

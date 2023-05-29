import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:voislate/models/slate_log_item.dart';
//TODO:RecoverAndroid
// when just build for web, disable this package
// import 'package:flutter_vibrate/flutter_vibrate.dart';
// import 'package:flutter_android_volume_keydown/flutter_android_volume_keydown.dart';
import 'package:voislate/providers/slate_log_notifier.dart';
import 'package:voislate/models/slate_schedule.dart';

import '../providers/slate_num_notifier.dart';
import '../providers/value_scroll_control.dart';
import '../models/recorder_file_num.dart';
import '../providers/slate_status_notifier.dart';

import '../widgets/record_page/prev_note_editor.dart';
import '../widgets/record_page/slate_picker.dart';
import '../widgets/record_page/floating_ok_dial.dart';
import '../widgets/record_page/quick_view_log_dialog.dart';
import '../widgets/record_page/file_counter.dart';
import '../widgets/record_page/dual_direction_joystick.dart';

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
15. *把currentScn改成prevScene
16. 保存配置的功能
*/
class SlateRecord extends StatefulWidget {
  const SlateRecord({super.key});

  @override
  State<SlateRecord> createState() => _SlateRecordState();
}

class _SlateRecordState extends State<SlateRecord> with WidgetsBindingObserver {
  // Some variables don't need to be in the state

  late List<SceneSchedule> totalScenes;
  late bool isLinked;
  final int _counterInit = 1;
  // about the logs
  final Box<SlateLogItem> logBox = Hive.box(RecordFileNum.today);
  var shotNoteController = TextEditingController();
  var descController = TextEditingController();
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

//TODO:RecoverAndroid
  // Future<void> _initVibrate() async {
  //   // init the vibration
  //   bool canVibrate = await Vibrate.canVibrate;
  //   setState(() {
  //     _canVibrate = canVibrate;
  //     _canVibrate
  //         ? debugPrint('This device can vibrate')
  //         : debugPrint('This device cannot vibrate');
  //   });
  // }

  // StreamSubscription<HardwareButton>? subscription;
  // void startListening() {
  //   subscription = FlutterAndroidVolumeKeydown.stream.listen((event) {
  //     if (event == HardwareButton.volume_down) {
  //       // debugPrint("Volume down received");
  //       scrl3.valueDec(isLinked);
  //     } else if (event == HardwareButton.volume_up) {
  //       // debugPrint("Volume up received");
  //       // drawbackItem();
  //       scrl3.valueInc(isLinked);
  //     }
  //   });
  // }

  // void stopListening() {
  //   subscription?.cancel();
  // }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
//TODO:RecoverAndroid
    // _initVibrate();
    // AndroidPhysicalButtons.listen((key) {
    //   debugPrint(key.toString());
    //   });
//TODO:RecoverAndroid
    // startListening();
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
    sceneCol.init(0, sceneList);
    shotCol.init(0, shotList);
    takeCol.init(0, takeList);
    WidgetsBinding.instance.endOfFrame.then((_) {
      var initS = initValueProvider.selectedSceneIndex;
      var initSh = initValueProvider.selectedShotIndex;
      var initTk = initValueProvider.selectedTakeIndex;
      var initCount = initValueProvider.recordCount;
      sceneCol.init(initS);
      shotCol.init(initSh);
      takeCol.init(initTk);
      num.setValue(initCount);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
//TODO:RecoverAndroid
    // stopListening();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var horizonPadding = 30.0;
    // everytime setState, the build method will be called again

    var prevTakeEditor = PrevTakeEditor(
      num: num,
      descEditingController: descController,
    );
    var prevShotNote = PrevShotNote(
      currentScn: sceneCol.selected,
      currentSht: shotCol.selected,
      currentTk: takeCol.selected,
      controller: shotNoteController,
    );

    return Consumer2<SlateStatusNotifier, SlateLogNotifier>(
        builder: (context, slateNotifier, logNotifier, child) {
      void drawBackItem() {
        setState(() {
          num.decrement();
          try {
            logBox.deleteAt(logBox.length - 1);
            // ignore: empty_catches
          } catch (e) {}
          // remove the last note
//TODO:RecoverAndroid
          // if (_canVibrate) {
          //   Vibrate.feedback(FeedbackType.warning);
          // }
        });
      }

      void addItem([bool isFake = false]) {
        if (isFake) prevTakeEditor.note = 'fake take';
        if (num.prevName().isNotEmpty) {
          var newLogItem = SlateLogItem(
            scn: sceneCol.selected,
            sht: shotCol.selected,
            tk: int.parse(takeCol.selected),
            filenamePrefix: num.prefix,
            filenameLinker: num.devider,
            filenameNum: num.number,
            tkNote: prevTakeEditor.note,
            shtNote: prevShotNote.shotNote,
            scnNote: totalScenes[sceneCol.selectedIndex].info.note.append,
            okTk: TkStatus.notChecked,
            okSht: ShtStatus.notChecked,
          );
          logBox.put(num.prevName(), newLogItem);
        }
        setState(() {
          num.increment();
//TODO:RecoverAndroid
          // if (_canVibrate) {
          //   isFake
          //       ? Vibrate.feedback(FeedbackType.error)
          //       : Vibrate.feedback(FeedbackType.heavy);
          // }
        });
      }

      var col3IncBtn = ElevatedButton(
          onPressed: () {
            addItem();
            prevTakeEditor.descEditingController.clear();
            takeCol.scrollToNext(isLinked);
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(70, 60)),
          child: const Icon(Icons.add));

      var col3DecBtn = ElevatedButton(
        onPressed: () {
          drawBackItem();
          prevTakeEditor.descEditingController.clear();
          takeCol.scrollToPrev(isLinked);
        },
        style: ElevatedButton.styleFrom(minimumSize: const Size(70, 60)),
        child: const Icon(Icons.remove),
      );

      scrl3 = ScrollValueController<SlateColumnThree>(
        context: context,
        textCon: prevTakeEditor.descEditingController,
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
          }
          // if the shot is changed manually
          if (shotCol.selectedIndex != slateNotifier.selectedShotIndex) {
            takeCol.init();
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
        var logs = logBox.values.toList().cast<SlateLogItem>();
        var notes = logs.map((log) {
          var fileName = log.filenamePrefix +
              log.filenameLinker +
              log.filenameNum.toString();
          return MapEntry(fileName, log.tkNote);
        }).toList();
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
                SlatePicker(
                  titles: titles,
                  stateOne: sceneCol,
                  stateTwo: shotCol,
                  stateThree: takeCol,
                  width: screenWidth - 2 * horizonPadding,
                  height: screenHeight * 0.17,
                  itemHeight: screenHeight * 0.13 - 48,
                  resultChanged: (v1, v2, v3) {
                    prevShotNote.controller.text =
                        totalScenes[sceneCol.selectedIndex]
                                [shotCol.selectedIndex]
                            .note
                            .append;
                    pickerNumSync();
                    debugPrint('v1: $v1, v2: $v2, v3: $v3');
                  },
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
                          child: DualDirectionJoystick(
                              width: 120,
                              sliderButtonContent: const Icon(Icons.mic),
                              backgroundColor: Colors.red.shade200,
                              backgroundColorEnd: Colors.green.shade200,
                              foregroundColor: Colors.purple.shade50,
                              onTapDown: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('正在录音'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              // onTapUp: () {
                              //   ScaffoldMessenger.of(context)
                              //       .hideCurrentSnackBar();
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     const SnackBar(
                              //       content: Text('录音取消'),
                              //       duration: Duration(seconds: 1),
                              //     ),
                              //   );
                              // },
                              onCancel: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('正在保存录音描述'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              onConfirmation: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('正在保存镜头描述'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: AbsorbPointer(
                                absorbing: _isAbsorbing, child: col3DecBtn)),
                      ],
                    ),
                    SwitchListTile(
                      value: !_isAbsorbing,
                      onChanged: ((value) =>
                          setState(() => _isAbsorbing = !value)),
                      title: Text('触控'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            Positioned(
                bottom: MediaQuery.of(context).size.height * 0.1,
                left: -5,
                child: FloatingOkDial(
                  context: context,
                )),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              child: DisplayNotesButton(
                notes: exportQuickNotes(),
                num: num,
              ),
            ),
          ],
        ),
      );
    });
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
// import 'package:android_physical_buttons/android_physical_buttons.dart';
import 'package:flutter_android_volume_keydown/flutter_android_volume_keydown.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';

import '../widgets/slate_picker.dart';
import '../models/slate_num_notifier.dart';
import '../widgets/simple_scroll_control.dart';
import '../widgets/quick_view_log_dialog.dart';
import '../widgets/file_counter.dart';
// import '../widgets/mono_direction_joystick.dart';
import '../models/recorder_file_num.dart';

/* 
这一页要做的事：
1. 轮盘绑定拍摄计划
2x 调整UI布局，删除一些输入框
3x 删除场镜相关悬浮按钮（本来就是用来验证功能的）
4x 调整轮盘高度
5. 考虑特殊录音（补录对白、补录环境音）
6. 跑条按钮
7. 想办法让文件名可以长按修改
8. "准备录音"不要那么高
9. "本场内容"注意schedule的数据结构
10. (备选方案)可以考虑加入急行军模式
11x *记得修改按键布局保证交互操作可以正常使用.某种意义上说，就是要足够的大
12x 增加振动交互
13x *修一下减了之后再加的问题
14. 把加减号改成方形的
15. *把currentScn改成prevScene
*/
class SlateRecord extends StatefulWidget {
  const SlateRecord({super.key});

  @override
  State<SlateRecord> createState() => _SlateRecordState();
}

class _SlateRecordState extends State<SlateRecord> {
  // Some variables don't need to be in the state
  final int _counterInit = 1;
  var note = '';
  List<MapEntry<String, String>> notes = [];
  List<MapEntry<String, String>> oldNotes = [];
  var ones = List.generate(8, (index) => (index + 1).toString());
  var twos = ['1A', '2', '6', '5', '4', '7', '8', '9', '10'];
  var threes = List.generate(200, (index) => (index + 1).toString());
  var titles = ['Scene', 'Shot', 'Take'];
  late String currentScn;
  late String currentSht;
  late String currentTk;
  final col2 = SlateColumnTwo();
  final col1 = SlateColumnOne();
  final col3 = SlateColumnThree();
  final num = RecordFileNum();
  late SliderValueController<SlateColumnThree> scrl3;
  late String currentFileNum;
  String previousFileNum = '';
  final inputNotice = 'Waiting for input...';

  // 手动跑一条录音
  void fakeTake() {
    setState(() {
      previousFileNum = currentFileNum;
      num.increment();
      currentFileNum = num.fullName();
      notes.last = MapEntry(notes.last.key, 'fake take');
    });
  }

  void drawbackItem() {
    setState(() {
      num.decrement();
      // remove the last note
      if (notes.isNotEmpty) {
        notes = oldNotes;
        if (oldNotes.isNotEmpty) {
          oldNotes.removeLast();
          oldNotes.last = MapEntry(oldNotes.last.key, inputNotice);
        }
        oldNotes = (oldNotes.length == 1) ? notes = [] : oldNotes;
        previousFileNum = oldNotes.isEmpty ? '' : oldNotes.last.key;
      }
      note = '';
      if (_canVibrate) {
        Vibrate.feedback(FeedbackType.warning);
      }
    });
  }

  void addItem(String currentFileNum) {
    setState(() {
      oldNotes = notes;
      if (notes.isEmpty) {
        notes.add(const MapEntry("File Name", "Note"));
        notes.add(MapEntry(num.fullName(), inputNotice));
      } else {
        note = note.isEmpty ? 'note ${num.number - 1}' : note;
        notes.last = (notes.last.value == 'fake take')
            ? notes.last
            : MapEntry(
                previousFileNum, // File Name
                note, //Note
              );
        notes.add(MapEntry(num.fullName(), inputNotice));
      }
      previousFileNum = currentFileNum;
      num.increment();
      note = '';
      if (_canVibrate) {
        Vibrate.feedback(FeedbackType.heavy);
      }
    });
  }

  // vibration feedback related
  bool _canVibrate = true;

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
        scrl3.valueDec();
      } else if (event == HardwareButton.volume_up) {
        // debugPrint("Volume up received");
        // drawbackItem();
        scrl3.valueInc();
      }
    });
  }

  void stopListening() {
    subscription?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _initVibrate();
    // AndroidPhysicalButtons.listen((key) {
    //   debugPrint(key.toString());
    //   });
    startListening();
    var box = Hive.box('scenes_box');
    var scenes = box.values.toList().cast();
    ones = scenes.map((e) => e.info.name.toString()).toList();

    currentScn = '1';
    currentSht = '1';
    currentTk = '1';
  }

  @override
  void dispose() {
    super.dispose();
    stopListening();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var horizonPadding = 30.0;
    // everytime setState, the build method will be called again
    currentFileNum = num.fullName();
    final TextEditingController textEditingController = TextEditingController();

    var col3IncBtn = IncrementCounterButton<SlateColumnThree>(
      onPressed: () => addItem(currentFileNum),
      textCon: textEditingController,
    );

    var col3DecBtn = DecrementCounterButton<SlateColumnThree>(
      onPressed: () => drawbackItem(),
      textCon: textEditingController,
    );

    void pickerNumSync() {
      setState(() {
        currentScn = col1.selected;
        currentSht = col2.selected;
        currentTk = col3.selected;
        currentFileNum = num.fullName();
        if (notes.isNotEmpty) {
          notes.last = MapEntry(currentFileNum, inputNotice);
        }
      });
    }

    var nextTakeMonitor = Card(
      child: Column(
        children: [
          const ListTile(
            visualDensity: VisualDensity(vertical: -4),
            leading: Icon(
              Icons.radio_button_checked_outlined,
              color: Colors.red,
            ),
            title: Text('准备录音:'),
            // trailing: IconButton(
            //   icon: const Icon(Icons.list),
            //   onPressed: () {
            //   },
            // ),
          ),
          SlatePicker(
            ones: ones,
            twos: twos,
            threes: threes,
            titles: titles,
            stateOne: col1,
            stateTwo: col2,
            stateThree: col3,
            width: screenWidth - 2 * horizonPadding,
            height: screenHeight * 0.17,
            itemHeight: screenHeight * 0.13 - 48,
            resultChanged: (v1, v2, v3) {
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
    );

    var prevTakeEditor = Flexible(
      child: ListTileTheme(
        minLeadingWidth: 5,
        child: ListTile(
          title: Row(
            children: [
              const Icon(Icons.stop_circle),
              Text(
                  '${num.prefix}${num.devider}${num.number < 2 ? '?' : (num.number - 1).toString()}'),
            ],
          ),
          subtitle: SizedBox(
            // width: screenWidth * 0.3,
            child: TextField(
              // bind the input to the note variable
              maxLines: 3,
              controller: textEditingController,
              onChanged: (text) {
                note = text;
              },
              decoration: const InputDecoration(
                // contentPadding: EdgeInsets.symmetric(vertical: 20),
                border: OutlineInputBorder(),
                hintText: 'Note',
              ),
            ),
          ),
        ),
      ),
    );

    var prevShotNote = Flexible(
      child: ListTileTheme(
        minLeadingWidth: 5,
        child: ListTile(
          title: Row(
            children: [
              const Icon(Icons.stop_circle),
              Text(
                  'S$currentScn Sh$currentSht Tk${int.parse(currentTk) < 2 ? '?' : (int.parse(currentTk) - 1).toString()}'),
            ],
          ),
          subtitle: SizedBox(
            // width: screenWidth * 0.3,
            child: TextField(
              // bind the input to the note variable
              maxLines: 3,
              controller: textEditingController,
              onChanged: (text) {
                note = text;
              },
              decoration: const InputDecoration(
                // contentPadding: EdgeInsets.symmetric(vertical: 20),
                border: OutlineInputBorder(),
                hintText: 'Note',
              ),
            ),
          ),
          // trailing: Container(
          //   width: 1,
          //   height: 10,
          //   padding: const EdgeInsets.symmetric(vertical: 16),
          //   alignment: Alignment.center,
          //   child: IconButton(
          //     icon: const Icon(Icons.mic),
          //     onPressed: () {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text('正在保存描述'),
          //           duration: Duration(seconds: 1),
          //         ),
          //       );
          //     },
          //           ),
          // ),
        ),
      ),
    );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: col1),
          ChangeNotifierProvider.value(value: col2),
          ChangeNotifierProvider.value(value: col3),
        ],
        builder: (context, child) {
          scrl3 = SliderValueController<SlateColumnThree>(
            context: context,
            textCon: textEditingController,
            inc: () => addItem(currentFileNum),
            dec: () => drawbackItem(),
            col: col3,
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
                        nextTakeMonitor,
                        Row(
                          children: [
                            Expanded(
                              child: col3IncBtn,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            prevTakeEditor,
                            IconButton(
                              icon: const Icon(Icons.mic),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('正在保存描述'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            prevShotNote,
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: col3DecBtn),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                okFloatingDial(context),
                DisplayNotesButton(notes: notes),
              ],
            ),
          );
        });
  }

  SpeedDial okFloatingDial(BuildContext context) {
    return SpeedDial(
      child: const Text('OK'),
      speedDialChildren: <SpeedDialChild>[
        SpeedDialChild(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('声音可用'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          label: '声音可用',
          child: const Icon(Icons.gpp_good),
        ),
        SpeedDialChild(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('声音弃用'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          label: '声音弃用',
          child: const Icon(Icons.gpp_bad),
        ),
      ],
    );
  }
}

class DisplayNotesButton extends StatelessWidget {
  // a button to show the notes in a list view
  const DisplayNotesButton({
    super.key,
    required this.notes,
  });

  final List<MapEntry<String, String>> notes;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        quickViewLog(context, notes);
      },
      tooltip: 'Quick View Log',
      child: const Icon(Icons.notes),
    );
  }
}

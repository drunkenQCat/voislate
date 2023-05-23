import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
// import 'package:android_physical_buttons/android_physical_buttons.dart';
import 'package:flutter_android_volume_keydown/flutter_android_volume_keydown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/slate_num_notifier.dart';
import '../models/value_scroll_control.dart';
import '../models/recorder_file_num.dart';
import '../models/slate_status_notifier.dart';

import '../widgets/record_page/slate_picker.dart';
import '../widgets/record_page/floating_ok_dial.dart';
import '../widgets/record_page/quick_view_log_dialog.dart';
import '../widgets/record_page/file_counter.dart';
import '../widgets/record_page/dual_direction_joystick.dart';

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
16. 保存配置的功能
*/
class SlateRecord extends StatefulWidget {
  const SlateRecord({super.key});

  @override
  State<SlateRecord> createState() => _SlateRecordState();
}

class _SlateRecordState extends State<SlateRecord> with WidgetsBindingObserver {
  // Some variables don't need to be in the state
  late Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool isLinked = true;
  final int _counterInit = 1;
  var note = '';
  String shotNote = '';
  List<MapEntry<String, String>> notes = [];
  List<MapEntry<String, String>> oldNotes = [];
  var ones = List.generate(8, (index) => (index + 1).toString());
  var twos = ['1A', '2', '6', '5', '4', '7', '8', '9', '10'];
  var threes = List.generate(200, (index) => (index + 1).toString());
  var titles = ['Scene', 'Shot', 'Take'];
  late String currentScn;
  late String currentSht;
  late String currentTk;
  final col1 = SlateColumnOne();
  final col2 = SlateColumnTwo();
  final col3 = SlateColumnThree();
  final num = RecordFileNum();
  late SliderValueController<SlateColumnThree> scrl3;
  final TextEditingController descEditingController = TextEditingController();
  final TextEditingController noteEditingController = TextEditingController();
  late String currentFileNum;
  String previousFileNum = '';
  final inputNotice = 'Waiting for input...';

  late Future<int> col3InitIdx;

  bool _isTouchable = false;

  // 手动跑一条录音
  // drawback the last note, and decrease the file number,but not the take number
  void drawBackItem() {
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
  void addItem(String currentFileNum, [bool isFake = false]) {
    setState(() {
      oldNotes = notes;
      if (notes.isEmpty) {
        notes.add(const MapEntry("File Name", "Note"));
        notes.add(MapEntry(num.fullName(), inputNotice));
      } else {
        note = note.isEmpty ? 'note ${num.number - 1}' : note;
        note = isFake ? 'fake $note' : note;
        notes.last = MapEntry(
          previousFileNum, // File Name
          note, //Note
        );
        notes.add(MapEntry(num.fullName(), inputNotice));
      }
      previousFileNum = currentFileNum;
      num.increment();
      note = '';
      if (_canVibrate) {
        isFake
            ? Vibrate.feedback(FeedbackType.error)
            : Vibrate.feedback(FeedbackType.heavy);
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

  void loadSettings() async {
    var prefs = await _prefs;
  }

  void saveSettings() async {
    // save settings here
    var prefs = await _prefs;
    prefs.setInt('currentSceneIndex', col1.selectedIndex);
    prefs.setInt('currentShotIndex', col2.selectedIndex);
    prefs.setInt('currentTakeIndex', col3.selectedIndex);
    prefs.setBool('isLinked', isLinked);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _initVibrate();
    col3InitIdx = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('currentTakeIndex') ?? 0;
    });
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    stopListening();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      loadSettings();
      // retrieve data here
    } else if (state == AppLifecycleState.paused) {
      saveSettings();
      // save data here
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var horizonPadding = 30.0;
    // everytime setState, the build method will be called again
    currentFileNum = num.fullName();

    var col3IncBtn = ElevatedButton(
        onPressed: () {
          addItem(currentFileNum);
          descEditingController.clear();
          col3.scrollToNext(isLinked);
        },
        style: ElevatedButton.styleFrom(minimumSize: const Size(70, 60)),
        child: const Icon(Icons.add));

    var col3DecBtn = ElevatedButton(
      onPressed: () {
        drawBackItem();
        descEditingController.clear();
        col3.scrollToPrev(isLinked);
      },
      style: ElevatedButton.styleFrom(minimumSize: const Size(70, 60)),
      child: const Icon(Icons.remove),
    );


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
        ),
        Transform.rotate(
          angle: 1.5708,
          child: IconButton(
            onPressed: () {
              setState(() {
                isLinked = !isLinked;
              });
            },
            icon: Icon(isLinked ? Icons.link : Icons.link_off),
            tooltip: '链接场次与录音编号',
          ),
        ),
      ],
    );

    var prevTakeEditor = Flexible(
      child: ListTileTheme(
        minLeadingWidth: 5,
        child: ListTile(
          title: const Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: Colors.red,
              ),
              Text('正在录制'),
            ],
          ),
          subtitle: SizedBox(
            // width: screenWidth * 0.3,
            child: TextField(
              // bind the input to the note variable
              maxLines: 3,
              controller: descEditingController,
              onChanged: (text) {
                note = text;
              },
              decoration: InputDecoration(
                // contentPadding: EdgeInsets.symmetric(vertical: 20),
                border: OutlineInputBorder(),
                hintText:
                    '${num.prefix}${num.devider}${num.number < 2 ? '?' : (num.number - 1).toString()}\n 录音标注...',
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
              const Icon(
                Icons.movie_creation_outlined,
                color: Colors.red,
              ),
              Text(
                  'S$currentScn Sh$currentSht Tk${int.parse(currentTk) < 2 ? '?' : (int.parse(currentTk) - 1).toString()}'),
            ],
          ),
          subtitle: SizedBox(
            // width: screenWidth * 0.3,
            child: TextField(
              // bind the input to the note variable
              maxLines: 3,
              controller: noteEditingController,
              onChanged: (text) {
                shotNote = text;
              },
              decoration: const InputDecoration(
                // contentPadding: EdgeInsets.symmetric(vertical: 20),
                border: OutlineInputBorder(),
                hintText: 'Shot Note',
              ),
            ),
          ),
        ),
      ),
    );

    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: col1),
          ChangeNotifierProvider.value(value: col2),
          ChangeNotifierProvider.value(value: col3),
        ],
        builder: (context, child) {
          scrl3 = SliderValueController<SlateColumnThree>(
            context: context,
            textCon: descEditingController,
            inc: () => addItem(currentFileNum),
            dec: () => drawBackItem(),
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
                        AbsorbPointer(
                            absorbing: _isTouchable, child: nextTakeMonitor),
                        Stack(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: AbsorbPointer(
                                        absorbing: _isTouchable,
                                        child: col3IncBtn))
                              ],
                            ),
                            AbsorbPointer(
                              absorbing: _isTouchable,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    addItem(currentFileNum, true);
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
                              absorbing: _isTouchable,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  prevTakeEditor,
                                  prevShotNote,
                                ],
                              ),
                            ),
                            DualDirectionJoystick(
                              width: 120,
                              sliderButtonContent: const Icon(Icons.mic),
                              onTapDown: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('正在录音'),
                                  duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              onTapUp: () {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('录音取消'),
                                  duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              onCancel: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('正在保存录音描述'),
                                  duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              onConfirmation: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('正在保存镜头描述'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                            }),
                            // IconButton(
                            //   icon: const Icon(Icons.mic),
                            //   onPressed: () {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       const SnackBar(
                            //         content: Text('正在保存描述'),
                            //         duration: Duration(seconds: 1),
                            //       ),
                            //     );
                            //   },
                            // ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: AbsorbPointer(
                                    absorbing: _isTouchable,
                                    child: col3DecBtn)),
                          ],
                        ),
                        SwitchListTile(
                          value: !_isTouchable,
                          onChanged: ((value) =>
                              setState(() => _isTouchable = !value)),
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
                // Positioned(
                //     bottom: MediaQuery.of(context).size.height * 0.1,
                //     left: -5,
                //     child: okFloatingDial(context)),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  child: DisplayNotesButton(notes: notes),
                ),
              ],
            ),
          );
        });
  }
}



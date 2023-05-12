import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/slate_picker.dart';
import '../models/slate_num_notifier.dart';
import '../widgets/add_remove_buttons.dart';
import '../widgets/quick_view_log_dialog.dart';
import '../widgets/file_counter.dart';
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
11. *记得修改按键布局保证交互操作可以正常使用.某种意义上说，就是要足够的大
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
  var ones = List.generate(8, (index) => (index + 1).toString());
  var twos = ['1A', '2', '6', '5', '4', '7', '8', '9', '10'];
  var threes = List.generate(200, (index) => (index + 1).toString());
  var titles = ['Scene', 'Shot', 'Take'];
  final col2 = SlateColumnTwo();
  final col1 = SlateColumnOne();
  final col3 = SlateColumnThree();
  final num = RecordFileNum();
  String previousFileNum = '';
  

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var horizonPadding = 30.0;
    // everytime setState, the build method will be called again
    var currentFileNum = num.fullName();
    final TextEditingController textEditingController = TextEditingController();

    // var col1IncBtn = IncrementCounterButton<SlateColumnOne>(
    //   onPressed: () => {},
    //   textCon: textEditingController,
    // );
    // var col1DecBtn = DecrementCounterButton<SlateColumnOne>(
    //   onPressed: () => {},
    //   textCon: textEditingController,
    // );
    // var col2IncBtn = IncrementCounterButton<SlateColumnTwo>(
    //   onPressed: () => {},
    //   textCon: textEditingController,
    // );
    // var col2DecBtn = DecrementCounterButton<SlateColumnTwo>(
    //   onPressed: () => {},
    //   textCon: textEditingController,
    // );
    var col3IncBtn = IncrementCounterButton<SlateColumnThree>(
      onPressed: () {
        setState(() {
            if (notes.isEmpty){
              notes.add(const MapEntry("File Name", "Note"));
              notes.add(MapEntry(num.fullName(), 'Waiting for input...'));
            } 
            else
            { 
              note = note.isEmpty ? 'note ${num.number -1}' : note;
              notes.last = MapEntry(
                previousFileNum, // File Name
                note,//Note
                );
              notes.add(MapEntry(num.fullName(), 'Waiting for input...'));
            }
            previousFileNum = currentFileNum;
            num.increment();
            note = '';
          });
        },
      textCon: textEditingController,
    );

    var col3DecBtn = DecrementCounterButton<SlateColumnThree>(
      onPressed: () {
        setState(() {
          num.decrement();
          // remove the last note
          if (notes.isNotEmpty) {
            notes.removeLast();
          }
          note = '';
        });
      },
      textCon: textEditingController,
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[

                      // The information about next take
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              visualDensity: const VisualDensity(vertical: -4),
                              leading: const Icon(Icons.radio_button_checked_outlined, color: Colors.red,),
                              title: const Text('准备录音:'),
                              trailing: IconButton(
                                icon: const Icon(Icons.list),
                                onPressed: () {
                                },
                              ),
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
                                resultChanged: (v1, v2, v3) =>
                                    debugPrint('v1: $v1, v2: $v2, v3: $v3')),
                            // add an input box to have a note about the number
                                        
                            const SizedBox(height: 10,),
                            FileCounter(
                              init: _counterInit,
                              num: num,
                            ),
                          ],
                        ),
                      ),
                                  
                      Text('本场内容'),
                      // a card with a title "备注信息"， and a text field to
                      // enter the note about the number and
                      // a icon button to show snack bar "正在保存描述" when long pressed
                      // the icon should be a waveform icon
                      // this card is designed to save the message of last record
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.stop_circle),
                              title: Text('${num.prefix}${num.devider}${num.number < 2 ? '?' :(num.number - 1).toString()}备注信息:'),
                            ),
                            SizedBox(
                              width: screenWidth * 0.8,
                              child: TextField(
                                // bind the input to the note variable
                                controller: textEditingController,
                                onChanged: (text) {
                                  note = text;
                                },
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.record_voice_over),
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter a note about the previous',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.waves),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('正在保存描述'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                                  
                      // this is a button with title"声音可用", when pressed,
                      // it will show a little toast message
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('声音可用'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Text('声音可用'),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            floatingActionButton: Column(
              // make the children of the column align to the end
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // col1IncBtn,
                    // col2IncBtn,
                    col3IncBtn,
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // col1DecBtn,
                    // col2DecBtn,
                    col3DecBtn,
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DisplayNotesButton(notes: notes),
                  ],
                ),
              ],
            ),
          );
        });
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

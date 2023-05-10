import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../widgets/slate_picker.dart';
import '../models/slate_num_notifier.dart';
import '../widgets/add_remove_buttons.dart';
import '../widgets/quick_view_log_dialog.dart';
import '../widgets/file_counter.dart';
import '../models/recorder_file_num.dart';

class SlateRecord extends StatefulWidget {
  const SlateRecord({super.key});

  @override
  State<SlateRecord> createState() => _SlateRecordState();
}

class _SlateRecordState extends State<SlateRecord> {
  int _counterInit = 1;
  var note = '';
  List<MapEntry<String, String>> notes = [];
  var ones = List.generate(8, (index) => ( index + 1 ).toString());
  var twos = ['1A', '2', '6', '5', '4', '7', '8', '9', '10'];
  var threes = List.generate(200, (index) => ( index + 1 ).toString());
  var titles = ['Scene', 'Shot', 'Take'];
  final col2 = SlateColumnTwo();
  final col1 = SlateColumnOne();
  final col3 = SlateColumnThree();
  var num= RecordFileNum();

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var horizonPadding = 30.0;
    final TextEditingController _textEditingController = TextEditingController();

    var col1IncBtn =
        IncrementCounterButton<SlateColumnOne>(onPressed: () => {},textCon: _textEditingController,);
    var col1DecBtn =
        DecrementCounterButton<SlateColumnOne>(onPressed: () => {},textCon: _textEditingController,);
    var col2IncBtn =
        IncrementCounterButton<SlateColumnTwo>(onPressed: () => {},textCon: _textEditingController,);
    var col2DecBtn =
        DecrementCounterButton<SlateColumnTwo>(onPressed: () => {},textCon: _textEditingController,);
    var col3IncBtn = IncrementCounterButton<SlateColumnThree>(
      onPressed: () {
        setState(() {
          var _ = num.fullName();
          if (note.isEmpty) {
            notes.add(MapEntry(_ ,'note ${num.number}'));
          } else {
            notes.add(MapEntry(_ , note));
          }
          num.increment();
          note = '';
        });
      },
      textCon: _textEditingController,
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
        }
        );
      },
      textCon: _textEditingController,
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
            body: Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SlatePicker(
                      ones: ones,
                      twos: twos,
                      threes: threes,
                      titles: titles,
                      stateOne: col1,
                      stateTwo: col2,
                      stateThree: col3,
                      width: screenWidth - 2 * horizonPadding,
                      height: screenHeight * 0.1,
                      itemHeight: screenHeight * 0.1 - 40,
                      resultChanged: (v1, v2, v3) =>
                          debugPrint('v1: $v1, v2: $v2, v3: $v3')),
                  // add an input box to have a note about the number

                  Container(
                    width: screenWidth * 0.8,
                    child: TextField(
                      // bind the input to the note variable
                      controller: _textEditingController,
                      onChanged: (text) {
                        note = text;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.record_voice_over),
                        border: OutlineInputBorder(),
                        hintText: 'Enter a note about the number',
                      ),
                    ),
                  ),

                  FileCounter(init: _counterInit, num: num,),
                  
                  // a card with a title "备注信息"， and a text field to 
                  // enter the note about the number and
                  // a icon button to show snack bar "正在保存描述" when long pressed
                  // the icon should be a waveform icon
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('备注信息'),
                          subtitle: Text(note),
                        ),
                        TextField(
                          onChanged: (text) {},
                          decoration: const InputDecoration(
                            icon: Icon(Icons.record_voice_over),
                            border: OutlineInputBorder(),
                            hintText: 'Enter a note about the number',
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
            floatingActionButton: Column(
              // make the children of the column align to the end
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    col1IncBtn,
                    col2IncBtn,
                    col3IncBtn,
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    col1DecBtn,
                    col2DecBtn,
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

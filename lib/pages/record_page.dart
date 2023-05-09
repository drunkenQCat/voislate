import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../widgets/slate_picker.dart';
import '../models/slate_num_notifier.dart';
import '../widgets/add_remove_buttons.dart';
import '../widgets/quick_view_log_dialog.dart';
import '../widgets/file_counter.dart';

class SlateRecord extends StatefulWidget {
  const SlateRecord({super.key});

  @override
  State<SlateRecord> createState() => _SlateRecordState();
}

class _SlateRecordState extends State<SlateRecord> {
  int _counter = 0;
  var note = '';
  List notes = [];
  var ones = List.generate(8, (index) => index.toString());
  var twos = ['1A', '2', '6', '5', '4', '7', '8', '9', '10'];
  var threes = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  var titles = ['Scene', 'Shot', 'Take'];
  final col2 = SlateColumnTwo();
  final col1 = SlateColumnOne();
  final col3 = SlateColumnThree();

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var horizonPadding = 30.0;

    var col1IncBtn =
        IncrementCounterButton<SlateColumnOne>(onPressed: () => {});
    var col1DecBtn =
        DecrementCounterButton<SlateColumnOne>(onPressed: () => {});
    var col2IncBtn =
        IncrementCounterButton<SlateColumnTwo>(onPressed: () => {});
    var col2DecBtn =
        DecrementCounterButton<SlateColumnTwo>(onPressed: () => {});
    var col3IncBtn = IncrementCounterButton<SlateColumnThree>(
      onPressed: () {
        setState(() {
          _counter++;
          // add a new note, and
          if (note.isEmpty) {
            notes.add('note $_counter');
          } else {
            notes.add(note);
          }
        });
      },
    );

    var col3DecBtn = DecrementCounterButton<SlateColumnThree>(
      onPressed: () {
        setState(() {
          _counter--;
          // remove the last note
          if (notes.isNotEmpty) {
            notes.removeLast();
          }
        });
      },
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

                  FileCounter(counter: _counter),
                  const Text(
                    'Go Ahead pushed the button this many times:',
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

  final List notes;

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

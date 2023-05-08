import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/slate_picker.dart';
import 'models/slate_num_notifier.dart';
import 'widgets/add_remove_buttons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var note = '';
  List notes = [];
  var ones = List.generate(8, (index) => index.toString());
  var twos = ['1A', '2', '6', '4', '5', '4', '7', '8', '9', '10'];
  var threes = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  var titles = ['Scene', 'Shot', 'Take'];
  final col2 = SlateColumnTwo();
  final col1 = SlateColumnOne();
  final col3 = SlateColumnThree();

  // Widget _incrementCounter() {
  //   return Consumer<SlateColumnThree>(
  //     builder: (_, col3, child) {
  //       return FloatingActionButton(
  //         onPressed: () {
  //           setState(() {
  //             _counter++;
  //             // add a new note, and
  //             if (note.length == 0) {
  //               notes.add('note $_counter');
  //             } else {
  //               notes.add(note);
  //             }
  //           });
  //           col3.scrollToNext();
  //         },
  //         tooltip: 'Increment',
  //         child: child,
  //       );
  //     },
  //     child: const Icon(Icons.add),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var horizonPadding = 30.0;

    var col1IncBtn = IncrementCounterButton<SlateColumnOne>(onPressed: () =>{});
    var col1DecBtn = DecrementCounterButton<SlateColumnOne>(onPressed: () =>{});
    var col2IncBtn = IncrementCounterButton<SlateColumnTwo>(onPressed: () =>{});
    var col2DecBtn = DecrementCounterButton<SlateColumnTwo>(onPressed: () =>{});
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
            notes.removeLast();
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
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text(widget.title),
            ),
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

                  const Text(
                    'Go Ahead pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            var screenWidth = MediaQuery.of(context).size.width;
            var screenHeight = MediaQuery.of(context).size.height;
            return AlertDialog(
              title: const Text('Notes'),
              content: Container(
                width: screenWidth * 0.618,
                height: screenHeight * 0.7,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                '$index',
                                textAlign: TextAlign.right,
                              )),
                              Center(
                                child: Row(
                                  children: const [
                                    SizedBox(width: 20),
                                    VerticalDivider(
                                      color: Colors.black,
                                      thickness: 1,
                                      width: 20,
                                    ),
                                    SizedBox(width: 20),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Text(
                                '${notes[index]}',
                                textAlign: TextAlign.left,
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
      tooltip: 'Show Notes',
      child: const Icon(Icons.notes),
    );
  }
}

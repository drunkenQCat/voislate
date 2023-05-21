import 'package:flutter/material.dart';

import '../models/recorder_file_num.dart';

class FileCounter extends StatelessWidget {
  final RecordFileNum num;
  final int _initCounter;
  const FileCounter({
    super.key,
    required int init,
    required this.num,
  }) : _initCounter = init;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.headlineMedium;

    return StreamBuilder<int>(
      stream: num.value,
      initialData: _initCounter,
      builder: (context, snapshot) {
        return Center(
          child: FileNameDisplayCard(
              num: num, snapshot: snapshot, style: textStyle),
        );
      },
    );
  }
}

class FileNameDisplayCard extends StatelessWidget {
  final AsyncSnapshot snapshot;
  final TextStyle? style;
  final RecordFileNum num;

  const FileNameDisplayCard({
    super.key,
    required this.num,
    required this.snapshot,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle tagStyle = TextStyle(
      fontSize: 16,
      color: Colors.black45,
      fontWeight: FontWeight.w100,
    );
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Card(
        color: Colors.blueGrey[100],
        margin: EdgeInsets.fromLTRB(21, 5, 16, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  num.prefix.contains(RegExp(r'^[0-9]+$')) ? 'Date' : 'Custom',
                  style: tagStyle,
                ),
                Text(
                  num.prefix,
                  style: style,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Devider',
                  style: tagStyle,
                ),
                GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String value = num.devider;
                        return AlertDialog(
                          title: const Text('Edit Devider'),
                          content: TextField(
                            onChanged: (newValue) {
                              value = newValue;
                            },
                            onSubmitted: (newValue) {
                              num.devider = newValue;
                              Navigator.of(context).pop();
                            },
                            controller: TextEditingController(text: value),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    num.devider,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.black45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                const Text(
                  'Num',
                  style: tagStyle,
                ),
                GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String value = snapshot.data.toString();
                        return AlertDialog(
                          title: const Text('Edit Num'),
                          content: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (newValue) {
                              value = newValue;
                            },
                            onSubmitted: (newValue) {
                              num.setValue(int.parse(newValue));
                              Navigator.of(context).pop();
                            },
                            controller: TextEditingController(text: value),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    snapshot.data.toString(),
                    style: style,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
    return Padding(
      padding: const EdgeInsets.only(left: 25,right: 25),
      child: Card(
        color: Colors.blueGrey[100],
        margin: EdgeInsets.fromLTRB(21, 5, 16, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(num.prefix,style: style,),
            Text(num.devider,style: const TextStyle(
              fontSize: 32,
              color: Colors.black45,
              fontWeight: FontWeight.w400,
            ),),
            SizedBox(width: 10,),
            Text(snapshot.data.toString(),style: style,),
          ],
        ),
      ),
    );
  }
}
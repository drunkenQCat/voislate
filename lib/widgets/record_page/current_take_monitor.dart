import 'package:flutter/material.dart';

class CurrentTakeMonitorDart extends StatelessWidget {
  const CurrentTakeMonitorDart({
    super.key,
    required this.currentScn,
    required this.currentSht,
    required this.currentTk,
  });
  final String currentScn;
  final String currentSht;
  final String currentTk;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.movie_creation_outlined,
            size: 19,
            color: Colors.green,
          ),
          Text("正在拍摄：S$currentScn Sh$currentSht Tk$currentTk"),
        ],
      ),
    );
  }
}

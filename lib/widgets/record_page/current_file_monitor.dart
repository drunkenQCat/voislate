import 'package:flutter/material.dart';
import 'package:voislate/models/recorder_file_num.dart';

class CurrentFileMonitor extends StatelessWidget {
  const CurrentFileMonitor({super.key, required this.fileNum});
  final RecordFileNum fileNum;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.radio_button_checked,
            size: 19,
            color: Colors.red,
          ),
          Text("正在录制:T${fileNum.prevFileNum().toString().padLeft(3, '0')}"),
        ],
      ),
    );
  }
}

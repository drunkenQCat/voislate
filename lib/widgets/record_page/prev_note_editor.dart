// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:voislate/models/recorder_file_num.dart';

class PrevTakeEditor extends StatelessWidget {
  PrevTakeEditor({
    Key? key,
    required this.num,
  }) : super(key: key);

  final TextEditingController descEditingController = TextEditingController();
  final RecordFileNum num;
  var note = '';

  @override
  Widget build(BuildContext context) {
    return Flexible(
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
  }
}

class PrevShotNote extends StatefulWidget {
  PrevShotNote({
    Key? key,
    required this.currentScn,
    required this.currentSht,
    required this.currentTk,
  }) : super(key: key);

  final String currentScn;
  final String currentSht;
  final String currentTk;
  String shotNote = '';

  @override
  State<PrevShotNote> createState() => _PrevShotNoteState();
}

class _PrevShotNoteState extends State<PrevShotNote> {
  final TextEditingController descEditingController = TextEditingController();

  final TextEditingController noteEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Flexible(
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
                  'S${widget.currentScn} Sh${widget.currentSht} Tk${int.parse(widget.currentTk) < 2 ? '?' : (int.parse(widget.currentTk) - 1).toString()}'),
            ],
          ),
          subtitle: SizedBox(
            // width: screenWidth * 0.3,
            child: TextField(
              // bind the input to the note variable
              maxLines: 3,
              controller: noteEditingController,
              onChanged: (text) {
                widget.shotNote = text;
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
  }
}

import 'package:flutter/material.dart';
import 'package:voislate/models/recorder_file_num.dart';

class PrevTakeEditor extends StatelessWidget {
  /// This is the Description Editor for the previous record file.
  PrevTakeEditor({
    Key? key,
    required this.num,
    required this.descEditingController,
  }) : super(key: key);

  final TextEditingController descEditingController;
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
                border: const OutlineInputBorder(),
                hintText: '${num.prevName()}\n 录音标注...',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrevShotNote extends StatelessWidget {
  PrevShotNote({
    Key? key,
    required this.currentScn,
    required this.currentSht,
    required this.currentTk,
    required this.controller,
  }) : super(key: key);

  final String currentScn;
  final String currentSht;
  final String currentTk;
  String shotNote = '';
  final TextEditingController controller;

//   @override
//   State<PrevShotNote> createState() => _PrevShotNoteState();
// }

// class _PrevShotNoteState extends State<PrevShotNote> {
//   late final TextEditingController noteEditingController;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     noteEditingController = widget.controller;
//   }

  @override
  build(BuildContext context) {
    return Flexible(
      child: ListTileTheme(
        minLeadingWidth: 5,
        child: ListTile(
          title: Row(
            children: [
              const Icon(
                Icons.movie_creation_outlined,
                color: Colors.green,
              ),
              Text(
                  'S$currentScn Sh$currentSht Tk$currentTk'),
            ],
          ),
          subtitle: SizedBox(
            // width: screenWidth * 0.3,
            child: TextField(
              // bind the input to the note variable
              maxLines: 3,
              controller: controller,
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
  }
}

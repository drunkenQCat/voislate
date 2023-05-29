import 'package:flutter/material.dart';
import 'package:voislate/models/recorder_file_num.dart';

class DisplayNotesButton extends StatefulWidget {
  final List<MapEntry<String, String>> notes;
  final RecordFileNum num;

  DisplayNotesButton({
    super.key,
    required this.notes,
    required this.num,
  });

  @override
  State<DisplayNotesButton> createState() => _DisplayNotesButtonState();
}

class _DisplayNotesButtonState extends State<DisplayNotesButton> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.endOfFrame.then((_) {
      controller.jumpTo(controller.position.maxScrollExtent);
    });
  }

  void quickViewLog(
      BuildContext context, List<MapEntry<String, String>> notes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var screenWidth = MediaQuery.of(context).size.width;
        var screenHeight = MediaQuery.of(context).size.height;
        return AlertDialog(
          title: const Text('场记速览'),
          content: SizedBox(
            width: screenWidth * 0.618,
            height: screenHeight * 0.7,
            child: Column(
              children: [
                Container(
                  color: Colors.purple[100],
                  child: itemRow(const MapEntry('File Name', 'Note'), -1),
                ),
                (widget.num.number == 1 || notes.isEmpty)
                    ? const Center(child: Text('尚未开始记录'))
                    : ListView.builder(
                        itemCount: notes.length,
                        controller: controller,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            color: index % 2 == 0
                                ? Colors.white
                                : Colors.grey[200],
                            child: itemRow(notes[index], index),
                          );
                        },
                      ),
                itemRow(
                    MapEntry(widget.num.fullName(), '等待输入...'), notes.length)
              ],
            ),
          ),
        );
      },
    );
  }

  Row itemRow(MapEntry<String, String> note, int index) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              note.key,
              style: TextStyle(
                color: index % 2 == 0 ? Colors.black : Colors.grey[700],
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              note.value,
              style: TextStyle(
                color: index % 2 == 0 ? Colors.black : Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        quickViewLog(context, widget.notes);
      },
      tooltip: 'Quick View Log',
      child: const Icon(Icons.notes),
    );
  }
}

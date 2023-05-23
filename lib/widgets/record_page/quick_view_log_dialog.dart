import 'package:flutter/material.dart';

class DisplayNotesButton extends StatelessWidget {
  // a button to show the notes in a list view
  const DisplayNotesButton({
    super.key,
    required this.notes,
  });

  final List<MapEntry<String, String>> notes;

  void quickViewLog(BuildContext context, List<MapEntry<String, String>> notes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var screenWidth = MediaQuery.of(context).size.width;
        var screenHeight = MediaQuery.of(context).size.height;
        return AlertDialog(
          title: const Text('Notes'),
          content: SizedBox(
            width: screenWidth * 0.618,
            height: screenHeight * 0.7,
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  color: index % 2 == 0 ? Colors.white : Colors.grey[200],
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            notes[index].key,
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
                            notes[index].value,
                            style: TextStyle(
                              color: index % 2 == 0 ? Colors.black : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
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

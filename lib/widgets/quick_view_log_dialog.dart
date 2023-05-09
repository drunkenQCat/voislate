import 'package:flutter/material.dart';

void quickViewLog(BuildContext context, List notes) {
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
      });
}

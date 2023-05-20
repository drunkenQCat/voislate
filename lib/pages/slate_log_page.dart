import 'package:flutter/material.dart';

import '../models/slate_schedule.dart';
import '../models/slate_log_item.dart';
// give me a frame of listview page
class SlateLog extends StatefulWidget {
  const SlateLog({super.key});

  @override
  _SlateLogState createState() => _SlateLogState();
}

class _SlateLogState extends State<SlateLog> {
  List<SlateLogItem> slateLogItems = [
    SlateLogItem(
      scn: 'Scene 1',
      sht: 'Shot 1',
      tk: 1,
      filenamePrefix: 'Prefix 1',
      filenameLinker: 'Linker 1',
      filenameNum: 1,
      tkNote: 'TK Note 1',
      shtNote: 'Shot Note 1',
      scnNote: 'Scene Note 1',
      okTk: TkStatus.ok,
      okSht: ShtStatus.ok,
    ),
    SlateLogItem(
      scn: 'Scene 2',
      sht: 'Shot 2',
      tk: 2,
      filenamePrefix: 'Prefix 2',
      filenameLinker: 'Linker 2',
      filenameNum: 2,
      tkNote: 'TK Note 2',
      shtNote: 'Shot Note 2',
      scnNote: 'Scene Note 2',
      okTk: TkStatus.bad,
      okSht: ShtStatus.nice,
    ),
    SlateLogItem(
      scn: 'Scene 2',
      sht: 'Shot 1',
      tk: 3,
      filenamePrefix: 'Prefix 3',
      filenameLinker: 'Linker 3',
      filenameNum: 3,
      tkNote: 'TK Note 3',
      shtNote: 'Shot Note 3',
      scnNote: 'Scene Note 3',
      okTk: TkStatus.notChecked,
      okSht: ShtStatus.ok,
    ),
  ];

  Set<String> foldedScenes = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: slateLogItems.length,
      itemBuilder: (BuildContext context, int index) {
        SlateLogItem item = slateLogItems[index];
        bool isFolded = foldedScenes.contains(item.scn);

        return Column(
          children: [
            ListTile(
              onTap: () {
                // Toggle the folding state of the scene
                setState(() {
                  if (isFolded) {
                    foldedScenes.remove(item.scn);
                  } else {
                    foldedScenes.add(item.scn);
                  }
                });
              },
              leading: CircleAvatar(
                child: Text(item.tk.toString()),
              ),
              title: RichText(
                text: TextSpan(
                  style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        ),
                  children: [
                    TextSpan(
                      text: item.filenamePrefix,
                    ),
                    TextSpan(text: ' '),
                    TextSpan(text: item.filenameLinker),
                    TextSpan(text: ' '),
                    TextSpan(text: item.filenameNum.toString()),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TK Note: ${item.tkNote}'),
                  Text('Shot Note: ${item.shtNote}'),
                  Text('Scene Note: ${item.scnNote}'),
                ],
              ),
              trailing: Icon(
                _getShtStatusIcon(item.okSht),
                color: _getShtStatusColor(item.okSht),
              ),
            ),
            if (!isFolded)
              Divider(
                thickness: 1.0,
                height: 0.0,
              ),
          ],
        );
      },
    );
  }

  IconData _getShtStatusIcon(ShtStatus status) {
    switch (status) {
      case ShtStatus.notChecked:
        return Icons.check_box_outline_blank;
      case ShtStatus.ok:
        return Icons.check_circle_outline;
      case ShtStatus.nice:
        return Icons.thumb_up_alt_outlined;
      default:
        return Icons.error_outline;
    }
  }

  Color _getShtStatusColor(ShtStatus status) {
    switch (status) {
      case ShtStatus.notChecked:
        return Colors.grey;
      case ShtStatus.ok:
        return Colors.green;
      case ShtStatus.nice:
        return Colors.blue;
      default:
        return Colors.red;
    }
  }
}
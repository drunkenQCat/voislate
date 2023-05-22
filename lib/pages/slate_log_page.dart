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
      filenamePrefix: '230522',
      filenameLinker: '-T',
      filenameNum: 1,
      tkNote: 'TK Note 1',
      shtNote: 'Shot Note 1',
      scnNote: 'Scene Note 1',
      okTk: TkStatus.ok,
      okSht: ShtStatus.ok,
    ),
    SlateLogItem(
      scn: 'Scene 1',
      sht: 'Shot 1',
      tk: 2,
      filenamePrefix: '230522',
      filenameLinker: '-T',
      filenameNum: 2,
      tkNote: 'TK Note 2',
      shtNote: 'Shot Note 2',
      scnNote: 'Scene Note 2',
      okTk: TkStatus.ok,
      okSht: ShtStatus.ok,
    ),
    SlateLogItem(
      scn: 'Scene 1',
      sht: 'Shot 1',
      tk: 3,
      filenamePrefix: '230522',
      filenameLinker: '-T',
      filenameNum: 3,
      tkNote: 'TK Note 3',
      shtNote: 'Shot Note 3',
      scnNote: 'Scene Note 3',
      okTk: TkStatus.ok,
      okSht: ShtStatus.ok,
    ),
    SlateLogItem(
      scn: 'Scene 1',
      sht: 'Shot 2',
      tk: 4,
      filenamePrefix: '230522',
      filenameLinker: '-T',
      filenameNum: 4,
      tkNote: 'TK Note 4',
      shtNote: 'Shot Note 4',
      scnNote: 'Scene Note 4',
      okTk: TkStatus.ok,
      okSht: ShtStatus.ok,
    ),
    SlateLogItem(
      scn: 'Scene 1',
      sht: 'Shot 2',
      tk: 5,
      filenamePrefix: '230522',
      filenameLinker: '-T',
      filenameNum: 5,
      tkNote: 'TK Note 5',
      shtNote: 'Shot Note 5',
      scnNote: 'Scene Note 5',
      okTk: TkStatus.ok,
      okSht: ShtStatus.ok,
    ),
    // Scene 2 Shot2
    SlateLogItem(
      scn: 'Scene 2',
      sht: 'Shot 2',
      tk: 2,
      filenamePrefix: '230522',
      filenameLinker: '-T',
      filenameNum: 2,
      tkNote: 'TK Note 2',
      shtNote: 'Shot Note 2',
      scnNote: 'Scene Note 2',
      okTk: TkStatus.bad,
      okSht: ShtStatus.nice,
    ),
    SlateLogItem(
      scn: 'Scene 2',
      sht: 'Shot 2',
      tk: 3,
      filenamePrefix: '230522',
      filenameLinker: '-T',
      filenameNum: 3,
      tkNote: 'TK Note 3',
      shtNote: 'Shot Note 3',
      scnNote: 'Scene Note 3',
      okTk: TkStatus.bad,
      okSht: ShtStatus.nice,
    ),
    SlateLogItem(
      scn: 'Scene 2',
      sht: 'Shot 2',
      tk: 4,
      filenamePrefix: '230522',
      filenameLinker: '-T',
      filenameNum: 4,
      tkNote: 'TK Note 4',
      shtNote: 'Shot Note 4',
      scnNote: 'Scene Note 4',
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

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, List<SlateLogItem>>> sortedItems = {};

    for (SlateLogItem item in slateLogItems) {
      if (!sortedItems.containsKey(item.scn)) {
        sortedItems[item.scn] = {};
      }
      if (!sortedItems[item.scn]!.containsKey(item.sht)) {
        sortedItems[item.scn]![item.sht] = [];
      }
      sortedItems[item.scn]![item.sht]!.add(item);
    }

    return ListView.builder(
      itemCount: sortedItems.length,
      itemBuilder: (BuildContext context, int index) {
        String scn = sortedItems.keys.elementAt(index);
        Map<String, List<SlateLogItem>> shtItems = sortedItems[scn]!;

        return ExpansionTile(
          initiallyExpanded: true,
          title: Text(scn),
          children: shtItems.keys.map((sht) {
            List<SlateLogItem> items = shtItems[sht]!;

            return ExpansionTile(
              initiallyExpanded: true,
              title: Text(sht),
              children: items.map((item) {
                return Container(
                  color: _getTkStatusColor(item.okTk),
                  child: ListTile(
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
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
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

  Color _getTkStatusColor(TkStatus status) {
    switch (status) {
      case TkStatus.notChecked: // changed enum name to TkStatus.notChecked
        return Colors.grey;
      case TkStatus.ok: // changed enum name to TkStatus.ok
        return Colors.green;
      case TkStatus.bad: // changed enum name to TkStatus.nice
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

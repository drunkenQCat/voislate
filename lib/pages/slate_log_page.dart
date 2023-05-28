import 'package:flutter/material.dart';

import '../models/slate_schedule.dart';
import '../models/slate_log_item.dart';
import '../data/dummy_data.dart';

/* 
TODO：
1. 与record页的数据绑定，最好能自动滚动到selected
*/
class SlateLog extends StatefulWidget {
  const SlateLog({super.key});

  @override
  _SlateLogState createState() => _SlateLogState();
}

class _SlateLogState extends State<SlateLog> {

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
          backgroundColor: Colors.grey,
          initiallyExpanded: true,
          title: Center(child: Text(scn)),
          subtitle: Center(child: Text('场')),
          children: shtItems.keys.map((sht) {
            List<SlateLogItem> items = shtItems[sht]!;

            return ExpansionTile(
              backgroundColor: Colors.grey[200],
              initiallyExpanded: true,
              title: Text(sht),
              subtitle: Text('镜'),
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

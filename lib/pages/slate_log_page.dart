import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:voislate/models/slate_schedule.dart';
import '../models/slate_log_item.dart';
import '../providers/slate_log_notifier.dart';
import '../providers/slate_status_notifier.dart';

/* 
TODO：
1x 与record页的数据绑定，最好能自动滚动到selected
2x 日期的TabView
3. 解决不能自动刷新的bug
*/
// ignore: must_be_immutable
class SlateLog extends StatefulWidget {
  var controller = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: false,
  );
  SlateLog({super.key});

  @override
  _SlateLogState createState() => _SlateLogState();
}

class _SlateLogState extends State<SlateLog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      widget.controller.jumpTo(widget.controller.position.maxScrollExtent);
    });
  }

  Widget build(BuildContext context) {
    return Consumer2<SlateLogNotifier, SlateStatusNotifier>(
      builder: (context, slateLogs, slateStatus, child) {
        Map<String, Map<String, List<SlateLogItem>>> sortedItems = {};
        SceneSchedule currentSceneData = Hive.box('scenes_box')
            .getAt(slateStatus.selectedSceneIndex) as SceneSchedule;
        var currentScn = currentSceneData.info.name;
        var currentShot = currentSceneData[slateStatus.selectedShotIndex].name;

        for (SlateLogItem item in slateLogs.logToday) {
          if (!sortedItems.containsKey(item.scn)) {
            sortedItems[item.scn] = {};
          }
          if (!sortedItems[item.scn]!.containsKey(item.sht)) {
            sortedItems[item.scn]![item.sht] = [];
          }
          sortedItems[item.scn]![item.sht]!.add(item);
        }

        return ListView.builder(
          controller: widget.controller,
          itemCount: sortedItems.length,
          itemBuilder: (BuildContext context, int index) {
            String scn = sortedItems.keys.elementAt(index);
            Map<String, List<SlateLogItem>> shtItems = sortedItems[scn]!;

            return ExpansionTile(
              backgroundColor: Colors.grey,
              initiallyExpanded: (scn == currentScn),
              title: Center(child: Text(scn)),
              subtitle: Center(child: Text('场')),
              children: shtItems.keys.map((sht) {
                List<SlateLogItem> items = shtItems[sht]!;

                return ExpansionTile(
                  backgroundColor: Colors.grey[200],
                  initiallyExpanded: (sht == currentShot),
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

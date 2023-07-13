import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:voislate/models/slate_log_item.dart';

import 'package:voislate/providers/slate_log_notifier.dart';
import 'package:flutter/services.dart';

void quitApp() {
  // Check if the platform is Android or iOS
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}

class SettingsConfiguePage extends StatelessWidget {
  const SettingsConfiguePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text(
        "取消",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () => Navigator.pop(context),
    );

    Widget continueButton = TextButton(
      child: const Text(
        "确认",
      ),
      onPressed: () {
        var logProvider = Provider.of<SlateLogNotifier>(context, listen: false);
        logProvider.clear();
        Navigator.pop(context);
      },
    );

    Widget clearAllConfirmButton = TextButton(
      child: const Text(
        "确认",
      ),
      onPressed: () {
        var logProvider = Provider.of<SlateLogNotifier>(context, listen: false);
        logProvider.clear();
        var dateBox = Hive.box('dates');
        for (String date in dateBox.values.toList().cast()) {
          if (date != logProvider.today) {
            Hive.box<SlateLogItem>(date).close();
            Hive.box<SlateLogItem>(date).deleteFromDisk();
          }
        }
        // if dates are more than one, delete all except the last one(today)
        dateBox.clear();
        dateBox.put(logProvider.today, logProvider.today);
        quitApp();
        Navigator.pop(context);
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiSlate 设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const ListTile(
            leading: Text('工程名'),
            title: TextField(
              decoration: InputDecoration(),
            ),
          ),
          ListTile(
            title: const Text('操作模式'),
            trailing: DropdownButton<String>(
              value: '左手',
              onChanged: (newValue) {},
              items: <String>['左手', '右手', '中间']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SwitchListTile(
            title: const Text('音量键控制'),
            value: true,
            onChanged: (bool value) {},
          ),
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('清除场记'),
                        content: const Text('是否确认要清除场记？'),
                        actions: [
                          cancelButton,
                          continueButton,
                        ],
                      );
                    });
              },
              child: const Text(
                '清空今日场记',
                style: TextStyle(color: Colors.red),
              )),
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('清除场记'),
                        content: const Text('是否确认要清除场记？'),
                        actions: [
                          cancelButton,
                          clearAllConfirmButton,
                        ],
                      );
                    });
              },
              child: const Text(
                '清空所有场记',
                style: TextStyle(color: Colors.red),
              ))
        ],
      ),
    );
  }
}

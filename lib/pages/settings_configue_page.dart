import 'package:flutter/material.dart';

class SettingsConfiguePage extends StatelessWidget {
  const SettingsConfiguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiSlate 设置'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
            title: Text('操作模式'),
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
        ],
      ),
    );
  }
}

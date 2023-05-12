import 'package:flutter/material.dart';

import 'scene_schedule_page.dart';
import 'record_page.dart';
import 'slate_log_page.dart';

class VoiSlate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voislate',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Voislate Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, this.title = "No Title"}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
          tabs: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('计划'),
                SizedBox(width: 5),
                Icon(Icons.edit_calendar_outlined),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('记录'),
                SizedBox(width: 5),
                Icon(Icons.record_voice_over_outlined),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('场记'),
                SizedBox(width: 5),
                Icon(Icons.format_list_bulleted_outlined),
              ],
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SceneSchedule(),
          const SlateRecord(),
          SlateLog(),
        ],
      ),
    );
  }
}
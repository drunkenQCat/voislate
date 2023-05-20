import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/main_page.dart';
import 'models/slate_schedule.dart';
import 'data/dummy_scenes.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(ScheduleItemAdapter());
  Hive.registerAdapter(DataListAdapter());
  Hive.registerAdapter(SceneScheduleAdapter());
  
  await Hive.openBox('scenes_box');
  if (Hive.box('scenes_box').isEmpty) {
    Hive.box('scenes_box').addAll([sceneSchedule, scene2ASchedule]);
  }
  runApp(const VoiSlate());
}

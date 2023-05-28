import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/main_page.dart';
import 'models/slate_schedule.dart';
import 'data/dummy_data.dart';
import 'models/recorder_file_num.dart';

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
  await Hive.openBox('scn_sht_tk');
  await Hive.openBox('dates');
  var today = RecordFileNum.today;

  // if today is not in the dates box, add it
  if (Hive.box('dates').isEmpty) {
    Hive.box('dates').add(today);
  }
  var lastDayIndex = Hive.box('dates').length - 1;
  if (!Hive.box('dates').containsKey(today)) {
    Hive.box('dates').putAt(lastDayIndex, today);
  }

  var dates = Hive.box('dates').values as List<String>;
  for (var date in dates) {
    await Hive.openBox(date);
  }
  // the slate log of today 
  runApp(const VoiSlate());
}

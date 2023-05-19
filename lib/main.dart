import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/main_page.dart';
void main() async{
  await Hive.initFlutter();
  runApp(VoiSlate());
}

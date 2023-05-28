import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'recorder_file_num.dart';

class SlateStatusNotifier extends ChangeNotifier {
  int _selectedSceneIndex =
      Hive.box('scn_sht_tk').get('scnIndex', defaultValue: 0) as int;
  int _selectedShotIndex =
      Hive.box('scn_sht_tk').get('shtIndex', defaultValue: 0) as int;
  int _selectedTakeIndex =
      Hive.box('scn_sht_tk').get('tkIndex', defaultValue: 0) as int;
  bool _isLinked =
      Hive.box('scn_sht_tk').get('isLinked', defaultValue: true) as bool;
  String _date =
      Hive.box('scn_sht_tk').get('date', defaultValue: RecordFileNum.today) as String;
  int _recordCount = 
      (RecordFileNum.today == Hive.box('scn_sht_tk').get('date', defaultValue: '0') as String) 
      ? Hive.box('scn_sht_tk').get('recordCount', defaultValue: 1) as int
      : 1;

  int get selectedSceneIndex => _selectedSceneIndex;
  int get selectedShotIndex => _selectedShotIndex;
  int get selectedTakeIndex => _selectedTakeIndex;
  bool get isLinked => _isLinked;
  String get date => _date;
  int get recordCount => _recordCount;

  void setIndex({int? scene, int? shot, int? take, int? count}) {
    if (scene != null) {
      _selectedSceneIndex = scene;
      Hive.box('scn_sht_tk').put('scnIndex', _selectedSceneIndex);
    }
    if (shot != null) {
      _selectedShotIndex = shot;
      Hive.box('scn_sht_tk').put('shtIndex', _selectedShotIndex);
    }
    if (take != null) {
      _selectedTakeIndex = take;
      Hive.box('scn_sht_tk').put('tkIndex', _selectedTakeIndex);
    }
    if (count != null) {
      _recordCount = count;
      Hive.box('scn_sht_tk').put('recordCount', _recordCount);
    }
    Hive.box('scn_sht_tk').put('date', RecordFileNum.today);
    notifyListeners();
  }

  void setLink(bool link) {
    Hive.box('scn_sht_tk').put('isLinked', link);
    notifyListeners();
  }
}

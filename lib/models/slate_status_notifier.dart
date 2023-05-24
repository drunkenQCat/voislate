import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SlateStatusNotifier extends ChangeNotifier {
  int _selectedSceneIndex =
      Hive.box('scn_sht_tk').get('scnIndex', defaultValue: 0) as int;
  int _selectedShotIndex =
      Hive.box('scn_sht_tk').get('shtIndex', defaultValue: 0) as int;
  int _selectedTakeIndex =
      Hive.box('scn_sht_tk').get('tkIndex', defaultValue: 0) as int;
  bool _isLinked =
      Hive.box('scn_sht_tk').get('isLinked', defaultValue: true) as bool;

  int get selectedSceneIndex => _selectedSceneIndex;
  int get selectedShotIndex => _selectedShotIndex;
  int get selectedTakeIndex => _selectedTakeIndex;
  bool get isLinked => _isLinked;

  void setIndex({int? scene, int? shot, int? take}) {
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
    notifyListeners();
  }

  void setLink(bool link) {
    Hive.box('scn_sht_tk').put('isLinked', link);
    notifyListeners();
  }
}

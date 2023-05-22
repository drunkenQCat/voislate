import 'package:flutter/material.dart';

class SceneScheduleModel extends ChangeNotifier {
  int _selectedSceneIndex = 0;
  int _selectedShotIndex = 0;
  int _selectedTakeIndex = 0;

  int get selectedSceneIndex => _selectedSceneIndex;
  int get selectedShotIndex => _selectedShotIndex;
  int get selectedTakeIndex => _selectedTakeIndex;

  void setIndex({int? scene, int? shot, int? take}) {
    _selectedSceneIndex = scene??_selectedSceneIndex;
    _selectedShotIndex = shot??_selectedShotIndex;
    _selectedTakeIndex = take??_selectedTakeIndex;
    notifyListeners();
  }
}

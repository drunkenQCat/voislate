import 'package:flutter/material.dart';

class SceneScheduleModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int _selectedShotIndex = 0;
  int _selectedTakeIndex = 0;

  int get selectedIndex => _selectedIndex;
  int get selectedShotIndex => _selectedShotIndex;
  int get selectedTakeIndex => _selectedTakeIndex;

  void setIndex(int index, int shotIndex, int takeIndex) {
    _selectedIndex = index;
    _selectedShotIndex = shotIndex;
    _selectedTakeIndex = takeIndex;
    notifyListeners();
  }
}

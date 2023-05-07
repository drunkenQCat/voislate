// change notifier model to change the numList value
import 'package:flutter/material.dart';

class SlateNumNotifier extends ChangeNotifier {
  // selected is the value on the picker now, numList is the list of the picker
  var selected;
  var _numList = List.generate(8, (index) => index.toString());
  String? scrollToValue;
  // getter of the _numList
  List<String> get numList => _numList;
  set numList(List<String> value) {
    _numList = value;
    notifyListeners();
  }

  void removeItem(value){
    _numList.remove(value);
    notifyListeners();
  }

  // a function to change the selected value
  void nextOrPre([ bool addOrSub = true ]) {
    var index = _numList.indexOf(selected);
    if (addOrSub) {
      index++;
    } else {
      index--;
    }
    selected = _numList[index];
    notifyListeners();
  }

  void scrollSelectedTo(String value) {
    scrollToValue = value;
    notifyListeners();
  }
}

class SlateColumnOne extends SlateNumNotifier {}
class SlateColumnTwo extends SlateNumNotifier {}
class SlateColumnThree extends SlateNumNotifier {}
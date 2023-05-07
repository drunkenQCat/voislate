// change notifier model to change the numList value
import 'package:flutter/material.dart';

class SlatePickerState with ChangeNotifier {
  late FixedExtentScrollController controller;
  var _selected;
  var numList;
  // getter and setter to _selected
  get selected => _selected;
  set selected(value) {
    _selected = value;
    notifyListeners();
  }

  void init([ List<String> inputList = const ['1', '2', '3', '4', '5', '6', '7', '8'], int initialIndex = 0 ]) {
    controller = FixedExtentScrollController(initialItem: initialIndex);
    numList = inputList;
    _selected = inputList[initialIndex];
  }

  void scrollSelectedTo(String value) {
    var index = numList.indexOf(value);
    controller.animateToItem(index, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    selected = value;
    notifyListeners();
  }
  
  void scrollToNext() {
    var index = numList.indexOf(selected);
    index++;
    if (index >= numList.length) {
      index = 0;
    }
    scrollSelectedTo(numList[index]);
  }

  void scrollToPrev(){
    var index = numList.indexOf(selected);
    index--;
    if (index < 0) {
      index = numList.length - 1;
    }
    scrollSelectedTo(numList[index]);
  }
}
class SlateColumnOne extends SlatePickerState {}
class SlateColumnTwo extends SlatePickerState {}
class SlateColumnThree extends SlatePickerState {}




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

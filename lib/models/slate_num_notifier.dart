// change notifier model to change the numList value
import 'package:flutter/material.dart';

abstract class SlatePickerState with ChangeNotifier {
  late FixedExtentScrollController controller;
  var _selected;
  var _numList;
  get selectedIndex => numList.indexOf(selected);
  // getter and setter to _selected
  get selected => _selected;
  set selected(value) {
    _selected = value;
    notifyListeners();
  }
  get numList => _numList;
  set numList(value) {
    _numList = value;
    // 检测numlist里边有没有重复的元素
    var set = Set<String>.from(value);
    if (set.length != value.length) {
      throw Exception('numList has duplicate elements');
    }
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
  
  void scrollToNext(bool isLink) {
    if(selected == numList.last) return;

    var index = numList.indexOf(selected);
    index++;
    if (index >= numList.length) {
      index = 0;
    }
    if (isLink) scrollSelectedTo(numList[index]);
  }

  void scrollToPrev(bool isLink){
    if (selected == numList.first) return;

    var index = numList.indexOf(selected);
    index--;
    if (index < 0) {
      index = numList.length - 1;
    }
    if (isLink) scrollSelectedTo(numList[index]);
  }
}
class SlateColumnOne extends SlatePickerState {}
class SlateColumnTwo extends SlatePickerState {}
class SlateColumnThree extends SlatePickerState {
  @override
  void init([ List<String> inputList = const ['1', '2', '3', '4', '5', '6', '7', '8'], int initialIndex = 0 ]) {
    super.init(inputList, initialIndex);
  }
}
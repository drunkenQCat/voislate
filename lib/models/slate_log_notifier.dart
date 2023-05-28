import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:voislate/models/slate_log_item.dart';
import 'recorder_file_num.dart';

class SlateLogNotifier with ChangeNotifier  {
  var dates = Hive.box('dates').values as List<String>;
  var today = RecordFileNum.today;
  late Box<SlateLogItem> logBox;
  late List<SlateLogItem> logToday ;

  SlateLogNotifier() {
    logBox = Hive.box(today);
    logToday = logBox.values as List<SlateLogItem>;
  }

  void add(SlateLogItem item) {
    logToday.add(item);
    logBox.add(item);
    notifyListeners();
  }

  void removeLast(){
    logToday.removeLast();
    logBox.deleteAt(logBox.length - 1);
    notifyListeners();
  }

  void removeAt(int index){
    logToday.removeAt(index);
    logBox.deleteAt(index);
    notifyListeners();
  }

  void clear() {
    logToday.clear();
    logBox.clear();
    notifyListeners();
  }

  get length => logToday.length;

  operator [](int index) => logToday[index];

  operator []=(int index, SlateLogItem item) {
    logToday[index] = item;
    logBox.putAt(index, item);
    notifyListeners();
  }
}


// the template of the schedule items
import 'package:flutter/material.dart';

class ScheduleItem{
  final String key;
  final String fix;
  final String name;
  final Note note;
  // constructor
  ScheduleItem(this.key, this.fix, this.note):name = key + fix;
}

class Note {
  late List<String> objects;
  late String type;
  final String append;
  //constructor
  Note({ required this.objects, required this.type, required this.append });
  @override
  String toString() {
    // concatenate the objects list into a string
    String objectsString = objects.join(', ');
    return 'Note{objects: $objectsString, type: $type, append: $append}';
  }
}
// this abstract class is used to store the data of the schedule, literally a list of schedule items
class DataList extends ChangeNotifier{
  late List<ScheduleItem> _data;
  List<ScheduleItem> get data => _data;
  set data(List<ScheduleItem> data){
    // detect that if the _data has duplicate items
    // if it does, throw an error
    var set = <String>{};
    for (var item in data) {
      if (set.contains(item.name)) {
        throw Exception('Duplicate items in the list');
      }
      set.add(item.name);
    }
    _data = data;
    refresh();
  }

  get length {
    return _data.length;}


  void add(ScheduleItem item, [ ShotSchedule? shots ]){
    _data.add(item);
    refresh();
  }

  void remove(ScheduleItem item){
    _data.remove(item);
    refresh();
  }

  ScheduleItem removeAt(int index){
    var removed = _data.removeAt(index);
    refresh();
    return removed;
  }

  void insert(int index, ScheduleItem item, [ ShotSchedule? shots ]){
    _data.insert(index, item);
    refresh();
  }

  void update(ScheduleItem oldItem, ScheduleItem newItem){
    int index = _data.indexWhere((element) => element.key == oldItem.key);
    _data[index] = newItem;
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}

class ShotSchedule extends DataList{
  ScheduleItem operator [](int index) => data[index];
  ShotSchedule(List<ScheduleItem> inputList){
    data = inputList;
  }

}

class SceneSchedule extends DataList{
  Map<String, ShotSchedule> shotScheduleMap = {};

  ShotSchedule operator [](int index){
    return shotScheduleMap[_data[index].name]!;
  }

  SceneSchedule({ required List<ScheduleItem> list, required List<ShotSchedule> shots }){
    data = list;
    assert(shots.length == list.length);
    var _ = shots;
    // map data to _
    for (var item in data) {
      // just pop the data out 
      var currentScene = _.removeAt(0);
      shotScheduleMap[item.name] = currentScene;
    }
  }
  @override
  void add(ScheduleItem item, [ShotSchedule? shots]) {
    shotScheduleMap[item.name] = shots!;
    super.add(item);
  }

  @override
  void remove(ScheduleItem item) {
    shotScheduleMap.remove(item.name);
    super.remove(item);
  }

  @override
  ScheduleItem removeAt(int index){
    var removed = super.removeAt(index);
    shotScheduleMap.remove(removed);
    return removed;

  }

  @override
  void insert(int index, ScheduleItem item, [ ShotSchedule? shots ]){
    shotScheduleMap[item.name] = shots!;
    super.insert(index, item);
  }

  @override
  void update(ScheduleItem oldItem, ScheduleItem newItem,[ ShotSchedule? shots ]) {
    shotScheduleMap[newItem.name] = shots!;
    shotScheduleMap.remove(oldItem.name);
    super.update(oldItem, newItem);
  }
}


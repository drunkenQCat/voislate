
// the template of the schedule items
import 'package:flutter/material.dart';

class ScheduleItem{
  final String key;
  final String fix;
  final Note note;
  // constructor
  ScheduleItem(this.key, this.fix, this.note);
}

class Note {
  late List<String> objects;
  late String type;
  final String append;
  //constructor
  Note({ required this.objects, required this.type, required this.append });
}
// this abstract class is used to store the data of the schedule, literally a list of schedule items
abstract class DataList with ChangeNotifier{
  late List<ScheduleItem> _data;
  List<ScheduleItem> get data => _data;
  set data(List<ScheduleItem> data){
    _data = data;
    refresh();
  }

  void add(ScheduleItem item){
    _data.add(item);
    refresh();
  }

  void remove(ScheduleItem item){
    _data.remove(item);
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

class SceneSchedule extends DataList{
  List<ShotSchedule> _ = [];
  Map<String, ShotSchedule> shotScheduleMap = {};

  SceneSchedule({ required List<ScheduleItem> list, required List<ShotSchedule> shots }){
    _data = list;
    assert(shots.length == list.length);
    _ = shots;
    // map data to _
    for (var item in _data) {
      // just pop the data out 
      var currentScene = _.removeAt(0);
      shotScheduleMap[item.key] = currentScene;
    }
    @override
    void add(ScheduleItem item) {
      shotScheduleMap[item.key] = ShotSchedule([]);
      super.add(item);
    }

    @override
    void remove(ScheduleItem item) {
      shotScheduleMap.remove(item.key);
      super.remove(item);
    }

    @override
    void update(ScheduleItem oldItem, ScheduleItem newItem) {
      shotScheduleMap[newItem.key] = shotScheduleMap[oldItem.key]!;
      shotScheduleMap.remove(oldItem.key);
      super.update(oldItem, newItem);
    }
  }
}

class ShotSchedule extends DataList{
  ShotSchedule(List<ScheduleItem> inputList){
    _data = inputList;
  }
}

// make an instance of SceneSchedule
// create a list of ScheduleItem objects
List<ScheduleItem> scheduleItems = [
  ScheduleItem('1', 'fix1', Note(objects: ['object1', 'Hero', 'Crowd'], type: 'type1', append: 'append1')),
  ScheduleItem('2', 'fix2', Note(objects: ['object2'], type: 'type2', append: 'append2')),
  ScheduleItem('3', 'fix3', Note(objects: ['object3'], type: 'type3', append: 'append3')),
];

// create a list of ShotSchedule objects
List<ShotSchedule> shotSchedules = [
  ShotSchedule([ScheduleItem('4', 'fix4', Note(objects: ['object4'], type: 'type4', append: 'append4'))]),
  ShotSchedule([ScheduleItem('5', 'fix5', Note(objects: ['object5'], type: 'type5', append: 'append5'))]),
  ShotSchedule([ScheduleItem('6', 'fix6', Note(objects: ['object6'], type: 'type6', append: 'append6'))]),
];

// create a SceneSchedule object
SceneSchedule sceneSchedule = SceneSchedule(list: scheduleItems, shots: shotSchedules);

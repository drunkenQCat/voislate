
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
// Dismissible(
//   key: Key(item.id),
//   onDismissed: (direction) {
//     // 在滑动时执行操作
//   },
//   child: ListTile(
//     title: Text(item.title),
//     subtitle: Text(item.subtitle),
//     leading: Icon(Icons.delete),
//   ),
// )

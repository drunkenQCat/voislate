import 'package:flutter/material.dart';
import '../models/slate_schedule.dart';

class SceneSchedulePage extends StatefulWidget {
  @override
  _SceneSchedulePageState createState() => _SceneSchedulePageState();
}


/*
接下来的这一页的规划：
1. 一个左边的列表，右边的详情
2. 左边的列表可以滑动，右边的详情可以滑动
3. 撤回/重做按钮
4. BottomSheet，可以编辑/删除/添加，添加的时候可以选择是添加到上边还是下边
5. 悬浮的录音识别按钮，可以语音快速创建计划
6. 上面的语音识别按钮，还是要暂时用输入框代替
7. listtile 感觉很适合做右边表格的样式
*/
class _SceneSchedulePageState extends State<SceneSchedulePage> {
  int _selectedIndex = 0;

  
  final SceneSchedule sceneSchedule = SceneSchedule(
    list: [
      ScheduleItem('1', 'Fix 1', Note(objects: ['Object 1'], type: 'Type 1', append: 'Append 1')),
      ScheduleItem('2', 'Fix 2', Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2')),
      ScheduleItem('3', 'Fix 3', Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3')),
    ],
    shots: [
      ShotSchedule([
        ScheduleItem('1', 'Fix 1', Note(objects: ['Object 1'], type: 'Type 1', append: 'Append 1')),
        ScheduleItem('2', 'Fix 2', Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2')),
        ScheduleItem('3', 'Fix 3', Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3')),
        ScheduleItem('4', 'Fix 4', Note(objects: ['Object 4'], type: 'Type 4', append: 'Append 4')),
        ScheduleItem('5', 'Fix 5', Note(objects: ['Object 5'], type: 'Type 5', append: 'Append 5')),
        
        ]),
      ShotSchedule([
        ScheduleItem('2', 'Fix 2', Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2')),
        ScheduleItem('6', 'Fix 6', Note(objects: ['Object 6'], type: 'Type 6', append: 'Append 6')),
        ScheduleItem('7', 'Fix 7', Note(objects: ['Object 7'], type: 'Type 7', append: 'Append 7')),
        ScheduleItem('8', 'Fix 8', Note(objects: ['Object 8'], type: 'Type 8', append: 'Append 8')),
        ScheduleItem('9', 'Fix 9', Note(objects: ['Object 9'], type: 'Type 9', append: 'Append 9')),
        ]),
      ShotSchedule([
        ScheduleItem('3', 'Fix 3', Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3')),
        ScheduleItem('10', 'Fix 10', Note(objects: ['Object 10'], type: 'Type 10', append: 'Append 10')),
        ScheduleItem('11', 'Fix 11', Note(objects: ['Object 11'], type: 'Type 11', append: 'Append 11')),
        ScheduleItem('12', 'Fix 12', Note(objects: ['Object 12'], type: 'Type 12', append: 'Append 12')),
        ScheduleItem('13', 'Fix 13', Note(objects: ['Object 13'], type: 'Type 13', append: 'Append 13')),
        ScheduleItem('14', 'Fix 14', Note(objects: ['Object 14'], type: 'Type 14', append: 'Append 14')),
        ]),
    ],
  );

  final _items = List<String>.generate(20, (i) => 'Item ${i + 1}');
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: sceneSchedule.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key:Key(sceneSchedule[index].key + sceneSchedule[index].fix),
                onDismissed: (direction) => setState(() {
                  
                  if(direction == DismissDirection.endToStart){
                    sceneSchedule.removeAt(index);
                  }else if(direction == DismissDirection.startToEnd){
                    sceneSchedule.removeAt(index);
                    _showModalBottomSheet(context);
                  }
                }),
                secondaryBackground: Container(
                  color: Colors.red,
                  child: const Icon(Icons.delete),
                ),
                background: Container(
                  color: Colors.green,
                  child: const Icon(Icons.edit),
                ),
                child: ListTile(
                  title: Text(_items[index]),
                  selected: index == _selectedIndex,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: Text(
                _items[_selectedIndex],
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void _showModalBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 200,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Modal BottomSheet'),
              ElevatedButton(
                child: const Text('Close BottomSheet'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      );
    },
  );
}

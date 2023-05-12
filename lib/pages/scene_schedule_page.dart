import 'package:flutter/material.dart';
import '../models/slate_schedule.dart';

class SceneSchedule extends StatefulWidget {
  @override
  _SceneScheduleState createState() => _SceneScheduleState();
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
class _SceneScheduleState extends State<SceneSchedule> {
  int _selectedIndex = 0;

  // final SceneSchedule sceneSchedule = SceneSchedule(
  //   list: [
  //     ScheduleItem('1', 'Fix 1', Note(objects: ['Object 1'], type: 'Type 1', append: 'Append 1')),
  //     ScheduleItem('2', 'Fix 2', Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2')),
  //     ScheduleItem('3', 'Fix 3', Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3')),
  //   ],
  //   shots: [
  //     ShotSchedule([ScheduleItem('1', 'Fix 1', Note(objects: ['Object 1'], type: 'Type 1', append: 'Append 1'))]),
  //     ShotSchedule([ScheduleItem('2', 'Fix 2', Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2'))]),
  //     ShotSchedule([ScheduleItem('3', 'Fix 3', Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3'))]),
  //   ],
  // );

  final _items = List<String>.generate(20, (i) => 'Item ${i + 1}');
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key:Key(_items[index]),
                onDismissed: (direction) => setState(() {
                  
                  if(direction == DismissDirection.endToStart){
                    _items.removeAt(index);
                  }else if(direction == DismissDirection.startToEnd){
                    _items.removeAt(index);
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

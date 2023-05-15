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
  int _selectedShotIndex = 0;

  final SceneSchedule scenes = SceneSchedule(
    list: [
      ScheduleItem('1', 'A',
          Note(objects: ['Object 1'], type: 'Type 1', append: 'Append 1')),
      ScheduleItem('2', 'A',
          Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2')),
      ScheduleItem('3', 'A',
          Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3')),
    ],
    shots: [
      ShotSchedule([
        ScheduleItem('1', 'A',
            Note(objects: ['Object 1'], type: 'Type 1', append: 'Append 1')),
        ScheduleItem('2', 'A',
            Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2')),
        ScheduleItem('3', 'A',
            Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3')),
        ScheduleItem('4', 'A',
            Note(objects: ['Object 4'], type: 'Type 4', append: 'Append 4')),
        ScheduleItem('5', 'A',
            Note(objects: ['Object 5'], type: 'Type 5', append: 'Append 5')),
      ]),
      ShotSchedule([
        ScheduleItem('2', 'A',
            Note(objects: ['Object 2'], type: 'Type 2', append: 'Append 2')),
        ScheduleItem('6', 'A',
            Note(objects: ['Object 6'], type: 'Type 6', append: 'Append 6')),
        ScheduleItem('7', 'A',
            Note(objects: ['Object 7'], type: 'Type 7', append: 'Append 7')),
        ScheduleItem('8', 'A',
            Note(objects: ['Object 8'], type: 'Type 8', append: 'Append 8')),
        ScheduleItem('9', 'A',
            Note(objects: ['Object 9'], type: 'Type 9', append: 'Append 9')),
      ]),
      ShotSchedule([
        ScheduleItem('3', 'A',
            Note(objects: ['Object 3'], type: 'Type 3', append: 'Append 3')),
        ScheduleItem('10', 'A',
            Note(objects: ['Object 10'], type: 'Type 10', append: 'Append 10')),
        ScheduleItem('11', 'A',
            Note(objects: ['Object 11'], type: 'Type 11', append: 'Append 11')),
        ScheduleItem('12', 'A',
            Note(objects: ['Object 12'], type: 'Type 12', append: 'Append 12')),
        ScheduleItem('13', 'A',
            Note(objects: ['Object 13'], type: 'Type 13', append: 'Append 13')),
        ScheduleItem('14', 'A',
            Note(objects: ['Object 14'], type: 'Type 14', append: 'Append 14')),
      ]),
    ],
  );

  @override
  Widget build(BuildContext context) {
    var leftWidth = MediaQuery.of(context).size.width * 0.3;
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: ListView.separated(
            itemCount: scenes.length,
            separatorBuilder: (context, index) {
              return const Divider(
                height: 1,
                color: Colors.grey,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              return leftList(index, context);
            },
          ),
        ),
        Flexible(
          // a copy of listview above , but to display the shot schedule
          flex: 3,
          child: ListView.builder(
            itemCount: scenes[_selectedIndex].length,
            itemBuilder: (BuildContext context, int index2) {
              return rightList(index2, context);
            },
          ),
        ),
      ],
    );
  }

  Dismissible rightList(int index, BuildContext context) {
    var itemGroup = scenes[_selectedIndex];
    var item = itemGroup[index];

    return Dismissible(
      key: Key(item.name),
      onDismissed: (direction) => setState(() {
        if (direction == DismissDirection.endToStart) {
          removeItem(index, context);
        }
      }),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          _showModalBottomSheet(context);
          return false;
        }
        return null;
      },
      secondaryBackground: Container(
        color: Colors.red,
        child: const Icon(Icons.delete),
      ),
      background: Container(
        color: Colors.green,
        child: const Icon(Icons.edit),
      ),
      child: LongPressDraggable(
        data: item,
        feedback: ListTile(
          title: Text(item.name),
          subtitle: Text(item.note.type),
          focusColor: Colors.amber,
          selected: index == _selectedShotIndex,
          onTap: () {
            setState(() {
              _selectedShotIndex = index;
            });
          },
        ),
        childWhenDragging: Container(),
        child: ListTile(
          title: Text(item.name),
          subtitle: Text(item.note.toString()),
          selected: index == _selectedShotIndex,
          onTap: () {
            setState(() {
              _selectedShotIndex = index;
            });
          },
        ),
      ),
    );
  }

  Dismissible leftList(int index, BuildContext context) {
    var item = scenes[index];
    return Dismissible(
      key: Key(scenes.data[index].name),
      onDismissed: (direction) => setState(() {
        if (direction == DismissDirection.endToStart) {
          removeItem(index, context, item);
        }
      }),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          _showModalBottomSheet(context);
          return false;
        }
        return null;
      },
      secondaryBackground: Container(
        color: Colors.red,
        child: const Icon(Icons.delete),
      ),
      background: Container(
        color: Colors.green,
        child: const Icon(Icons.edit),
      ),
      child: LongPressDraggable(
        data: scenes,
        feedback: ListTile(
          leading: CircleAvatar(
            child: Text(scenes.data[index].name
          ),),
          focusColor: Colors.amber,
          selected: index == _selectedIndex,
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        childWhenDragging: Container(),
        child: ListTile(
          leading: Column(
            children: [
              CircleAvatar(
                child: Text(scenes.data[index].name),
              ),
              Text(scenes.data[index].note.type),
            ],
          ),
          selected: index == _selectedIndex,
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  void removeItem(int index, BuildContext context, [ShotSchedule? item]) {
    // if modify shot schedule, item is null
    if (item != null) {
      var removed = scenes.removeAt(index);
      _selectedIndex = (index - 1 < 0) ? 0 : index - 1;
      _selectedShotIndex = 0;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${removed.name} dismissed'),
          action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                scenes.insert(index, removed, item);
              })));
    } else {
      var removed = scenes[_selectedIndex].removeAt(index);
      // if remove the last item, _selectedShotIndex will be -1
      _selectedShotIndex = (index - 1 < 0) ? 0 : index - 1;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${removed.name} dismissed'),
          action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                scenes[_selectedShotIndex].insert(index, removed);
              })));
    }
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

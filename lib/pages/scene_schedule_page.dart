
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/slate_schedule.dart';

class SceneSchedulePage extends StatefulWidget {

  @override
  _SceneSchedulePageState createState() => _SceneSchedulePageState();
}

/*
接下来的这一页的规划：
1x 一个左边的列表，右边的详情
2. 左边的列表可以滑动，右边的详情可以滑动
3. 撤回/重做按钮
4. BottomSheet，可以编辑/删除/添加，添加的时候可以选择是添加到上边还是下边
5. 悬浮的录音识别按钮，可以语音快速创建计划
6. 上面的语音识别按钮，还是要暂时用输入框代替
7. listtile 感觉很适合做右边表格的样式
郑老师对于“计划”的更具体的建议：
1. 可以考虑导入Excel分镜表
2. 以及每日通告
3. 自动化的计划生成，比如说，可以根据每日通告自动生成多日计划
4. 话筒信息可以根据通告自动生成
5. 可以考虑火星大数据的接入 
*/
class _SceneSchedulePageState extends State<SceneSchedulePage> {
  int _selectedIndex = 0;
  int _selectedShotIndex = 0;
 
  List<SceneSchedule> scenes = [];

  @override
  void initState() {
    super.initState();
    var sBox = Hive.box('scenes_box');
    scenes = sBox.values.toList().cast<SceneSchedule>();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: ReorderableListView.builder(
          // 左边的列表
          itemCount: scenes.length,
          // itemCount: 2,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              var shots = scenes[oldIndex];
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              scenes.removeAt(oldIndex);
              // int index = newIndex > oldIndex ? newIndex - 1 : newIndex;
              scenes.insert(newIndex, shots);
              // make the selected item to be the dragged item
            });
            _selectedIndex = newIndex;
          },
          itemBuilder: (BuildContext context, int index) {
            return ReorderableDelayedDragStartListener(
                key: ValueKey('Scene$index'),
                index: index,
                child: leftList(index, context));
          },
          ),
        ),
        Flexible(
          flex: 3,
          child: Column(
            children: [
              ListTile(
                // 用来显示场的基本信息，作为接下来创建的镜的计划
                tileColor: Colors.purple[50],
                title: Text(scenes[_selectedIndex][_selectedShotIndex].name),
                subtitle: Text(scenes[_selectedIndex][_selectedShotIndex].note.type),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  // 右边的列表
                  itemCount: scenes[_selectedIndex].length,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = scenes[_selectedIndex].removeAt(oldIndex);
                      // int index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                      scenes[_selectedIndex].insert(newIndex, item);
                      // make the selected item to be the dragged item
                    });
                    _selectedShotIndex = newIndex;
                  },
                  itemBuilder: (BuildContext context, int index2) {
                    return ReorderableDelayedDragStartListener(
                        key: ValueKey(scenes[_selectedIndex][index2].name),
                        index: index2,
                        child: rightList(index2, context));
                  },
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      color: Colors.transparent,
                      child: child,
                      elevation: 10.0,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Dismissible leftList(int index, BuildContext context) {
    return Dismissible(
      key: Key(scenes[index].info.name),
      onDismissed: (direction) => setState(() {
        if (direction == DismissDirection.endToStart) {
          removeItem(context, index);
        }
      }),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          _editNote(context, index);
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
      child: ListTileTheme(
        contentPadding: const EdgeInsets.all(5),
        selectedColor: const Color(0xFF212121),
        selectedTileColor: const Color(0xFFD1C4E9),
        child: ListTile(
          leading: Column(
            children: [
              CircleAvatar(
                child: Text(
                  scenes[index].info.name,
                ),
              ),
              Text(
                scenes[index].info.note.type,
                style: const TextStyle(fontSize: 10),
              ),
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

  Dismissible rightList(int index, BuildContext context) {
    var itemGroup = scenes[_selectedIndex];
    var item = itemGroup[index];

    return Dismissible(
      key: Key(item.name),
      onDismissed: (direction) => setState(() {
        if (direction == DismissDirection.endToStart) {
          removeItem(context, _selectedIndex, index);
        }
      }),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          _editNote(context, _selectedIndex, index);
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
      child: ListTileTheme(
        tileColor: Colors.white,
        selectedTileColor: const Color(0xFFE0E0E0),
        child: ListTile(
          leading: CircleAvatar(child: Text(item.name)),
          title: Text(
              '${item.note.type},${item.note.objects},${item.note.append}'),
          subtitle: Text(item.note.objects.toString()),
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

  void removeItem(BuildContext context, int sceneIndex, [int? shotIndex]) {
    // if modify shot schedule, item is null
    if (shotIndex == null) {
      var removed = scenes.removeAt(sceneIndex);
      _selectedIndex = (sceneIndex - 1 < 0) ? 0 : sceneIndex - 1;
      _selectedShotIndex = 0;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${removed.info.name} dismissed'),
          action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                scenes.insert(sceneIndex, removed);
              })));
    }else{
      var removed = scenes[_selectedIndex].removeAt(shotIndex);
      // if remove the last item, _selectedShotIndex will be -1
      _selectedShotIndex = (shotIndex - 1 < 0) ? 0 : shotIndex - 1;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${removed.name} dismissed'),
          action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                scenes[_selectedShotIndex].insert(shotIndex, removed);
              })));
    }
  }

  void _editNote(BuildContext context, int index, [int? shotIndex]) async {
    // if shotIndex is null, edit scene note
    Note note = (shotIndex == null) ? 
                scenes[index].info.note : 
                scenes[index][shotIndex].note;
    List<String> editedObjects = List.from(note.objects);
    String editedType = note.type;
    String editedAppend = note.append;

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void _updateObjects(List<String> newObjects) {
              setState(() {
                editedObjects = newObjects;
              });
            }

            void _updateType(String newType) {
              setState(() {
                editedType = newType;
              });
            }

            void _updateAppend(String newAppend) {
              setState(() {
                editedAppend = newAppend;
              });
            }

            void _saveChanges() {
              setState(() {
                (shotIndex == null) ? scenes[index].info.note : scenes[index][shotIndex].note = Note(
                  objects: editedObjects,
                  type: editedType,
                  append: editedAppend,
                );
              });
              Navigator.of(context).pop();
            }

            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit Note',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Objects:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: tagChips(editedObjects, context, _updateObjects),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Type:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    onChanged: (value) {
                      _updateType(value);
                    },
                    controller: TextEditingController(text: editedType),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Append:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    onChanged: (value) {
                      _updateAppend(value);
                    },
                    controller: TextEditingController(text: editedAppend),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text('向前添加'),
                      ),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text('保存'),
                      ),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text('向后添加'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    setState(() {});
  }

  List<Chip> tagChips(List<String> editedObjects, BuildContext context,
    void Function(List<String> newObjects) updateObjects) {
    var chipList = List<Chip>.empty(growable: true);
    for(int index = 0; index < editedObjects.length; index++){
      String object = editedObjects[index];
      chipList.add(
        Chip(
          label: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String newObject = '';
                    return AlertDialog(
                      title: const Text('Edit Object'),
                      content: TextField(
                        onChanged: (value) {
                          newObject = value;
                        },
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Edit'),
                          onPressed: () {
                            editedObjects[index] = newObject;
                            updateObjects(editedObjects);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(object)),
          onDeleted: () {
            updateObjects(editedObjects..remove(object));
          },
        )
        // TextField(
        //   onChanged: (value) {
        //     object = value;
        //   },
        //   controller:
        //       TextEditingController(text: object),
        // );
      );
    }
    chipList.add(Chip(
        label: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String newObject = '';
              return AlertDialog(
                title: const Text('Add Object'),
                content: TextField(
                  onChanged: (value) {
                    newObject = value;
                  },
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      updateObjects(editedObjects..add(newObject));
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      child: const Icon(Icons.add),
    )));
    return chipList;
  }
}
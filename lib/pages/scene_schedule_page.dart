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
2x 左边的列表可以滑动，右边的详情可以滑动
3. 撤回/重做按钮
4x BottomSheet，可以编辑/删除/添加，添加的时候可以选择是添加到上边还是下边
5. 悬浮的录音识别按钮，可以语音快速创建计划
6. 上面的语音识别按钮，还是要暂时用输入框代替
7x listtile 感觉很适合做右边表格的样式
郑老师对于“计划”的更具体的建议：
1. 可以考虑导入Excel分镜表
2. 以及每日通告
3. 自动化的计划生成，比如说，可以根据每日通告自动生成多日计划
4. 话筒信息可以根据通告自动生成
5. 可以考虑火星大数据的接入 
*/
class _SceneSchedulePageState extends State<SceneSchedulePage> with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  int _selectedShotIndex = 0;
  List<SceneSchedule> scenes = [];

  Future<void> _saveBox() async {
    var box = Hive.box('scenes_box');
    await box.clear();
    await box.addAll(scenes);
  }

  Future<void> _openBox() async {
    await Hive.openBox('scenes_box');
  }

  @override
  void initState() {
    // TODO: implement initState
    scenes = Hive.box('scenes_box').values.toList().cast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _openBox(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        // if (snapshot.connectionState == ConnectionState.done) {
        return Row(
          children: [
            Flexible(
              flex: 1,
              child: ReorderableListView.builder(
                // 左边的列表
                itemCount: scenes.length,
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
                    _saveBox();
                  });
                  _selectedIndex = newIndex;
                },
                itemBuilder: (BuildContext context, int index) {
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(scenes[index].info.name + index.toString()),
                    index: index,
                    child: leftList(index, context),
                  );
                },
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    elevation: 10.0,
                    child: child,
                  );
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
                    title: Text(
                        '${scenes[_selectedIndex].info.name}场，地点：${scenes[_selectedIndex].info.note.type}'),
                    subtitle: Text(scenes[_selectedIndex].info.note.append),
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
                          final item =
                              scenes[_selectedIndex].removeAt(oldIndex);
                          // int index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                          scenes[_selectedIndex].insert(newIndex, item);
                          // make the selected item to be the dragged item
                        });
                        _selectedShotIndex = newIndex;
                        _saveBox();
                      },
                      itemBuilder: (BuildContext context, int index2) {
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(scenes[_selectedIndex][index2].name +
                              index2.toString()),
                          index: index2,
                          child: rightList(index2, context),
                        );
                      },
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          elevation: 10.0,
                          child: child,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        // } else {
        //   return const Center(
        //     child: CircularProgressIndicator(),
        //   );
        // }
      },
    );
  }

  Dismissible leftList(int index, BuildContext context) {
    return Dismissible(
      key: Key(scenes[index].info.name + index.toString()),
      onDismissed: (direction) => setState(() {
        if (direction == DismissDirection.endToStart) {
          if (scenes.length > 1) {
            removeItem(context, index);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('至少保留一个场'),
              ),
            );
          }
        }
      }),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          if (scenes.length > 1) {
            return true;
          }
          return false;
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
      key: Key(item.name + index.toString()),
      onDismissed: (direction) => setState(() {
        if (direction == DismissDirection.endToStart) {
          if (scenes[_selectedIndex].length > 1) {
            removeItem(context, _selectedIndex, index);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('至少保留一个镜'),
              ),
            );
          }
        }
      }),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          if (scenes[_selectedIndex].length > 1) {
            return true;
          }
          return false;
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: item.note.objects
                      .map((object) => Container(
                            margin: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.purple[300],
                            ),
                            child: Text(
                              object,
                              style: TextStyle(fontSize: 14),
                            ),
                          ))
                      .toList(),
                ),
              ),
              Text(
                '${item.note.type},',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          subtitle: Text('${item.note.append}'),
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
    bool isScene = shotIndex == null;
    if (isScene) {
      var removed = scenes.removeAt(sceneIndex);
      _selectedIndex = (sceneIndex - 1 < 0) ? 0 : sceneIndex - 1;
      _selectedShotIndex = 0;
      _saveBox();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('第${removed.info.name} 场已撤回'),
          action: SnackBarAction(
            label: '恢复',
            onPressed: () {
              setState(() => scenes.insert(sceneIndex, removed));
              _saveBox();
            },
          )));
    } else {
      var removed = scenes[_selectedIndex].removeAt(shotIndex);
      // if remove the last item, _selectedShotIndex will be -1
      _selectedShotIndex = (shotIndex - 1 < 0) ? 0 : shotIndex - 1;
      _saveBox();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('第${removed.name} 镜已删除'),
          action: SnackBarAction(
            label: '恢复',
            onPressed: () {
              setState(() => scenes[sceneIndex].insert(shotIndex, removed));
              _saveBox();
            },
          )));
    }
  }

  void _dupSceneDetect(SceneSchedule newScene) {
    var detectorList = scenes.map((scene) => scene.info.name).toList();
    for (var name in detectorList) {
      if (newScene.info.name == name) {
        throw DuplicateItemException('本场号已存在');
      }
    }
  }

  void _editNote(BuildContext context, int index, [int? shotIndex]) async {
    // if shotIndex is null, edit scene note
    bool isScene = shotIndex == null;
    Note note =
        (isScene) ? scenes[index].info.note : scenes[index][shotIndex].note;
    String editedKey =
        (isScene) ? scenes[index].info.key : scenes[index][shotIndex].key;
    String editedFix =
        (isScene) ? scenes[index].info.fix : scenes[index][shotIndex].fix;

    List<String> fixs =
        List.generate(26, (index) => String.fromCharCode(index + 65));
    fixs = [''] + fixs;

    List<String> editedObjects = List.from(note.objects);
    String editedType = note.type;
    // to make the cursor at the end
    TextEditingController typeControlller =
        TextEditingController(text: editedType);
    typeControlller.selection = TextSelection.fromPosition(
        TextPosition(offset: typeControlller.text.length));

    String editedAppend = note.append;
    TextEditingController appendControlller =
        TextEditingController(text: editedAppend);
    appendControlller.selection = TextSelection.fromPosition(
        TextPosition(offset: appendControlller.text.length));
    // text to change
    var typeText = isScene ? '场地:' : '镜头类型:';
    var appendText = isScene ? '概要' : '内容';

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

            void addItem(bool after) {
              setState(() {
                var newNote = Note(
                  objects: editedObjects,
                  type: editedType,
                  append: editedAppend,
                );
                var newInfo = ScheduleItem(editedKey, editedFix, newNote);
                var newShot = ScheduleItem('1', '',
                    Note(objects: editedObjects, type: '近景', append: ''));
                var plusIndex = after ? 1 : 0;

                if (isScene) {
                  try {
                    var newScene = SceneSchedule([newShot], newInfo);
                    _dupSceneDetect(newScene);
                    if (index == scenes.length - 1) {
                      scenes.add(newScene);
                      return;
                    }
                    scenes.insert(index + plusIndex, newScene);
                  } on DuplicateItemException {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('该场景序号已存在'),
                      ),
                    );

                  }
                } else {
                  try {
                    if (shotIndex == scenes[index].length - 1) {
                      scenes[index].add(newInfo);
                      return;
                    }
                    scenes[index].insert(shotIndex + plusIndex, newInfo);
                  } on DuplicateItemException {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                      content: Text('该镜头序号已存在'),
                    ));

                  }
                }
              });
              Navigator.of(context).pop();
            }

            void saveChanges() {
              setState(() {
                var newNote = Note(
                  objects: editedObjects,
                  type: editedType,
                  append: editedAppend,
                );
                var newInfo = ScheduleItem(editedKey, editedFix, newNote);

                if (isScene) {
                  scenes[index].info = newInfo;
                } else {
                  scenes[index][shotIndex] = newInfo;
                }
              });
              Navigator.of(context).pop();
            }

            return CustomScrollView(
              scrollDirection: Axis.vertical,
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 1.2,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          '${isScene ? '场次' : '镜头'}信息修改',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<String>(
                              value: editedKey,
                              onChanged: (String? newValue) {
                                setState(() {
                                  editedKey = newValue!;
                                });
                              },
                              items: List.generate(
                                      200, (index) => (index + 1).toString())
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            DropdownButton<String>(
                              value: editedFix,
                              onChanged: (String? newValue) {
                                setState(() {
                                  editedFix = newValue!;
                                });
                              },
                              items: fixs.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            Text(isScene ? '场' : '镜')
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          '拍摄对象:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                tagChips(editedObjects, context, _updateObjects)
                                    .map((chip) =>
                                        Transform.scale(scale: 1, child: chip))
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          typeText,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (isScene)
                          TextField(
                            // 输入框自动滚动解决方案
                            scrollPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        20),
                            onChanged: (value) => editedType = value,
                            controller: typeControlller,
                          )
                        else
                          ToggleButtons(
                            isSelected: [
                              editedType == '特写',
                              editedType == '近景',
                              editedType == '中景',
                              editedType == '全景',
                              editedType == '远景',
                            ],
                            onPressed: (index) {
                              setState(() {
                                switch (index) {
                                  case 0:
                                    editedType = '特写';
                                    break;
                                  case 1:
                                    editedType = '近景';
                                    break;
                                  case 2:
                                    editedType = '中景';
                                    break;
                                  case 3:
                                    editedType = '全景';
                                    break;
                                  case 4:
                                    editedType = '远景';
                                    break;
                                }
                              });
                            },
                            children: const [
                              Text('特写'),
                              Text('近景'),
                              Text('中景'),
                              Text('全景'),
                              Text('远景'),
                            ],
                          ),
                        const SizedBox(height: 16.0),
                        Text(
                          appendText,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  20),
                          onChanged: (value) => editedAppend = value,
                          controller: appendControlller,
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => addItem(false),
                              child: const Text('向前添加'),
                            ),
                            ElevatedButton(
                              onPressed: saveChanges,
                              child: const Text('保存'),
                            ),
                            ElevatedButton(
                              onPressed: () => addItem(true),
                              child: const Text('向后添加'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
    _saveBox();
    setState(() {});
  }

  List<Chip> tagChips(List<String> editedObjects, BuildContext context,
      void Function(List<String> newObjects) updateObjects) {
    var chipList = List<Chip>.empty(growable: true);
    for (int index = 0; index < editedObjects.length; index++) {
      String object = editedObjects[index];
      chipList.add(Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            child: Text(
              object,
              style: TextStyle(
                fontSize: 14,
              ),
            )),
        onDeleted: () {
          updateObjects(editedObjects..remove(object));
        },
      ));
    }
    chipList.add(Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        )));

    return chipList;
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:voislate/models/slate_status_notifier.dart';

import '../models/slate_schedule.dart';
import '../../widgets/scene_schedule_page/note_editor.dart';

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
class _SceneSchedulePageState extends State<SceneSchedulePage>
    with AutomaticKeepAliveClientMixin {
  List<SceneSchedule> scenes = [];
  int selectedIndex = 0;
  int selectedShotIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    scenes = Hive.box('scenes_box').values.toList().cast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _openBox(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Consumer<SlateStatusNotifier>(
            builder: (context, slateNotifier, child) {
          selectedIndex = slateNotifier.selectedSceneIndex;
          selectedShotIndex = slateNotifier.selectedShotIndex;

          void removeItem(BuildContext context, int sceneIndex,
              [int? shotIndex]) {
            // if modify shot schedule, item is null
            bool isScene = shotIndex == null;
            if (isScene) {
              var removed = scenes.removeAt(sceneIndex);
              if (selectedIndex < sceneIndex) {
                // do nothing
              } else if (selectedIndex == sceneIndex &&
                  selectedIndex == scenes.length) {
                selectedIndex--;
                selectedShotIndex = 0;
                slateNotifier.setIndex(
                    scene: selectedIndex, shot: selectedShotIndex, take: 0);
              } else if (selectedIndex > sceneIndex) {
                selectedIndex--;
                slateNotifier.setIndex(scene: selectedIndex);
              }
              _saveBox();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 5),
                  content: Text('第 ${removed.info.name} 场已删除'),
                  action: SnackBarAction(
                    label: '恢复',
                    onPressed: () {
                      setState(() => scenes.insert(sceneIndex, removed));
                      _saveBox();
                    },
                  )));
            } else {
              var removed = scenes[selectedIndex].removeAt(shotIndex);
              // if remove the last item, selectedShotIndex will be -1
              selectedShotIndex = (shotIndex - 1 < 0) ? 0 : shotIndex - 1;
              if (selectedShotIndex < shotIndex) {
                // do nothing
              } else if (selectedShotIndex == shotIndex &&
                  selectedShotIndex == scenes[selectedIndex].length) {
                selectedShotIndex--;
                slateNotifier.setIndex(shot: selectedShotIndex, take: 0);
              } else if (selectedShotIndex > shotIndex) {
                selectedShotIndex--;
                slateNotifier.setIndex(shot: selectedShotIndex);
              }
              _saveBox();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 5),
                  content: Text('第 ${removed.name} 镜已删除'),
                  action: SnackBarAction(
                    label: '恢复',
                    onPressed: () {
                      setState(
                          () => scenes[sceneIndex].insert(shotIndex, removed));
                      _saveBox();
                    },
                  )));
            }
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
                  showNoteEditor(context, scenes, index);
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
              child: GestureDetector(
                onDoubleTap: () {
                  showNoteEditor(context, scenes, index);
                },
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
                    selected: index == selectedIndex,
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        slateNotifier.setIndex(scene: index);
                      });
                    },
                  ),
                ),
              ),
            );
          }

          Dismissible rightList(int index, BuildContext context) {
            var itemGroup = scenes[selectedIndex];
            var item = itemGroup[index];

            return Dismissible(
              key: Key(item.name + index.toString()),
              onDismissed: (direction) => setState(() {
                if (direction == DismissDirection.endToStart) {
                  if (scenes[selectedIndex].length > 1) {
                    removeItem(context, selectedIndex, index);
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
                  if (scenes[selectedIndex].length > 1) {
                    return true;
                  }
                  return false;
                } else if (direction == DismissDirection.startToEnd) {
                  showNoteEditor(
                      context, scenes, selectedIndex, selectedIndex, index);
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
              child: GestureDetector(
                onDoubleTap: () {
                  showNoteEditor(
                      context, scenes, selectedIndex, selectedIndex, index);
                },
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
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    subtitle: Text(item.note.append),
                    selected: index == selectedShotIndex,
                    onTap: () {
                      setState(() {
                        selectedShotIndex = index;
                        slateNotifier.setIndex(shot: index, take: 1);
                      });
                    },
                  ),
                ),
              ),
            );
          }

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
                      selectedIndex = newIndex;
                      slateNotifier.setIndex(scene: newIndex, shot: 1, take: 1);
                      _saveBox();
                    });
                    slateNotifier.setIndex(scene: newIndex);
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
                          '${scenes[selectedIndex].info.name}场，地点：${scenes[selectedIndex].info.note.type}'),
                      subtitle: Text(scenes[selectedIndex].info.note.append),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        // 右边的列表
                        itemCount: scenes[selectedIndex].length,
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item =
                                scenes[selectedIndex].removeAt(oldIndex);
                            // int index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                            scenes[selectedIndex].insert(newIndex, item);
                            // make the selected item to be the dragged item
                            selectedShotIndex = newIndex;
                          });
                          slateNotifier.setIndex(shot: newIndex, take: 1);
                          _saveBox();
                        },
                        itemBuilder: (BuildContext context, int index2) {
                          return ReorderableDelayedDragStartListener(
                            key: ValueKey(scenes[selectedIndex][index2].name +
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
        });
        // } else {
        //   return const Center(
        //     child: CircularProgressIndicator(),
        //   );
        // }
      },
    );
  }

  Future<void> _saveBox() async {
    var box = Hive.box('scenes_box');
    await box.clear();
    await box.addAll(scenes);
  }

  Future<void> _openBox() async {
    await Hive.openBox('scenes_box');
  }

  void showNoteEditor(
      BuildContext context, List<SceneSchedule> scenes, int index,
      [int? selectedIndex, int? shotIndex]) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: (selectedIndex != null && shotIndex != null)
                ? NoteEditor(
                    context: context,
                    scenes: scenes,
                    index: index,
                    selectedIndex: selectedIndex,
                    shotIndex: shotIndex,
                  )
                : NoteEditor(
                    context: context,
                    scenes: scenes,
                    index: index,
                  ));
      },
    );
    _saveBox();
    setState(() {});
  }
}

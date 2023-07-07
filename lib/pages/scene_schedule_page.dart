import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:voislate/providers/slate_status_notifier.dart';

import '../models/slate_schedule.dart';
import '../../widgets/scene_schedule_page/note_editor.dart';

class SceneSchedulePage extends StatefulWidget {
  const SceneSchedulePage({super.key});

  @override
  SceneSchedulePageState createState() => SceneSchedulePageState();
}

/*
TODO:
1x 一个左边的列表，右边的详情
2x 左边的列表可以滑动，右边的详情可以滑动
3x 撤回/重做按钮
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
class SceneSchedulePageState extends State<SceneSchedulePage>
    with AutomaticKeepAliveClientMixin {
  List<SceneSchedule> scenes = [];
  int selectedSceneIndex = 0;
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
          selectedSceneIndex = slateNotifier.selectedSceneIndex;
          selectedShotIndex = slateNotifier.selectedShotIndex;

          void removeItem(BuildContext context, int sceneIndex,
              [int? shotIndex]) {
            // if modify shot schedule, item is null
            bool isScene = shotIndex == null;
            if (isScene) {
              var removed = scenes.removeAt(sceneIndex);
              if (selectedSceneIndex < sceneIndex) {
                // do nothing
              } else if (selectedSceneIndex == sceneIndex &&
                  selectedSceneIndex == scenes.length) {
                selectedSceneIndex--;
                selectedShotIndex = 0;
                slateNotifier.setIndex(
                    scene: selectedSceneIndex, shot: selectedShotIndex, take: 0);
              } else if (selectedSceneIndex > sceneIndex) {
                selectedSceneIndex--;
                slateNotifier.setIndex(scene: selectedSceneIndex);
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
              var removed = scenes[selectedSceneIndex].removeAt(shotIndex);
              // if remove the last item, selectedShotIndex will be -1
              // selectedShotIndex = (shotIndex - 1 < 0) ? 0 : shotIndex - 1;
              if (selectedShotIndex < shotIndex) {

              } else if (selectedShotIndex == shotIndex &&
                  selectedShotIndex == scenes[selectedSceneIndex].length) {
                setState(() {
                  selectedShotIndex--;
                });
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
                    selected: index == selectedSceneIndex,
                    onTap: () {
                      setState(() {
                        selectedSceneIndex = index;
                        selectedShotIndex = 0;
                        slateNotifier.setIndex(scene: index, shot: 0, take: 0);
                      });
                    },
                  ),
                ),
              ),
            );
          }

          Dismissible rightList(int index, BuildContext context) {
            var itemGroup = scenes[selectedSceneIndex];
            var item = itemGroup[index];

            return Dismissible(
              key: Key(item.name + index.toString()),
              onDismissed: (direction) => setState(() {
                if (direction == DismissDirection.endToStart) {
                  if (scenes[selectedSceneIndex].length > 1) {
                    removeItem(context, selectedSceneIndex, index);
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
                  if (scenes[selectedSceneIndex].length > 1) {
                    return true;
                  }
                  return false;
                } else if (direction == DismissDirection.startToEnd) {
                  showNoteEditor(
                      context, scenes, selectedSceneIndex, index);
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
                      context, scenes, selectedSceneIndex, index);
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
                                      margin: const EdgeInsets.only(right: 5),
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.purple[300],
                                      ),
                                      child: Text(
                                        object,
                                        style: const TextStyle(fontSize: 14),
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
                        slateNotifier.setIndex(shot: index, take: 0);
                      });
                    },
                  ),
                ),
              ),
            );
          }

          return Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Row(
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
                          selectedSceneIndex = newIndex;
                          slateNotifier.setIndex(
                              scene: newIndex, shot: 0, take: 0);
                          _saveBox();
                        });
                        slateNotifier.setIndex(scene: newIndex);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(
                              scenes[index].info.name + index.toString()),
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
                              '${scenes[selectedSceneIndex].info.name}场，地点：${scenes[selectedSceneIndex].info.note.type}'),
                          subtitle:
                              Text(scenes[selectedSceneIndex].info.note.append),
                        ),
                        Expanded(
                          child: ReorderableListView.builder(
                            // 右边的列表
                            itemCount: scenes[selectedSceneIndex].length,
                            onReorder: (int oldIndex, int newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item =
                                    scenes[selectedSceneIndex].removeAt(oldIndex);
                                // int index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                                scenes[selectedSceneIndex].insert(newIndex, item);
                                // make the selected item to be the dragged item
                                selectedShotIndex = newIndex;
                              });
                              slateNotifier.setIndex(shot: newIndex, take: 0);
                              _saveBox();
                            },
                            itemBuilder: (BuildContext context, int index2) {
                              return ReorderableDelayedDragStartListener(
                                key: ValueKey(
                                    scenes[selectedSceneIndex][index2].name +
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
              ),
              ElevatedButton.icon(
                onPressed: () {
                  var util = ScheduleUtils(
                    scenes: scenes,
                    currentScnIndex: selectedSceneIndex,
                    currentShtIndex: selectedShotIndex
                    );
                  util.addNewAtLast();
                  setState(() {});
                },
                icon: const Icon(Icons.add_business_outlined),
                label: const Text("镜头+"),
              )
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
      BuildContext context, List<SceneSchedule> scenes, int currentScn,
      [int? currentSht]) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        var isScene = currentSht == null;
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: (isScene)
                ? NoteEditor(
                    context: context,
                    scenes: scenes,
                    scnIndex: currentScn,
                  )
                : NoteEditor(
                    context: context,
                    scenes: scenes,
                    scnIndex: currentScn,
                    shotIndex: currentSht,
                  )
                );
      },
    );
    _saveBox();
    setState(() {});
  }
}

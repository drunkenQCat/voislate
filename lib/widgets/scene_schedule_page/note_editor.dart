import 'package:flutter/material.dart';
import '../../models/slate_schedule.dart';

class NoteEditor extends StatefulWidget {
  final BuildContext context;
  final List<SceneSchedule> scenes;
  final int index;
  final int? selectedIndex;
  final int? shotIndex;

  const NoteEditor({
    super.key,
    required this.context,
    required this.scenes,
    required this.index,
    this.selectedIndex,
    this.shotIndex,
  }) : assert((shotIndex == null && selectedIndex == null) ||
            (shotIndex != null && selectedIndex != null));

  @override
  // ignore: library_private_types_in_public_api
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late bool isScene;
  late Note note;
  late String editedKey;
  late String editedFix;
  late List<String> fixs;
  late List<String> editedObjects;
  late String editedType;
  late String editedAppend;
  late TextEditingController typeControlller;
  late TextEditingController appendControlller;

  late int selectedIndex;

  late String typeText;
  late String appendText;

  @override
  void initState() {
    super.initState();
    isScene = widget.shotIndex == null;
    note = (isScene)
        ? widget.scenes[widget.index].info.note
        : widget.scenes[widget.index][widget.shotIndex!].note;
    editedKey = (isScene)
        ? widget.scenes[widget.index].info.key
        : widget.scenes[widget.index][widget.shotIndex!].key;
    editedFix = (isScene)
        ? widget.scenes[widget.index].info.fix
        : widget.scenes[widget.index][widget.shotIndex!].fix;
    fixs = List.generate(26, (index) => String.fromCharCode(index + 65));
    fixs = [''] + fixs;
    editedObjects = List.from(note.objects);
    editedType = note.type;
    editedAppend = note.append;
    typeControlller = TextEditingController(text: editedType);
    typeControlller.selection = TextSelection.fromPosition(
        TextPosition(offset: typeControlller.text.length));
    appendControlller = TextEditingController(text: editedAppend);
    appendControlller.selection = TextSelection.fromPosition(
        TextPosition(offset: appendControlller.text.length));
    typeText = isScene ? '场地:' : '镜头类型:';
    appendText = isScene ? '概要' : '内容';
    selectedIndex = widget.selectedIndex ?? 0;
  }

  void _dupSceneDetect(SceneSchedule newScene) {
    var detectorList = widget.scenes.map((scene) => scene.info.name).toList();
    for (var name in detectorList) {
      if (newScene.info.name == name) {
        throw DuplicateItemException('本场号已存在');
      }
    }
  }

  void _dupShotDetect(ScheduleItem newShot) {
    var detectorList =
        widget.scenes[selectedIndex].data.map((shot) => shot.name).toList();
    for (var name in detectorList) {
      if (newShot.name == name) {
        throw DuplicateItemException('本镜号已存在');
      }
    }
  }

  String _findFix(List<String> alphas, bool after) {
    if (after) return '';
    if (alphas == ['']) return 'A';
    alphas =
        alphas.where((element) => element.contains(RegExp(r'[A-Z]'))).toList();
    alphas.sort();
    String someLetterMax = alphas.last;
    if (someLetterMax == 'Z') {
      int maxGap = 0;
      for (int i = 0; i < alphas.length - 1; i++) {
        int gap = alphas[i + 1].codeUnitAt(0) - alphas[i].codeUnitAt(0);
        if (gap > maxGap) {
          maxGap = gap;
          someLetterMax = alphas[i];
        }
      }
    }
    int nextLetter = someLetterMax.codeUnitAt(0) + 1;
    return String.fromCharCode(nextLetter);
  }

  String _findKey(List<int> keys, int index, bool after) {
    if (!after)
      return (index == 0) ? keys[0].toString() : keys[index - 1].toString();
    keys.sort();
    int maxKey = keys.last;
    return (maxKey + 1).toString();
  }

  void addItem(bool after) {
    setState(() {
      var newNote = Note(
        objects: editedObjects,
        type: editedType,
        append: editedAppend,
      );
      var newInfo = ScheduleItem(editedKey, editedFix, newNote);
      var newShot = ScheduleItem(
          '1', '', Note(objects: editedObjects, type: '近景', append: ''));
      var plusIndex = after ? 1 : 0;

      if (isScene) {
        var newScene = SceneSchedule([newShot], newInfo);
        try {
          _dupSceneDetect(newScene);
        } on DuplicateItemException {
          List<int> keys = widget.scenes
              .map((scene) => int.tryParse(scene.info.key) ?? 0)
              .toList();
          newInfo.key = _findKey(keys, widget.index, after);
          List<String> fixs = widget.scenes
              .where((scene) => scene.info.key == newInfo.key)
              .map((scene) => scene.info.fix)
              .toList();
          newInfo.fix = _findFix(fixs, after);
          newScene.info = newInfo;
        }
        (widget.index == widget.scenes.length - 1 && after)
            ? widget.scenes.add(newScene)
            : widget.scenes.insert(widget.index + plusIndex, newScene);
      } else {
        try {
          _dupShotDetect(newInfo);
        } catch (e) {
          List<int> keys = widget.scenes[widget.index].data
              .map((shot) => int.tryParse(shot.key) ?? 0)
              .toList();
          newInfo.key = _findKey(keys, widget.index, after);
          List<String> fixs = widget.scenes[widget.index].data
              .where((shot) => shot.key == newInfo.key)
              .map((shot) => shot.fix)
              .toList();
          newInfo.fix = _findFix(fixs, after);
          (widget.shotIndex == widget.scenes[widget.index].length - 1 && after)
              ? widget.scenes[widget.index].add(newInfo)
              : widget.scenes[widget.index]
                  .insert(widget.shotIndex! + plusIndex, newInfo);
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
        widget.scenes[widget.index].info = newInfo;
      } else {
        widget.scenes[widget.index].data[widget.shotIndex!] = newInfo;
      }
    });
    Navigator.of(context).pop();
  }

  void _updateObjects(List<String> newObjects) {
    setState(() {
      editedObjects = newObjects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height * 1.2,
                padding: const EdgeInsets.all(16.0),
                child: contentEditor(setState, context),
              ),
            )
          ],
        );
      },
    );
  }

  Column contentEditor(StateSetter setState, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 3,
        ),
        // The title
        Text(
          '${isScene ? '场次' : '镜头'}信息修改',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        keyFixPicker(setState),
        const SizedBox(height: 16.0),
        objectsTagEditor(context),
        const SizedBox(height: 16.0),
        typeEditor(context),
        const SizedBox(height: 16.0),
        appendEditor(context),
        const SizedBox(height: 16.0),
        confirmButtons(),
      ],
    );
  }

  Row confirmButtons() {
    return Row(
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
      );
  }

  Column appendEditor(BuildContext context) {
    return Column(
      children: [
        Text(
          appendText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(
          scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          onChanged: (value) => editedAppend = value,
          controller: appendControlller,
        ),
      ],
    );
  }

  Column typeEditor(BuildContext context) {
    return Column(
      children: [
        Text(
          typeText,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        if (isScene)
          TextField(
            // 输入框自动滚动解决方案
            scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
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
      ],
    );
  }

  Column objectsTagEditor(BuildContext context) {
    return Column(
      children: [
        const Text(
          '拍摄对象:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tagChips(editedObjects, context, _updateObjects)
                .map((chip) => Transform.scale(scale: 1, child: chip))
                .toList(),
          ),
        ),
      ],
    );
  }

  Row keyFixPicker(StateSetter setState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          value: editedKey,
          onChanged: (String? newValue) {
            setState(() {
              editedKey = newValue!;
            });
          },
          items: List.generate(200, (index) => (index + 1).toString())
              .map<DropdownMenuItem<String>>((String value) {
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
          items: fixs.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Text(isScene ? '场' : '镜')
      ],
    );
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
}



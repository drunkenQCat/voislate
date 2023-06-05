import 'package:flutter/material.dart';
import '../../models/slate_log_item.dart';

class LogEditor extends StatefulWidget {
  final BuildContext context;
  final List<SlateLogItem> logItems;
  final int index;

  const LogEditor({
    super.key,
    required this.context,
    required this.logItems,
    required this.index,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LogEditorState createState() => _LogEditorState();
}

class _LogEditorState extends State<LogEditor> {
  late String _scn;
  late String _sht;
  late int _tkNum;
  late String _filenamePrefix;
  late String _filenameLinker;
  late int _filenameNum;
  late TextEditingController _tkNoteController;
  late TextEditingController _shtNoteController;
  late TextEditingController _scnNoteController;
  late TkStatus _okTk;
  late ShtStatus _okSht;
  late TextStyle? textStyle;
  late TextStyle fixedWordsStyle;
  late TextStyle selectableWordsStyle;
  @override
  void initState() {
    super.initState();
    _scn = widget.logItems[widget.index].scn;
    _sht = widget.logItems[widget.index].sht;
    _tkNum = widget.logItems[widget.index].tk;
    _filenamePrefix = widget.logItems[widget.index].filenamePrefix;
    _filenameLinker = widget.logItems[widget.index].filenameLinker;
    _filenameNum = widget.logItems[widget.index].filenameNum;
    _tkNoteController =
        TextEditingController(text: widget.logItems[widget.index].tkNote);
    _shtNoteController =
        TextEditingController(text: widget.logItems[widget.index].shtNote);
    _scnNoteController =
        TextEditingController(text: widget.logItems[widget.index].scnNote);
    _okTk = widget.logItems[widget.index].okTk;
    _okSht = widget.logItems[widget.index].okSht;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    textStyle = Theme.of(context).textTheme.titleLarge;
    fixedWordsStyle = TextStyle(
      shadows: const [Shadow(color: Colors.black12, offset: Offset(2, 4))],
      fontSize: textStyle!.fontSize,
      fontWeight: FontWeight.normal,
      color: Colors.black54,
    );
    selectableWordsStyle = TextStyle(
      fontSize: textStyle!.fontSize,
      fontWeight: FontWeight.normal,
      color: Colors.blue[400],
    );
  }

  @override
  void dispose() {
    _tkNoteController.dispose();
    _shtNoteController.dispose();
    _scnNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Slate Log Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fileNumPicker(),
              tkNumPicker(),
              TextField(
                controller: _tkNoteController,
                decoration: const InputDecoration(
                  labelText: '录音描述',
                ),
              ),
              TextField(
                controller: _shtNoteController,
                decoration: const InputDecoration(
                  labelText: '镜头标注',
                ),
              ),
              TextField(
                controller: _scnNoteController,
                decoration: const InputDecoration(
                  labelText: '本场信息',
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    tkStatusPicker(),
                    const VerticalDivider(
                        indent: 10, endIndent: 2, color: Colors.grey),
                    shtStatusPicker(),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Save changes to the SlateLogItem object
                  widget.logItems[widget.index].tk = _tkNum;
                  widget.logItems[widget.index].filenameNum = _filenameNum;
                  widget.logItems[widget.index].tkNote = _tkNoteController.text;
                  widget.logItems[widget.index].shtNote =
                      _shtNoteController.text;
                  widget.logItems[widget.index].scnNote =
                      _scnNoteController.text;
                  widget.logItems[widget.index].okTk = _okTk;
                  widget.logItems[widget.index].okSht = _okSht;

                  // Navigate back to the previous screen
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget fileNumPicker() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('$_filenamePrefix $_filenameLinker  ', style: fixedWordsStyle,),
      DropdownButton<int>(
        value: _filenameNum,
        onChanged: (value) {
          setState(() {
            _filenameNum = value!;
          });
        },
        items: List.generate(500, (index) => index + 1).map((number) {
          return DropdownMenuItem<int>(
            value: number,
            child: Text(number.toString(),style: selectableWordsStyle,),
          );
        }).toList(),
      ),
    ]);
  }

  Row shtStatusPicker() {
    return Row(
      children: [
        const Icon(
          Icons.movie,
          color: Colors.blue,
        ),
        const Text('镜头评价'),
        const SizedBox(
          width: 4,
        ),
        DropdownButton<ShtStatus>(
          value: _okSht,
          onChanged: (value) {
            setState(() {
              _okSht = value!;
            });
          },
          items: ShtStatus.values.map((status) {
            return DropdownMenuItem<ShtStatus>(
              value: status,
              child: status == ShtStatus.notChecked
                  ? const Row(
                      children: [
                        Icon(
                          Icons.videocam,
                          color: Colors.grey,
                        ),
                        Text('无')
                      ],
                    )
                  : status == ShtStatus.ok
                      ? const Row(
                          children: [
                            Icon(
                              Icons.movie_filter,
                              color: Colors.blue,
                            ),
                            Text('保')
                          ],
                        )
                      : const Row(
                          children: [
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              color: Colors.green,
                            ),
                            Text('过')
                          ],
                        ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Row tkStatusPicker() {
    return Row(
      children: [
        const Icon(
          Icons.radio_button_checked,
          color: Colors.red,
        ),
        const Text('录音评价'),
        const SizedBox(
          width: 4,
        ),
        DropdownButton<TkStatus>(
          value: _okTk,
          onChanged: (value) {
            setState(() {
              _okTk = value!;
            });
          },
          items: TkStatus.values.map((status) {
            return DropdownMenuItem<TkStatus>(
              value: status,
              child: status == TkStatus.notChecked
                  ? const Row(
                      children: [
                        Icon(
                          Icons.headphones,
                          color: Colors.grey,
                        ),
                        Text('无')
                      ],
                    )
                  : status == TkStatus.ok
                      ? const Row(
                          children: [
                            Icon(
                              Icons.gpp_good,
                              color: Colors.green,
                            ),
                            Text('过')
                          ],
                        )
                      : const Row(
                          children: [
                            Icon(
                              Icons.hearing_disabled,
                              color: Colors.red,
                            ),
                            Text('弃')
                          ],
                        ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget tkNumPicker() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [
        Text(_scn, style: fixedWordsStyle),
        Text('场', style: textStyle),
        const SizedBox(
          width: 10,
        ),
        Text(_sht, style: fixedWordsStyle),
        Text('镜', style: textStyle),
      ]),
      const SizedBox(
        width: 10,
      ),
      DropdownButton<int>(
        value: _tkNum,
        onChanged: (value) {
          setState(() {
            _tkNum = value!;
          });
        },
        items: List.generate(500, (index) => index + 1).map((number) {
          return DropdownMenuItem<int>(
            value: number,
            child: Text(
              number.toString(),
              style: selectableWordsStyle,
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
      Text('次', style: textStyle),
    ]);
  }
}

// {
//   void _dupSceneDetect(SceneSchedule newScene) {
//     var detectorList = widget.logItems.map((scene) => scene.info.name).toList();
//     for (var name in detectorList) {
//       if (newScene.info.name == name) {
//         throw DuplicateItemException('本场号已存在');
//       }
//     }
//   }

//   void _dupShotDetect(ScheduleItem newShot) {
//     var detectorList =
//         widget.logItems[selectedIndex].data.map((shot) => shot.name).toList();
//     for (var name in detectorList) {
//       if (newShot.name == name) {
//         throw DuplicateItemException('本镜号已存在');
//       }
//     }
//   }

//   String _findFix(List<String> alphas, bool after) {
//     if (after) return '';
//     if (alphas == ['']) return 'A';
//     alphas =
//         alphas.where((element) => element.contains(RegExp(r'[A-Z]'))).toList();
//     alphas.sort();
//     String someLetterMax = alphas.last;
//     if (someLetterMax == 'Z') {
//       int maxGap = 0;
//       for (int i = 0; i < alphas.length - 1; i++) {
//         int gap = alphas[i + 1].codeUnitAt(0) - alphas[i].codeUnitAt(0);
//         if (gap > maxGap) {
//           maxGap = gap;
//           someLetterMax = alphas[i];
//         }
//       }
//     }
//     int nextLetter = someLetterMax.codeUnitAt(0) + 1;
//     return String.fromCharCode(nextLetter);
//   }

//   String _findKey(List<int> keys, int index, bool after) {
//     if (!after)
//       return (index == 0) ? keys[0].toString() : keys[index - 1].toString();
//     keys.sort();
//     int maxKey = keys.last;
//     return (maxKey + 1).toString();
//   }

//   void addItem(bool after) {
//     setState(() {
//       var newNote = Note(
//         objects: editedObjects,
//         type: editedType,
//         append: editedAppend,
//       );
//       var newInfo = ScheduleItem(editedPrefix, editedNum, newNote);
//       var newShot = ScheduleItem(
//           '1', '', Note(objects: editedObjects, type: '近景', append: ''));
//       var plusIndex = after ? 1 : 0;

//       if (isScene) {
//         var newScene = SceneSchedule([newShot], newInfo);
//         try {
//           _dupSceneDetect(newScene);
//         } on DuplicateItemException {
//           List<int> keys = widget.logItems
//               .map((scene) => int.tryParse(scene.info.key) ?? 0)
//               .toList();
//           newInfo.key = _findKey(keys, widget.index, after);
//           List<String> fixs = widget.logItems
//               .where((scene) => scene.info.key == newInfo.key)
//               .map((scene) => scene.info.fix)
//               .toList();
//           newInfo.fix = _findFix(fixs, after);
//           newScene.info = newInfo;
//         }
//         (widget.index == widget.logItems.length - 1 && after)
//             ? widget.logItems.add(newScene)
//             : widget.logItems.insert(widget.index + plusIndex, newScene);
//       } else {
//         try {
//           _dupShotDetect(newInfo);
//         } catch (e) {
//           List<int> keys = widget.logItems[widget.index].data
//               .map((shot) => int.tryParse(shot.key) ?? 0)
//               .toList();
//           newInfo.key = _findKey(keys, widget.index, after);
//           List<String> fixs = widget.logItems[widget.index].data
//               .where((shot) => shot.key == newInfo.key)
//               .map((shot) => shot.fix)
//               .toList();
//           newInfo.fix = _findFix(fixs, after);
//           (widget.shotIndex == widget.logItems[widget.index].length - 1 &&
//                   after)
//               ? widget.logItems[widget.index].add(newInfo)
//               : widget.logItems[widget.index]
//                   .insert(widget.shotIndex! + plusIndex, newInfo);
//         }
//       }
//     });
//     Navigator.of(context).pop();
//   }

//   void saveChanges() {
//     setState(() {
//       var newNote = Note(
//         objects: editedObjects,
//         type: editedType,
//         append: editedAppend,
//       );
//       var newInfo = ScheduleItem(editedPrefix, editedNum, newNote);

//       if (isScene) {
//         widget.logItems[widget.index].info = newInfo;
//       } else {
//         widget.logItems[widget.index].data[widget.shotIndex!] = newInfo;
//       }
//     });
//     Navigator.of(context).pop();
//   }

//   void _updateObjects(List<String> newObjects) {
//     setState(() {
//       editedObjects = newObjects;
//     });
//   }

//   Column contentEditor(StateSetter setState, BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const SizedBox(
//           height: 3,
//         ),
//         // The title
//         Text(
//           '${isScene ? '场次' : '镜头'}信息修改',
//           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16.0),
//         keyFixPicker(setState),
//         const SizedBox(height: 16.0),
//         objectsTagEditor(context),
//         const SizedBox(height: 16.0),
//         typeEditor(context),
//         const SizedBox(height: 16.0),
//         appendEditor(context),
//       ],
//     );
//   }

//   Row confirmButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         ElevatedButton(
//           onPressed: () => addItem(false),
//           child: const Row(
//             children: [
//               Icon(Icons.arrow_upward),
//               Text('向前添加'),
//             ],
//           ),
//         ),
//         ElevatedButton(
//           onPressed: saveChanges,
//           child: const Text('保存'),
//         ),
//         ElevatedButton(
//           onPressed: () => addItem(true),
//           child: const Row(
//             children: [
//               Text('向后添加'),
//               Icon(Icons.arrow_downward),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Column appendEditor(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           appendText,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         TextField(
//           scrollPadding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom + 20),
//           onChanged: (value) => editedAppend = value,
//           controller: appendControlller,
//         ),
//       ],
//     );
//   }

//   Column typeEditor(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           typeText,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         if (isScene)
//           TextField(
//             // 输入框自动滚动解决方案
//             scrollPadding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom + 20),
//             onChanged: (value) => editedType = value,
//             controller: typeControlller,
//           )
//         else
//           ToggleButtons(
//             isSelected: [
//               editedType == '特写',
//               editedType == '近景',
//               editedType == '中景',
//               editedType == '全景',
//               editedType == '远景',
//             ],
//             onPressed: (index) {
//               setState(() {
//                 switch (index) {
//                   case 0:
//                     editedType = '特写';
//                     break;
//                   case 1:
//                     editedType = '近景';
//                     break;
//                   case 2:
//                     editedType = '中景';
//                     break;
//                   case 3:
//                     editedType = '全景';
//                     break;
//                   case 4:
//                     editedType = '远景';
//                     break;
//                 }
//               });
//             },
//             children: const [
//               Text('特写'),
//               Text('近景'),
//               Text('中景'),
//               Text('全景'),
//               Text('远景'),
//             ],
//           ),
//       ],
//     );
//   }

//   Column objectsTagEditor(BuildContext context) {
//     return Column(
//       children: [
//         const Text(
//           '拍摄对象:',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: tagChips(editedObjects, context, _updateObjects)
//                 .map((chip) => Transform.scale(scale: 1, child: chip))
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   Row keyFixPicker(StateSetter setState) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         DropdownButton<String>(
//           value: editedPrefix,
//           onChanged: (String? newValue) {
//             setState(() {
//               editedPrefix = newValue!;
//             });
//           },
//           items: List.generate(200, (index) => (index + 1).toString())
//               .map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//         ),
//         const SizedBox(
//           width: 5,
//         ),
//         DropdownButton<String>(
//           value: editedNum,
//           onChanged: (String? newValue) {
//             setState(() {
//               editedNum = newValue!;
//             });
//           },
//           items: fixs.map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//         ),
//         Text(isScene ? '场' : '镜')
//       ],
//     );
//   }

//   List<Chip> tagChips(List<String> editedObjects, BuildContext context,
//       void Function(List<String> newObjects) updateObjects) {
//     var chipList = List<Chip>.empty(growable: true);
//     for (int index = 0; index < editedObjects.length; index++) {
//       String object = editedObjects[index];
//       chipList.add(Chip(
//         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         label: TextButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   String newObject = '';
//                   return AlertDialog(
//                     title: const Text('Edit Object'),
//                     content: TextField(
//                       onChanged: (value) {
//                         newObject = value;
//                       },
//                     ),
//                     actions: [
//                       TextButton(
//                         child: const Text('Cancel'),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                       TextButton(
//                         child: const Text('Edit'),
//                         onPressed: () {
//                           editedObjects[index] = newObject;
//                           updateObjects(editedObjects);
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             child: Text(
//               object,
//               style: TextStyle(
//                 fontSize: 14,
//               ),
//             )),
//         onDeleted: () {
//           updateObjects(editedObjects..remove(object));
//         },
//       ));
//     }
//     chipList.add(Chip(
//         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         label: TextButton(
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 String newObject = '';
//                 return AlertDialog(
//                   title: const Text('Add Object'),
//                   content: TextField(
//                     onChanged: (value) {
//                       newObject = value;
//                     },
//                   ),
//                   actions: [
//                     TextButton(
//                       child: const Text('Cancel'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                     TextButton(
//                       child: const Text('Add'),
//                       onPressed: () {
//                         updateObjects(editedObjects..add(newObject));
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//           child: const Icon(
//             Icons.add,
//             size: 30,
//           ),
//         )));
//     return chipList;
//   }
// }

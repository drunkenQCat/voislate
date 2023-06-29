import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voislate/providers/slate_status_notifier.dart';

import '../../models/recorder_file_num.dart';

class FileCounter extends StatelessWidget {
  final RecordFileNum num;
  final int _initCounter;
  const FileCounter({
    super.key,
    required int init,
    required this.num,
  }) : _initCounter = init;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.headlineMedium;

    return StreamBuilder<int>(
      stream: num.value,
      initialData: _initCounter,
      builder: (context, snapshot) {
        return Center(
          child: FileNameDisplayCard(
              num: num, snapshot: snapshot, style: textStyle),
        );
      },
    );
  }
}

class FileNameDisplayCard extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final TextStyle? style;
  final RecordFileNum num;

  const FileNameDisplayCard({
    super.key,
    required this.num,
    required this.snapshot,
    required this.style,
  });

  @override
  State<FileNameDisplayCard> createState() => _FileNameDisplayCardState();
}

class _FileNameDisplayCardState extends State<FileNameDisplayCard> {
  late String type;

  @override
  void initState() {
    super.initState();
    type = widget.num.recorderType;
  }
  @override
  Widget build(BuildContext context) {
    const TextStyle tagStyle = TextStyle(
      fontSize: 16,
      color: Colors.black45,
      fontWeight: FontWeight.w100,
    );
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Card(
        color: Colors.blueGrey[100],
        margin: EdgeInsets.fromLTRB(21, 5, 16, 5),
        child: GestureDetector(
          onLongPress: () {
            showDialog(context: context, builder: (context)=>prefixEditor());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.num.prefix.contains(RegExp(r'^[0-9]+$'))
                        ? 'Date'
                        : 'Custom',
                    style: tagStyle,
                  ),
                  Text(
                    widget.num.prefix,
                    style: widget.num.prefix.length > 6 ? 
                      TextStyle(fontSize: 20) : 
                      widget.style,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Devider',
                    style: tagStyle,
                  ),
                  GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String value = widget.num.intervalSymbol;
                          return AlertDialog(
                            title: const Text('Edit Devider'),
                            content: TextField(
                              onChanged: (newValue) {
                                value = newValue;
                              },
                              onSubmitted: (newValue) {
                                widget.num.intervalSymbol = newValue;
                                Provider.of<SlateStatusNotifier>(context,
                                        listen: false)
                                    .setRecordLinker(newValue);
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                              controller: TextEditingController(text: value),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      widget.num.intervalSymbol,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.black45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  const Text(
                    'Num',
                    style: tagStyle,
                  ),
                  GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String value = widget.snapshot.data.toString();
                          return AlertDialog(
                            title: const Text('编辑录音编号（不需要输入0）'),
                            content: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (newValue) {
                                value = newValue;
                              },
                              onSubmitted: (newValue) {
                                widget.num.setValue(int.parse(newValue));
                                Navigator.of(context).pop();
                              },
                              controller: TextEditingController(text: value),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      widget.snapshot.data.toString().padLeft(3, '0'),
                      style: widget.style,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget prefixEditor() {
    String value = widget.num.prefix;
    var editCon = TextEditingController(text: value);
    var prefixEditField = TextField(
      onSubmitted: (newValue) {
        widget.num.customPrefix = newValue;
        Provider.of<SlateStatusNotifier>(context,
                listen: false)
            .setCustomPrefix(newValue);
        setState(() {});
        Navigator.of(context).pop();
      },
      controller: editCon,
    );
    return AlertDialog(
      title: const Text('请选择前缀形式'),
      content: SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ToggleButtons(
              isSelected: [
                type == "default",
                type == "sound devices",
                type == "custom"
              ],
              onPressed: (int index) {
                  switch (index) {
                    case 0:
                      type = "default";
                      break;
                    case 1:
                      type = "sound devices";
                      break;
                    case 2:
                      type = "custom";
                      break;
                  }
                  widget.num.recorderType = type;
                  Provider.of<SlateStatusNotifier>(context, listen: false)
                      .setPrefixType(type);
                  setState(() {
                    editCon.text = widget.num.prefix;
                  });
              },
              children: const [
                Text("Date"),
                Text("Sound Devices"),
                Text("Custom")
              ]),
              prefixEditField,
          ],
        ),
      ),
    );
  }
}

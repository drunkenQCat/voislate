import 'package:flutter/material.dart';

import '../models/slate_schedule.dart';
import '../data/dummy_scenes.dart';
// give me a frame of listview page
class SlateLog extends StatefulWidget {
  @override
  _SlateLogState createState() => _SlateLogState();
}

class _SlateLogState extends State<SlateLog> with AutomaticKeepAliveClientMixin{
  late TextEditingController _fixController;
  late TextEditingController _noteController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fixController = TextEditingController(text: defaultScenes.data[0].fix);
    _noteController = TextEditingController(text: defaultScenes.data[0].note.toString());
  }

  @override
  void dispose() {
    _fixController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  List<Widget> objectsEditor(int index){
    List<Widget> chipList = defaultScenes.data[index].note.objects.asMap().map(
      (idx, tag) => MapEntry(
        idx,
        TextButton(
          onPressed: (){
            setState(() {
                tagButton(index, tag, idx);
              });},
          child: Chip(label: Text(tag)
          )),
      )
      ).values.toList();

    chipList.add(TextButton(
          
          onPressed: (){
            setState(() {
              defaultScenes.data[index].note.objects.add('new');
            });
          },
          child: const Chip(
            label: Icon(
                Icons.add,
                ),
            )
          ),
    );
    return chipList;
  }

  void tagButton(int index, String tag, int idx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm delete'),
        content: TextFormField(
          initialValue: defaultScenes.data[index].note.objects[idx],
          onSaved: ((value) {
            if (value != null) {
              defaultScenes.data[index].note.objects[idx] = value;
            }
          }),
          decoration: const InputDecoration(labelText: 'Tag'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // FormState.save();
              Navigator.of(context).pop(false);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              setState(
                  () => defaultScenes.data[index].note.objects.remove(tag));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    // .then(
    //   (confirmed) => {
    //     if (confirmed)
    //       {
    //         defaultScenes.data[index].note.objects.remove(tag),
    //         // Provider.of<Users>(context, listen: false).remove(user),
    //       },
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // TextFormField(
        //   decoration: InputDecoration(labelText: 'Key'),
        //   initialValue: defaultScenes.data[0].key,
        //   onChanged: (value) => widget.onScheduleItemChanged(defaultScenes.data[0].copyWith(key: value)),
        // ),
        // TextFormField(
        //   decoration: InputDecoration(labelText: 'Fix'),
        //   controller: _fixController,
        //   onChanged: (value) => widget.onScheduleItemChanged(defaultScenes.data[0].copyWith(fix: value)),
        // ),
        // TextFormField(
        //   decoration: InputDecoration(labelText: 'Note'),
        //   controller: _noteController,
        //   onChanged: (value) => widget.onScheduleItemChanged(defaultScenes.data[0].copyWith(note: Note.fromString(value))),
        // ),
        Wrap(
          spacing: 8.0,
          children: objectsEditor(0),
        ),
      ],
    );
  }
}
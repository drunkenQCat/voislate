import 'package:flutter/material.dart';

// give me a frame of listview page
class SlateLog extends StatefulWidget {
  @override
  _SlateLogState createState() => _SlateLogState();
}

class _SlateLogState extends State<SlateLog> {
  int _selectedIndex = 0;

  List<String> _items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_items[index]),
            selected: index == _selectedIndex,
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
          );
        },
      ),
    );
  }
}
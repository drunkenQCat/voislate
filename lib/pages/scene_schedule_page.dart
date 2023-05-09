import 'package:flutter/material.dart';

class SceneSchedule extends StatefulWidget {
  @override
  _SceneScheduleState createState() => _SceneScheduleState();
}

class _SceneScheduleState extends State<SceneSchedule> {
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
    return Row(
      children: [
        Expanded(
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
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: Text(
                _items[_selectedIndex],
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

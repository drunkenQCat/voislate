import 'package:flutter/material.dart';

class MapToTabs extends StatefulWidget {
  final Map<String, Widget> tabs;

  const MapToTabs({super.key, required this.tabs});

  @override
  _MapToTabsState createState() => _MapToTabsState();
}

class _MapToTabsState extends State<MapToTabs> {
  late List<String> _tabNames;

  @override
  void initState() {
    super.initState();
    _tabNames = widget.tabs.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: _tabNames.map((name) => Tab(text: name)).toList(),
          ),
        ),
        body: TabBarView(
          children: widget.tabs.values.toList(),
        ),
      ),
    );
  }
}

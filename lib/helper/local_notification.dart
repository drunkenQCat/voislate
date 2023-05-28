import 'dart:async';
import 'package:flutter/material.dart';

class DateChecker extends StatefulWidget {
  @override
  _DateCheckerState createState() => _DateCheckerState();
}

class _DateCheckerState extends State<DateChecker> {
  late DateTime _lastDate;

  @override
  void initState() {
    super.initState();
    _lastDate = DateTime.now();
    Timer.periodic(Duration(minutes: 1), (timer) {
      if (_lastDate.day != DateTime.now().day) {
        // Do something here
        print('The date has changed!');
      }
      _lastDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

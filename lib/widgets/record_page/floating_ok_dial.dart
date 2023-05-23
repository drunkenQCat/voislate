import 'package:flutter/material.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';

class FloatingOkDial extends StatelessWidget {
  const FloatingOkDial({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      child: const Text('OK'),
      speedDialChildren: <SpeedDialChild>[
        SpeedDialChild(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('声音可用'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          label: '声音可用',
          child: const Icon(Icons.gpp_good),
        ),
        SpeedDialChild(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('声音弃用'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          label: '声音弃用',
          child: const Icon(Icons.gpp_bad),
        ),
      ],
    );
  }
}
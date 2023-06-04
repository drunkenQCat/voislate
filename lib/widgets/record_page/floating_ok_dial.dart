import 'package:flutter/material.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';

import '../../models/slate_log_item.dart';

class TakeOkDial extends StatefulWidget {
  TkStatus tkStatus = TkStatus.notChecked;

  TakeOkDial({super.key, 
    required this.context,
  });

  final BuildContext context;

  @override
  State<TakeOkDial> createState() => _TakeOkDialState();
}

class _TakeOkDialState extends State<TakeOkDial> {

  Widget _buildTkStatusIcon() {
    switch (widget.tkStatus) {
      case TkStatus.notChecked:
        return const Icon(Icons.gpp_maybe);
      case TkStatus.ok:
        return const Icon(Icons.gpp_good);
      case TkStatus.bad:
        return const Icon(Icons.gpp_bad);
    }
  }
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      key: widget.key,
      speedDialChildren: <SpeedDialChild>[
        SpeedDialChild(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('声音可用'),
                duration: Duration(seconds: 1),
              ),
            );
            setState(() {
              widget.tkStatus = TkStatus.ok;
            });
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
            setState(() {
              widget.tkStatus = TkStatus.bad;
            });

          },
          label: '声音弃用',
          child: const Icon(Icons.gpp_bad),
        ),
      ],
      child: _buildTkStatusIcon(),
    );
  }
}
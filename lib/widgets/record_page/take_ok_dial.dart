import 'package:flutter/material.dart';
// import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../models/slate_log_item.dart';

// ignore: must_be_immutable
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
        return const Icon(Icons.headphones,);
      case TkStatus.ok:
        return const Icon(Icons.gpp_good,);
      case TkStatus.bad:
        return const Icon(Icons.hearing_disabled,);
    }
  }

  Color _getTkStatusColor(TkStatus status) {
    switch (status) {
      case TkStatus.notChecked: // changed enum name to TkStatus.notChecked
        return Colors.grey;
      case TkStatus.ok: // changed enum name to TkStatus.ok
        return Colors.green;
      case TkStatus.bad: // changed enum name to TkStatus.nice
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      key: widget.key,
      heroTag: 'tkStatus',
      direction: SpeedDialDirection.up,
      activeIcon: Icons.close,
      backgroundColor: _getTkStatusColor(widget.tkStatus),
      children: <SpeedDialChild>[
        SpeedDialChild(
          backgroundColor: Colors.red,
          onTap: () {
            setState(() {
              widget.tkStatus = TkStatus.bad;
            });

          },
          label: '声音弃',
          child: const Icon(Icons.hearing_disabled),
        ),
        SpeedDialChild(
          backgroundColor: Colors.green,
          onTap: () {
            setState(() {
              widget.tkStatus = TkStatus.ok;
            });
          },
          label: '声音可',
          child: const Icon(Icons.gpp_good),
        ),
      ],
      child: _buildTkStatusIcon(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/slate_num_notifier.dart';

// the button to increment the counter for every column， add and scroll different columns 
class IncrementCounterButton<T extends SlatePickerState> extends StatelessWidget {
  final VoidCallback onPressed;

  IncrementCounterButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (_, col, child) {
        return FloatingActionButton(
          onPressed: () {
            onPressed();
            col.scrollToNext();
          },
          tooltip: 'Increment',
          child: child,
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

class DecrementCounterButton <T extends SlatePickerState> extends StatelessWidget {
  final VoidCallback onPressed;

  DecrementCounterButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (_, col, child) {
        return FloatingActionButton(
          onPressed: () {
            onPressed();
            col.scrollToPrev();
          },
          tooltip: 'Decrement',
          child: child,
        );
      },
      child: const Icon(Icons.remove),
    );
  }
}
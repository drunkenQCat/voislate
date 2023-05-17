import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/slate_num_notifier.dart';

// the button to increment the counter for every column， add and scroll different columns 
class SliderValueController<T extends SlatePickerState> {

  final TextEditingController textCon;
  BuildContext context;
  VoidCallback? inc;
  VoidCallback? dec;
  final T col;


  SliderValueController({
    required this.context,
    required this.textCon,
    this.inc,
    this.dec,
    required this.col,
  });

  void valueInc(){
    inc?.call();
    textCon.clear();
    col.scrollToNext();
  }

  void valueDec(){
    dec?.call();
    textCon.clear();
    col.scrollToPrev();
  }

}

class IncrementCounterButton<T extends SlatePickerState> extends StatelessWidget{
  final VoidCallback onPressed;
  final TextEditingController textCon;


  IncrementCounterButton({
    required this.onPressed,
    required this.textCon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (_, col, child) {
        return FloatingActionButton.large(
          onPressed: () {
            onPressed();
            textCon.clear();
            col.scrollToNext();
          },
          tooltip: 'Increment',
          child: child,
        );
      },
      child: const Icon(Icons.add, ),
    );
  }
}

class DecrementCounterButton <T extends SlatePickerState> extends StatelessWidget {
  final VoidCallback onPressed;
  final TextEditingController textCon;

  DecrementCounterButton({
    required this.onPressed,
    required this.textCon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (_, col, child) {
        return FloatingActionButton.large(
          onPressed: () {
            onPressed();
            textCon.clear();
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
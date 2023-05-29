import 'package:flutter/material.dart';

import 'slate_num_notifier.dart';

// the button to increment the counter for every column， add and scroll different columns
// especiallly for volume key control
class ScrollValueController<T extends SlatePickerState> {
  final TextEditingController textCon;
  BuildContext context;
  VoidCallback? inc;
  VoidCallback? dec;
  final T col;

  ScrollValueController({
    required this.context,
    required this.textCon,
    this.inc,
    this.dec,
    required this.col,
  });

  void valueInc(bool isLink) {
    inc?.call();
    textCon.clear();
    col.scrollToNext(isLink);
  }

  void valueDec(bool isLink) {
    dec?.call();
    textCon.clear();
    col.scrollToPrev(isLink);
  }
}

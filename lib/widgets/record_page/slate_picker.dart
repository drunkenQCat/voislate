import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/slate_num_notifier.dart';

/// 自定义结果回调函数
/// V1:第一列选中的值
/// V2:第二列选中的值
/// V3:第三列选中的值
typedef ResultChanged<V1, V2, V3> = Function(V1 v1, V2 v2, V3 v3);

// notifier for every column

// The Picker for the slate
class SlatePicker extends StatefulWidget {
  // data for the three columns
  final List<String> ones;
  final List<String> twos;
  final List<String> threes;
  // in fact, the tags for the three columns
  final List<String> titles;

  // initial index for the three columns
  final int initialOneIndex;
  final int initialTwoIndex;
  final int initialThreeIndex;
  // state for the three columns
  SlateColumnOne? stateOne;
  SlateColumnTwo? stateTwo;
  SlateColumnThree? stateThree;

  // the visual pramters for the SlatePicker
  final double height;
  final double width;
  final double itemHeight;
  final Color itemBackgroundColor;

  // feed back the result to the main.dart
  final ResultChanged? resultChanged;

  // whether the picker is loop
  final bool isLoop;

  SlatePicker({
    Key? key,
    required this.ones,
    required this.twos,
    required this.threes,
    this.stateOne,
    this.stateTwo,
    this.stateThree,
    required this.titles,
    this.resultChanged,
    this.initialOneIndex = 0,
    this.initialTwoIndex = 0,
    this.initialThreeIndex = 0,
    this.height = 90,
    this.width = 300,
    this.itemHeight = 40,
    this.itemBackgroundColor = const Color(0xFFD1C4E9),
    this.isLoop = false,
  }) : super(key: key) {
    // 初始化 stateOne、stateTwo 和 stateThree
    assert(titles.length >= 3);
  }

  @override
  State<SlatePicker> createState() => _SlatePickerState();
}

class _SlatePickerState extends State<SlatePicker> {
  final double padding = 58;

  @override
  void initState() {
    super.initState();
    widget.stateOne = widget.stateOne ?? SlateColumnOne()
      ..init(widget.ones, widget.initialOneIndex);
    widget.stateTwo = widget.stateTwo ?? SlateColumnTwo()
      ..init(widget.twos, widget.initialTwoIndex);
    widget.stateThree = widget.stateThree ?? SlateColumnThree()
      ..init(widget.threes, widget.initialThreeIndex);
    // callback the result to the main.dart
    WidgetsBinding.instance.endOfFrame.then((_) {
      _resultChanged(
        widget.stateOne!.selected, 
        widget.stateTwo!.selected,
        widget.stateThree!.selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildPicker(
          widget.ones,
          widget.titles[0],
          (value) => _resultChanged(
              value, widget.stateTwo!.selected, widget.stateThree!.selected),
          widget.stateOne!.controller,
        ),
        VerticalSeparator(widget: widget, padding: padding),
        _buildPicker(
          widget.twos,
          widget.titles[1],
          (value) => _resultChanged(
              widget.stateOne!.selected, value, widget.stateThree!.selected),
          widget.stateTwo!.controller,
        ),
        VerticalSeparator(widget: widget, padding: padding),
        _buildPicker(
          widget.threes,
          widget.titles[2],
          (value) => _resultChanged(
              widget.stateOne!.selected, widget.stateTwo!.selected, value),
          widget.stateThree!.controller,
        ),
      ],
    );
  }

  _buildPicker(List data, String unit, ValueChanged valueChanged,
      FixedExtentScrollController controller) {
    return Container(
      height: widget.height + 10,
      width: widget.width / 3.4,
      child: Column(
        children: [
          Expanded(
            child: CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.5,
              scrollController: controller,
              useMagnifier: true,
              itemExtent: widget.itemHeight,
              looping: widget.isLoop,
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                background: widget.itemBackgroundColor.withAlpha(80),
              ),
              onSelectedItemChanged: (selectedIndex) {
                valueChanged(data[selectedIndex]);
              },
              children: data
                  .map(
                    (e) => Center(
                      child: Text(
                        '$e',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // SizedBox(height: 4),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF212121),
              fontWeight: FontWeight.w400,)),
        ],
      ),
    );
  }

  /// 刷新回调结果
  _resultChanged(v1, v2, v3) {
    if (widget.resultChanged != null) {
      widget.resultChanged!(v1, v2, v3);
    }
    widget.stateOne!.selected = v1;
    widget.stateTwo!.selected = v2;
    widget.stateThree!.selected = v3;
  }
}

class VerticalSeparator extends StatelessWidget {
  const VerticalSeparator({
    super.key,
    required this.widget,
    required this.padding,
  });

  final SlatePicker widget;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xffbdbdbd),
          width: 1,
          height: widget.height - padding,
        ),
        SizedBox(height: padding / 3),
      ],
    );
  }
}

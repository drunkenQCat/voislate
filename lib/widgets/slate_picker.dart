import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/slate_num_notifier.dart';

/// 自定义结果回调函数
/// V1:第一列选中的值
/// V2:第二列选中的值
/// V3:第三列选中的值
typedef ResultChanged<V1, V2, V3> = Function(V1 v1, V2 v2, V3 v3);

// 轮盘选择器
class SlatePicker extends StatefulWidget {
  // data for the three columns
  final List ones;
  final List twos;
  final List<String> threes;

  final List<String> titles;

  // initial index for the three columns
  final int initialOneIndex;
  final int initialTwoIndex;
  final int initialThreeIndex;

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
    required this.titles,
    this.resultChanged,
    this.initialOneIndex = 0,
    this.initialTwoIndex = 0,
    this.initialThreeIndex = 0,
    this.height = 100,
    this.width = 200,
    this.itemHeight = 40,
    this.itemBackgroundColor = const Color(0x0A0A4D),
    this.isLoop = true,
  })  : assert(titles.length >= 3),
        super(key: key);

  @override
  State<SlatePicker> createState() => _SlatePickerState();
}

class _SlatePickerState extends State<SlatePicker> {
  var selected1;
  var selected2;
  var selected3;
  final double padding = 58;
  // the scroll controller for the third column
  late FixedExtentScrollController _controller3;
  // listen to changes of the third column



  @override
  void initState() {
    super.initState();
    selected1 = widget.ones[widget.initialOneIndex];
    selected2 = widget.twos[widget.initialTwoIndex];
    selected3 = widget.threes[widget.initialThreeIndex];
    // some bind to column3
    _controller3 = FixedExtentScrollController(initialItem: widget.initialThreeIndex);
    final notifier = Provider.of<SlateNumNotifier>(context, listen: false);
    notifier.numList = widget.threes;
    notifier.selected = selected3;


    // callback the result to the main.dart
    WidgetsBinding.instance.endOfFrame.then((_) {
      _resultChanged(selected1, selected2, selected3);
    });
  }
  // make an api to change the selected3 value
  void changeSelected3(bool addOrSub) {
      var index = _getSelected3Index();
      if (addOrSub) {
        index++;
      } else {
        index--;
      }
      var newthree = widget.threes[index];
      _resultChanged(selected1, selected2, newthree);
  }

  // an function to get the index of selected value in the picker 
  int _getSelected3Index() {
    return widget.threes.indexOf(selected3);
  }

  // a function to scroll selected3 to the some value
  void _scrollSelected3To(String value) {
    var index = widget.threes.indexOf(value);
    _controller3.animateToItem(index, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildPicker(
          widget.ones,
          widget.titles[0],
          (value) => _resultChanged(value, selected2, selected3),
          FixedExtentScrollController(initialItem: widget.initialOneIndex),
        ),
        Container(
          color: Colors.black,
          width: 1,
          height: widget.height - padding,
        ),
        _buildPicker(
          widget.twos,
          widget.titles[1],
          (value) => _resultChanged(selected1, value, selected3),
          FixedExtentScrollController(initialItem: widget.initialTwoIndex),
        ),
        Container(
          color: Colors.black,
          width: 1,
          height: widget.height - padding,
        ),
        _buildPicker(
          widget.threes,
          widget.titles[2],
          (value) => _resultChanged(selected1, selected2, value),
          _controller3,
        ),
      ],
    );
  }

  _buildPicker(
      List data, String unit, ValueChanged valueChanged, FixedExtentScrollController controller) {
    return Container(
      height: widget.height,
      width: widget.width / 3,
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
          Text(unit),
        ],
      ),
    );
  }

  /// 刷新回调结果
  _resultChanged(v1, v2, v3) {
    if (widget.resultChanged != null) {
      widget.resultChanged!(v1, v2, v3);
    }
    setState(() {
      selected1 = v1;
      selected2 = v2;
      selected3 = v3;
    });
  }
}

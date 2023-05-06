import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 自定义结果回调函数
/// V1:第一列选中的值
/// V2:第二列选中的值
/// V3:第三列选中的值
typedef ResultChanged<V1, V2, V3> = Function(V1 v1, V2 v2, V3 v3);

// an inherited widget to pass the SlatePicker instance to the main.dart
class SlatePickerInherited extends InheritedWidget {
  final SlatePicker slatePicker;

  const SlatePickerInherited({
    Key? key,
    required this.slatePicker,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(SlatePickerInherited oldWidget) {
    return slatePicker != oldWidget.slatePicker;
  }
  static SlatePicker of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SlatePickerInherited>()!.slatePicker;
}

// 轮盘选择器
class SlatePicker extends StatefulWidget {
  /// 第一列数据
  final List ones;

  /// 第二列数据
  final List twos;

  /// 第三列数据
  final List threes;

  /// 列下方的标题
  final List<String> titles;

  /// 第一列初始显示数据的index，默认从0开始.
  final int initialOneIndex;

  /// 第二列初始显示数据的index，默认从0开始.
  final int initialTwoIndex;

  /// 第三列初始显示数据的index，默认从0开始.
  final int initialThreeIndex;

  /// 组件高度
  final double height;

  /// 组件宽度
  final double width;

  /// 中间数字的高度
  final double itemHeight;

  /// 轮盘背景色
  final Color itemBackgroundColor;

  /// 选中结果回调
  final ResultChanged? resultChanged;

  /// 轮盘是否循环，默认为true.
  final bool isLoop;

  const SlatePicker({
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
  void changeSelected3(bool addOrSub) => _SlatePickerState().changeSelected3(addOrSub);
}

class _SlatePickerState extends State<SlatePicker> {
  var selected1;
  var selected2;
  var selected3;
  final double padding = 58;

  @override
  void initState() {
    super.initState();
    selected1 = widget.ones[widget.initialOneIndex];
    selected2 = widget.twos[widget.initialTwoIndex];
    selected3 = widget.threes[widget.initialThreeIndex];
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildPicker(
          widget.ones,
          widget.titles[0],
          (value) => _resultChanged(value, selected2, selected3),
          widget.initialOneIndex,
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
          widget.initialTwoIndex,
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
          widget.initialThreeIndex,
        ),
      ],
    );
  }

  _buildPicker(
      List data, String unit, ValueChanged valueChanged, int initIndex) {
    return Container(
      height: widget.height,
      width: widget.width / 3,
      child: Column(
        children: [
          Expanded(
            child: CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.5,
              scrollController:
                  FixedExtentScrollController(initialItem: initIndex),
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

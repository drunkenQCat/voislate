import 'package:flutter/material.dart';


class MonoDirectionJoystick extends StatefulWidget {
  /// Height of the slider. Defaults to 70.
  final double height;

  /// Width of the slider. Defaults to 300.
  final double width;

  final double slideLength;

  final double initValue;

  /// The color of the background of the slider. Defaults to Colors.white.
  final Color backgroundColor;

  /// The color of the background of the slider when it has been slide to the end. By giving a value here, the background color
  /// will gradually change from backgroundColor to backgroundColorEnd when the user slides. Is not used by default.
  final Color? backgroundColorEnd;

  /// The color of the moving element of the slider. Defaults to Colors.blueAccent.
  final Color foregroundColor;

  /// The color of the icon on the moving element if icon is IconData. Defaults to Colors.white.
  final Color iconColor;

  /// The button widget used on the moving element of the slider. Defaults to Icon(Icons.chevron_right).
  final Widget sliderButtonContent;

  /// The shadow below the slider. Defaults to BoxShadow(color: Colors.black38, offset: Offset(0, 2),blurRadius: 2,spreadRadius: 0,).
  final BoxShadow? shadow;

  /// The text showed below the foreground. Used to specify the functionality to the user. Defaults to "Slide to confirm".
  final String text;

  /// The style of the text. Defaults to TextStyle(color: Colors.black26, fontWeight: FontWeight.bold,).
  final TextStyle? textStyle;

  /// The callback when slider is completed. This is the only required field.
  final VoidCallback onConfirmation;
  
  /// the callback when slider is canceled.
  final VoidCallback? onCancel;

  /// The callback when slider is pressed.
  final VoidCallback? onTapDown;

  /// The callback when slider is release.
  final VoidCallback? onTapUp;

  /// The shape of the moving element of the slider. Defaults to a circular border radius
  final BorderRadius? foregroundShape;

  /// The shape of the background of the slider. Defaults to a circular border radius
  final BorderRadius? backgroundShape;

  /// Stick the slider to the end
  final bool stickToEnd;

  const MonoDirectionJoystick({
    Key? key,
    this.height = 70,
    this.width = 300,
    this.backgroundColor = Colors.white,
    this.backgroundColorEnd,
    this.foregroundColor = Colors.blueAccent,
    this.iconColor = Colors.white,
    this.shadow,
    this.sliderButtonContent = const Icon(
      Icons.unfold_more,
      color: Colors.white,
      size: 35,
    ),
    this.text = "Slide to confirm",
    this.textStyle,
    required this.onConfirmation,
    this.onCancel,
    this.onTapDown,
    this.onTapUp,
    this.foregroundShape,
    this.backgroundShape,
    this.stickToEnd = false,

  }) : assert(height >= 25 && width >= 180),
        slideLength = width - height,
        initValue = (width - height) / 2,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MonoDirectionJoystickState();
  }
}

class MonoDirectionJoystickState extends State<MonoDirectionJoystick> {
  late double _position = widget.initValue;
  int _duration = 0;

  double getPosition() {
    if (_position < 0) {
      return 0;
    } else if (_position > widget.slideLength) {
      return widget.slideLength;
    } else {
      return _position;
    }
  }

  void updatePosition(details) {
    if (details is DragEndDetails) {
      setState(() {
        _duration = 200;
        if (widget.stickToEnd && _position > widget.slideLength) {
          _position = widget.slideLength;
        } else {
          _position = widget.initValue;
        }
      });
    } else if (details is DragUpdateDetails) {
      setState(() {
        _duration = 0;
        _position = details.localPosition.dx + widget.initValue;
      });
    }
  }

  void sliderReleased(details) {
    if (_position > widget.slideLength) {
      widget.onConfirmation();
    }else if(_position < 0 && widget.onCancel != null ){
      widget.onCancel!();
    }
    updatePosition(details);
  }

  Color calculateBackground() {
    if (widget.backgroundColorEnd != null) {
      double percent;

      // calculates the percentage of the position of the slider
      if (_position > widget.slideLength) {
        percent = 1.0;
      } else if (_position / (widget.slideLength) > 0) {
        percent = _position / (widget.slideLength);
      } else {
        percent = 0.0;
      }

      int red = widget.backgroundColorEnd!.red;
      int green = widget.backgroundColorEnd!.green;
      int blue = widget.backgroundColorEnd!.blue;

      return Color.alphaBlend(Color.fromRGBO(red, green, blue, percent), widget.backgroundColor);
    } else {
      return widget.backgroundColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    BoxShadow shadow;
    if (widget.shadow == null) {
      shadow = BoxShadow(
        color: Colors.black38,
        offset: Offset(0, 2),
        blurRadius: 2,
        spreadRadius: 0,
      );
    } else {
      shadow = widget.shadow!;
    }

    TextStyle style;
    if (widget.textStyle == null) {
      style = TextStyle(
        color: Colors.black26,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = widget.textStyle!;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: _duration),
      curve: Curves.easeInExpo,
      height: widget.height,
      width: widget.width,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: widget.backgroundShape ?? BorderRadius.all(Radius.circular(widget.height)),
        color: widget.backgroundColorEnd != null ? this.calculateBackground() : widget.backgroundColor,
        boxShadow: <BoxShadow>[shadow],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: widget.height / 2,
            child: AnimatedContainer(
              height: widget.height - 10,
              width: getPosition(),
              duration: Duration(milliseconds: _duration),
              curve: Curves.ease,
              decoration: BoxDecoration(
                borderRadius: widget.backgroundShape ?? BorderRadius.all(Radius.circular(widget.height)),
                color: widget.backgroundColorEnd != null ? this.calculateBackground() : widget.backgroundColor,
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                  Icons.cancel,
                  size: 48,
                  color: Colors.red[300],
                ),
                SizedBox(
                  height: 5,
                ),
                Icon(
                  Icons.add,
                  size: 48,
                  color: Colors.green[300],
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: _duration),
            curve: Curves.easeInExpo,
            left: getPosition(),
            top: 0,
            child: GestureDetector(
              onTapDown: (_) => widget.onTapDown != null ? widget.onTapDown!() : null,
              onTapUp: (_) => widget.onTapUp != null ? widget.onTapUp!() : null,
              onPanUpdate: (details) {
                updatePosition(details);
              },
              onPanEnd: (details) {
                if (widget.onTapUp != null) widget.onTapUp!();
                sliderReleased(details);
              },
              child: Container(
                height: widget.height - 10,
                width: widget.height - 10,
                decoration: BoxDecoration(
                  borderRadius: widget.foregroundShape ?? BorderRadius.all(Radius.circular(widget.height / 2)),
                  color: widget.foregroundColor,
                ),
                child: RotatedBox(quarterTurns: 1, child: widget.sliderButtonContent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


typedef EasyCallback<P, R> = R Function(P param);
class RainbowText extends StatefulWidget {
  final List<Color> colors;
  final String text;
  final bool loop;

  const RainbowText({Key key, this.colors, this.text, this.loop = false})
      : assert(colors != null),
        super(key: key);

  @override
  _RainbowTextState createState() => _RainbowTextState();
}

class _RainbowTextState extends State<RainbowText>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  Size _textSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    if (widget.loop) {
      _animationController.forward();
      _animationController.addStatusListener((status) {
        if (widget.loop) {
          if (status == AnimationStatus.completed) {
            _animationController.value = 0;
            _animationController.forward();
          }
        }
      });
    }
  }

  void calculateTextWidth() {
    var textPainter = TextPainter(
        text: TextSpan(text: widget.text, style: TextStyle(fontSize: 20)),
        textDirection: TextDirection.ltr);
    textPainter.layout();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RainbowText oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void onSizeCallBack(Size size) {
    if (_textSize != null && _textSize == size) {
      return;
    }
    _textSize = size;
    print("onSizeCallBack:" + _textSize.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (!_animationController.isAnimating) {
      _animationController.value = 0;
      _animationController.forward();
    }
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget child) {
        var width = _textSize.width;
        TextStyle textStyle = TextStyle(fontSize: 20);
        if (widget.colors.length > 0 && width > 0) {
          Shader shader = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: widget.colors,
              tileMode: TileMode.repeated)
              .createShader(Rect.fromLTWH(
              _animationController.value * width, 0, width, 0));
          var foreground = Paint();
          foreground.shader = shader;
          textStyle = textStyle.merge(TextStyle(foreground: foreground));
        }
        return RepaintBoundary(
            child: CustomPaint(
                painter: _SizeGetPainter(onSizeCallBack, tag: widget.text),
                child: Text(
                  widget.text,
                  style: textStyle,
                )));
      },
    );
  }
}

class _SizeGetPainter extends CustomPainter {
  final EasyCallback<Size, void> sizeCallBack;

  final dynamic tag;

  _SizeGetPainter(this.sizeCallBack, {this.tag = ""});

  @override
  void paint(Canvas canvas, Size size) {
    if (sizeCallBack != null) {
      sizeCallBack(size);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is _SizeGetPainter) {
      return oldDelegate.tag != tag && tag != "";
    }
    return true;
  }
}

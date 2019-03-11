import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DiffScaleText extends StatefulWidget {
  @override
  _DiffScaleTextState createState() => _DiffScaleTextState();
}

class _DiffScaleTextState extends State<DiffScaleText>
    with TickerProviderStateMixin<DiffScaleText> {
  AnimationController _animationController;

  String text;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 800));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.value = 0;
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (text == "西出阳关无故人") {
      text = "太阳打西边出来了";
    } else if (text == null) {
      text = "西出阳关无故人";
    }
    return Container(
      color: Colors.brown,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          return RepaintBoundary(
              child: CustomPaint(
            size: Size(200, 60),
            foregroundPainter: _DiffText(
                text: text,
                textStyle: TextStyle(fontSize: 26, color: Color(0xff000000)),
                progress: _animationController.value),
          ));
        },
      ),
    );
  }
}

class _DiffText extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final double progress;
  String _oldText;
  List<_TextLayoutInfo> _textLayoutInfo = [];
  List<_TextLayoutInfo> _oldTextLayoutInfo = [];

  _DiffText({this.text, this.textStyle, this.progress = 0})
      : assert(text != null),
        assert(textStyle != null);

  @override
  void paint(Canvas canvas, Size size) {
    if (_textLayoutInfo.length == 0) {
      calculateLayoutInfo(text, _textLayoutInfo);
    }
    for (_TextLayoutInfo _textLayoutInfo in _textLayoutInfo) {
      if (!_textLayoutInfo.needMove) {
        var textPaint = Paint();
        textPaint.color = textStyle.color.withAlpha(
            (textStyle.color.alpha * progress).floor());
        var textPainter = TextPainter(text: TextSpan(text: _textLayoutInfo.text,
            style: textStyle.merge(TextStyle(
                color: null,
                foreground: textPaint,textBaseline:TextBaseline.ideographic))),
            textDirection: TextDirection.ltr);
        textPainter.textAlign = TextAlign.center;
        textPainter.textScaleFactor = progress;
        textPainter.textDirection = TextDirection.ltr;
        textPainter.layout(minWidth: _textLayoutInfo.width);
        textPainter.paint(canvas, Offset(_textLayoutInfo.offsetX, (size.height-textPainter.computeDistanceToActualBaseline(TextBaseline.ideographic))/2));
      }
    }
    if (_oldTextLayoutInfo != null && _oldTextLayoutInfo.length > 0) {
      for (_TextLayoutInfo _oldTextLayoutInfo in _oldTextLayoutInfo) {

      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is _DiffText) {
      String oldFrameText = oldDelegate.text;
      if (oldFrameText == text) {
        this._oldText = oldDelegate._oldText;
        this._oldTextLayoutInfo = oldDelegate._oldTextLayoutInfo;
        this._textLayoutInfo = oldDelegate._textLayoutInfo;
        if (this.progress == oldDelegate.progress) {
          return false;
        }
      } else {
        this._oldText = oldDelegate.text;
        calculateLayoutInfo(text, _textLayoutInfo);
        calculateLayoutInfo(_oldText, _oldTextLayoutInfo);
        calculateMove();
      }
    }
    return true;
  }

  void calculateLayoutInfo(String text, List<_TextLayoutInfo> list) {
    list.clear();
    double offset = 0;
    for (int i = 0; i < text.length; i++) {
      int charAt = text.codeUnitAt(i);
      var textPainter = TextPainter(
          text: TextSpan(text: String.fromCharCode(charAt), style: textStyle),
          textDirection: TextDirection.ltr);
      textPainter.layout();
      var textLayoutInfo = _TextLayoutInfo();
      textLayoutInfo.text = String.fromCharCode(charAt);
      textLayoutInfo.offsetX = offset;
      textLayoutInfo.width = textPainter.width;
      textLayoutInfo.height = textPainter.height;
      textLayoutInfo.baseline = textPainter.computeDistanceToActualBaseline(TextBaseline.ideographic);
      offset += textPainter.width;
      list.add(textLayoutInfo);
    }
  }

  void calculateMove() {
    if (_oldTextLayoutInfo == null || _oldTextLayoutInfo.length == 0) {
      return;
    }
    if (_textLayoutInfo == null || _textLayoutInfo.length == 0) {
      return;
    }

    for (_TextLayoutInfo oldText in _oldTextLayoutInfo) {
      for (_TextLayoutInfo text in _textLayoutInfo) {
        if (!text.needMove && text.text == oldText.text) {
          text.fromX = oldText.offsetX;
          oldText.toX = text.offsetX;
          text.needMove = true;
          oldText.needMove = true;
        }
      }
    }
  }
}

class _TextLayoutInfo {
  String text;
  double offsetX;
  double baseline;
  double width;
  double height;
  double fromX = 0;
  double toX = 0;
  bool needMove = false;
}

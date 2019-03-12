import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DiffScaleText extends StatefulWidget {

  final String text;

  const DiffScaleText({Key key, this.text})
      : assert(text != null),
        super(key: key);

  @override
  _DiffScaleTextState createState() => _DiffScaleTextState();
}

class _DiffScaleTextState extends State<DiffScaleText>
    with TickerProviderStateMixin<DiffScaleText> {
  AnimationController _animationController;


  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _animationController.addStatusListener((status) {});
  }

  @override
  void didUpdateWidget(DiffScaleText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      if (!_animationController.isAnimating) {
        _animationController.value = 0;
        _animationController.forward();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget child) {
        return RepaintBoundary(
            child: CustomPaint(
              child: Text(widget.text,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.transparent,
                  ),
                  maxLines: 1,
                  textDirection: TextDirection.ltr),
              foregroundPainter: _DiffText(
                  text: widget.text,
                  textStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  progress: _animationController.value),
            ));
      },
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
  Alignment alignment;

  _DiffText({this.text,
    this.textStyle,
    this.progress = 1,
    this.alignment = Alignment.center})
      : assert(text != null),
        assert(textStyle != null);

  @override
  void paint(Canvas canvas, Size size) {
    double percent = Math.max(0, Math.min(1, progress));
    if (_textLayoutInfo.length == 0) {
      calculateLayoutInfo(text, _textLayoutInfo);
    }
    canvas.save();
    if (_oldTextLayoutInfo != null && _oldTextLayoutInfo.length > 0) {
      for (_TextLayoutInfo _oldTextLayoutInfo in _oldTextLayoutInfo) {
        if (_oldTextLayoutInfo.needMove) {
          double p = percent * 2;
          p = p > 1 ? 1 : p;
          var textPainter = TextPainter(
              text: TextSpan(text: _oldTextLayoutInfo.text, style: textStyle),
              textDirection: TextDirection.ltr);
          textPainter.textDirection = TextDirection.ltr;
          textPainter.textAlign = TextAlign.center;
          textPainter.layout();
          textPainter.paint(
              canvas,
              Offset(
                  _oldTextLayoutInfo.offsetX -
                      (_oldTextLayoutInfo.offsetX - _oldTextLayoutInfo.toX) * p,
                  _oldTextLayoutInfo.offsetY));
        } else {
          var textPaint = Paint();
          textPaint.color = textStyle.color
              .withAlpha((textStyle.color.alpha * percent).floor());
          var textPainter = TextPainter(
              text: TextSpan(
                  text: _oldTextLayoutInfo.text,
                  style: textStyle.merge(TextStyle(
                      color: null,
                      foreground: textPaint,
                      textBaseline: TextBaseline.ideographic))),
              textDirection: TextDirection.ltr);
          textPainter.textAlign = TextAlign.center;
          textPainter.textScaleFactor = 1 - percent;
          textPainter.textDirection = TextDirection.ltr;
          textPainter.layout();
          textPainter.paint(canvas,
              Offset(_oldTextLayoutInfo.offsetX, _oldTextLayoutInfo.offsetY));
        }
      }
    } else {
      percent = 1;
    }
    for (_TextLayoutInfo _textLayoutInfo in _textLayoutInfo) {
      if (!_textLayoutInfo.needMove) {
        var textPaint = Paint();
        textPaint.color = textStyle.color
            .withAlpha((textStyle.color.alpha * percent).floor());
        var textPainter = TextPainter(
            text: TextSpan(
                text: _textLayoutInfo.text,
                style: textStyle.merge(TextStyle(
                    color: null,
                    foreground: textPaint,
                    textBaseline: TextBaseline.ideographic))),
            textDirection: TextDirection.ltr);
        textPainter.textAlign = TextAlign.center;
        textPainter.textScaleFactor = percent;
        textPainter.textDirection = TextDirection.ltr;
        textPainter.layout();
        textPainter.paint(
            canvas, Offset(_textLayoutInfo.offsetX, _textLayoutInfo.offsetY));
      }
    }
    canvas.restore();
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

    TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1);
    textPainter.layout();
    for (int i = 0; i < text.length; i++) {
      var forCaret =
      textPainter.getOffsetForCaret(TextPosition(offset: i), Rect.zero);
      var offsetX = forCaret.dx;
      if (i > 0 && offsetX == 0) {
        break;
      }
      var textLayoutInfo = _TextLayoutInfo();
      textLayoutInfo.text = text.substring(i, i + 1);
      textLayoutInfo.offsetX = offsetX;
      textLayoutInfo.offsetY = forCaret.dy;
      textLayoutInfo.width = 0;
      textLayoutInfo.height = textPainter.height;
      textLayoutInfo.baseline =
          textPainter.computeDistanceToActualBaseline(TextBaseline.ideographic);
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
        if (!text.needMove && !oldText.needMove && text.text == oldText.text) {
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
  double offsetY;
  double baseline;
  double width;
  double height;
  double fromX = 0;
  double toX = 0;
  bool needMove = false;
}

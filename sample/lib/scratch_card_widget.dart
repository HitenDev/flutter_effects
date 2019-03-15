import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef MaskPainter = Function(Canvas canvas, Size size, Offset offset);

class ScratchCardWidget extends StatefulWidget {
  final Widget child;
  final MaskPainter foreground;
  final double strokeWidth;

  final double threshold;

  const ScratchCardWidget(
      {Key key, this.child, this.foreground, this.strokeWidth, this.threshold})
      : assert(foreground != null),
        super(key: key);

  @override
  _ScratchCardWidgetState createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  Path _path = Path();

  bool _complete = false;

  GlobalKey scratchCardRenderKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (detail) {
          _path.lineTo(detail.globalPosition.dx, detail.globalPosition.dy);
          setState(() {});
        },
        onPanStart: (detail) {
          _path.moveTo(detail.globalPosition.dx, detail.globalPosition.dy);
          setState(() {});
        },
        onPanEnd: (detail) {
          _ScratchCardRenderObject _scratchCardRenderObject =
              scratchCardRenderKey.currentContext.findRenderObject();
          _scratchCardRenderObject.eraserComplete().then((complete) {
            if (complete) {
              setState(() {
                _complete = true;
              });
            }
          });
        },
        child: _complete
            ? widget.child
            : RepaintBoundary(
                child: _ScratchCardRenderWidget(
                key: scratchCardRenderKey,
                child: widget.child,
                path: _path,
                foreground: widget.foreground,
                strokeWidth: widget.strokeWidth,
                threshold: widget.threshold,
              )));
  }
}

class _ScratchCardRenderWidget extends SingleChildRenderObjectWidget {
  final Path path;
  final MaskPainter foreground;
  final double strokeWidth;
  final double threshold;

  const _ScratchCardRenderWidget(
      {Key key,
      Widget child,
      this.path,
      this.foreground,
      this.strokeWidth,
      this.threshold})
      : super(key: key, child: child);

  @override
  _ScratchCardRenderObject createRenderObject(BuildContext context) {
    return _ScratchCardRenderObject(
        path: path,
        foreground: foreground,
        strokeWidth: strokeWidth,
        threshold: threshold);
  }

  @override
  void updateRenderObject(
      BuildContext context, _ScratchCardRenderObject renderObject) {
    renderObject.path = path;
    renderObject.strokeWidth = strokeWidth;
    renderObject.foreground = foreground;
    renderObject.threshold = threshold;
    renderObject.updatePoint();
  }
}

class _ScratchCardRenderObject extends RenderProxyBox {
  _ScratchCardRenderObject(
      {RenderBox child,
      this.path,
      this.foreground,
      this.strokeWidth,
      this.threshold = 0.66})
      : assert(threshold > 0 && threshold <= 1),
        super(child);

  MaskPainter foreground;

  Path path;

  double strokeWidth;

  double threshold;

  void updatePoint() {
    markNeedsPaint();
  }

  Future<bool> eraserComplete() async {
    var pictureRecorder = PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    foreground(canvas, size, Offset.zero);
    var eraserPaint = Paint();
    eraserPaint.color = Colors.transparent;
    eraserPaint.style = PaintingStyle.stroke;
    eraserPaint.strokeWidth = strokeWidth == null ? 20 : strokeWidth;
    eraserPaint.strokeCap = StrokeCap.round;
    eraserPaint.strokeJoin = StrokeJoin.round;
    eraserPaint.blendMode = BlendMode.dstIn;
    eraserPaint.isAntiAlias = true;
    if (path != null) {
      var toGlobal = localToGlobal(Offset(0, 0));
      var _path = path.shift(-toGlobal);
      canvas.drawPath(_path, eraserPaint);
    }
    canvas.restore();
    var picture = pictureRecorder.endRecording();
    var image = await picture.toImage(size.width.toInt(), size.height.toInt());
    var byteData = await image.toByteData();
    int pixelCount = 0;
    int maxCount = (size.width * size.height * threshold).toInt();
    for (int index = 0; index < size.width * size.height; index++) {
      int i = index * 4;
      int r = byteData.getUint8(i);
      int g = byteData.getUint8(i + 1);
      int b = byteData.getUint8(i + 2);
      int a = byteData.getUint8(i + 3);
      if (r == 0 && g == 0 && b == 0 && a == 0) {
        pixelCount++;
      }
      if (pixelCount > maxCount) {
        return true;
      }
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    context.canvas.saveLayer(
        Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height), Paint());
    context.canvas.translate(offset.dx, offset.dy);
    foreground(context.canvas, size, offset);
    var eraserPaint = Paint();
    eraserPaint.color = Colors.transparent;
    eraserPaint.style = PaintingStyle.stroke;
    eraserPaint.strokeWidth = strokeWidth == null ? 20 : strokeWidth;
    eraserPaint.strokeCap = StrokeCap.round;
    eraserPaint.strokeJoin = StrokeJoin.round;
    eraserPaint.blendMode = BlendMode.dstIn;
    eraserPaint.isAntiAlias = true;
    if (path != null) {
      var toGlobal = localToGlobal(Offset(0, 0));
      var _path = path.shift(-toGlobal);
      context.canvas.drawPath(_path, eraserPaint);
    }
    context.canvas.restore();
  }
}

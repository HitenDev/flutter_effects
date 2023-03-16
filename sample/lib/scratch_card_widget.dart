import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef MaskPainter = Function(Canvas canvas, Size size, Offset offset);

class ScratchCardWidget extends StatefulWidget {
  final Widget child;
  final MaskPainter foreground;
  final double strokeWidth;

  final double threshold;

  const ScratchCardWidget(
      {super.key,
      required this.child,
      required this.foreground,
      required this.strokeWidth,
      required this.threshold});

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  final Path _path = Path();

  bool _complete = false;

  GlobalKey scratchCardRenderKey = GlobalKey();

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
          _ScratchCardRenderObject? scratchCardRenderObject =
              scratchCardRenderKey.currentContext?.findRenderObject()
                  as _ScratchCardRenderObject?;
          scratchCardRenderObject?.eraserComplete().then((complete) {
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
                path: _path,
                foreground: widget.foreground,
                strokeWidth: widget.strokeWidth,
                threshold: widget.threshold,
                child: widget.child,
              )));
  }
}

class _ScratchCardRenderWidget extends SingleChildRenderObjectWidget {
  final Path path;
  final MaskPainter foreground;
  final double strokeWidth;
  final double threshold;

  const _ScratchCardRenderWidget(
      {Key? key,
      required Widget child,
      required this.path,
      required this.foreground,
      required this.strokeWidth,
      required this.threshold})
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
      {RenderBox? child,
      this.path,
      required this.foreground,
      this.strokeWidth,
      this.threshold = 0.66})
      : assert(threshold > 0 && threshold <= 1),
        super(child);

  MaskPainter foreground;

  Path? path;

  double? strokeWidth;

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
    eraserPaint.strokeWidth = strokeWidth ?? 20;
    eraserPaint.strokeCap = StrokeCap.round;
    eraserPaint.strokeJoin = StrokeJoin.round;
    eraserPaint.blendMode = BlendMode.dstIn;
    eraserPaint.isAntiAlias = true;
    if (path != null) {
      var toGlobal = localToGlobal(const Offset(0, 0));
      var shiftPath = path!.shift(-toGlobal);
      canvas.drawPath(shiftPath, eraserPaint);
    }
    canvas.restore();
    var picture = pictureRecorder.endRecording();
    var image = await picture.toImage(size.width.toInt(), size.height.toInt());
    var byteData = await image.toByteData();
    int pixelCount = 0;
    int maxCount = (size.width * size.height * threshold).toInt();
    if (byteData != null) {
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
    eraserPaint.strokeWidth = strokeWidth ?? 20;
    eraserPaint.strokeCap = StrokeCap.round;
    eraserPaint.strokeJoin = StrokeJoin.round;
    eraserPaint.blendMode = BlendMode.dstIn;
    eraserPaint.isAntiAlias = true;
    if (path != null) {
      var toGlobal = localToGlobal(const Offset(0, 0));
      var shiftPath = path!.shift(-toGlobal);
      context.canvas.drawPath(shiftPath, eraserPaint);
    }
    context.canvas.restore();
  }
}

import 'dart:typed_data';
import 'dart:ui';

import 'package:anvil_effect/pixel_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ExplosionWidget extends StatefulWidget {
  final Widget child;

  const ExplosionWidget({Key key, this.child}) : super(key: key);

  @override
  _ExplosionWidgetState createState() => _ExplosionWidgetState();
}

class _ExplosionWidgetState extends State<ExplosionWidget> {
  ByteData _byteData;
  Size _imageSize;

  GlobalKey globalKey = GlobalKey();

  void onTap() {
    if (_byteData == null || _imageSize == null) {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      boundary.toImage().then((image) {
        _imageSize = Size(image.width.toDouble(), image.height.toDouble());
        image.toByteData().then((byteData) {
          _byteData = byteData;
          setState(() {});
        });
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ExplosionRenderObjectWidget(
        key: globalKey,
        child: widget.child,
        byteData: _byteData,
        imageSize: _imageSize,
      ),
    );
  }
}

class ExplosionRenderObjectWidget extends RepaintBoundary {
  final ByteData byteData;
  final Size imageSize;

  const ExplosionRenderObjectWidget(
      {Key key, Widget child, this.byteData, this.imageSize})
      : super(key: key, child: child);

  @override
  RenderRepaintBoundary createRenderObject(BuildContext context) =>
      _ExplosionRenderObject(byteData: byteData, imageSize: imageSize);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
  }
}

class _ExplosionRenderObject extends RenderRepaintBoundary {
  final ByteData byteData;
  final Size imageSize;

  _ExplosionRenderObject({this.byteData, this.imageSize, RenderBox child})
      : super(child: child);

  @override
  void paint(PaintingContext context, Offset offset) {
    if (byteData != null && imageSize != null) {
      var color = getColorByPixel(byteData, imageSize, Offset(240, 50));
      context.canvas
          .drawRect(Rect.fromLTWH(0, 0, 10, 10), Paint()..color = color);
    } else {
      if (child != null) {
        context.paintChild(child, offset);
      }
    }
  }
}

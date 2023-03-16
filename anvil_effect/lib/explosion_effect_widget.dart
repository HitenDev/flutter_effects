import 'dart:math' as math;
import 'dart:typed_data';

import 'package:anvil_effect/pixel_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExplosionWidget extends StatefulWidget {
  final Widget? child;
  final Rect? bound;
  final String tag;

  const ExplosionWidget({super.key, this.child, this.bound, required this.tag});

  @override
  State<ExplosionWidget> createState() => _ExplosionWidgetState();
}

class _ExplosionWidgetState extends State<ExplosionWidget>
    with SingleTickerProviderStateMixin {
  ByteData? _byteData;
  Size? _imageSize;

  late AnimationController _animationController;

  late GlobalObjectKey globalKey;

  @override
  void initState() {
    super.initState();
    globalKey = GlobalObjectKey(widget.tag);
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  void onTap() {
    if (_byteData == null || _imageSize == null) {
      final boundary = globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      boundary?.toImage().then((image) {
        _imageSize = Size(image.width.toDouble(), image.height.toDouble());
        image.toByteData().then((byteData) {
          _byteData = byteData;
          _animationController.value = 0;
          _animationController.forward();
          setState(() {});
        });
      });
    } else {
      _animationController.value = 0;
      _animationController.forward();
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(ExplosionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tag != oldWidget.tag) {
      _byteData = null;
      _imageSize = null;
      globalKey = GlobalObjectKey(widget.tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ExplosionRenderObjectWidget(
                    key: globalKey,
                    bound: widget.bound,
                    byteData: _byteData,
                    imageSize: _imageSize,
                    progress: _animationController.value,
                    child: widget.child);
              }),
        ));
  }
}

class ExplosionRenderObjectWidget extends RepaintBoundary {
  final ByteData? byteData;
  final Size? imageSize;
  final double? progress;
  final Rect? bound;

  const ExplosionRenderObjectWidget(
      {Key? key,
      Widget? child,
      this.byteData,
      this.imageSize,
      this.progress,
      this.bound})
      : super(key: key, child: child);

  @override
  ExplosionRenderObject createRenderObject(BuildContext context) =>
      ExplosionRenderObject(
          byteData: byteData, imageSize: imageSize, bound: bound);

  @override
  void updateRenderObject(
      BuildContext context, ExplosionRenderObject renderObject) {
    renderObject.update(byteData, imageSize, progress);
  }
}

class ExplosionRenderObject extends RenderRepaintBoundary {
  ByteData? byteData;
  Size? imageSize;
  double progress = 0;
  List<_Particle> _particles = [];
  Rect? bound;

  ExplosionRenderObject(
      {this.byteData, this.imageSize, this.bound, RenderBox? child})
      : super(child: child);

  void update(ByteData? byteData, Size? imageSize, double? progress) {
    this.byteData = byteData;
    this.imageSize = imageSize;
    this.progress = progress ?? 0;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (byteData != null &&
        imageSize != null &&
        progress != 0 &&
        progress != 1) {
      if (_particles.isEmpty) {
        bound ??= Rect.fromLTWH(0, 0, size.width, size.height * 2);
        _particles = _initParticleList(bound!, byteData!, imageSize!);
      }
      _draw(context.canvas, _particles, progress);
    } else {
      if (child != null) {
        context.paintChild(child!, offset);
      }
    }
  }
}

const double kEndValue = 1.4;
const double V = 2;
const double X = 5;
const double Y = 20;
const double W = 1;

List<_Particle> _initParticleList(
    Rect bound, ByteData byteData, Size imageSize) {
  int partLen = 15;
  List<_Particle> particles = List.filled(partLen * partLen, _Particle());
  math.Random random = math.Random(DateTime.now().millisecondsSinceEpoch);
  int w = imageSize.width ~/ (partLen + 2);
  int h = imageSize.height ~/ (partLen + 2);
  for (int i = 0; i < partLen; i++) {
    for (int j = 0; j < partLen; j++) {
      particles[(i * partLen) + j] = _generateParticle(
          getColorByPixel(byteData, imageSize,
              Offset((j + 1) * w.toDouble(), (i + 1) * h.toDouble())),
          random,
          bound);
    }
  }
  return particles;
}

bool _draw(Canvas canvas, List<_Particle> particles, double progress) {
  Paint paint = Paint();
  for (int i = 0; i < particles.length; i++) {
    _Particle particle = particles[i];
    particle.advance(progress);
    if (particle.alpha > 0) {
      paint.color = particle.color
          .withAlpha((particle.color.alpha * particle.alpha).toInt());
      canvas.drawCircle(
          Offset(particle.cx, particle.cy), particle.radius, paint);
    }
  }
  return true;
}

_Particle _generateParticle(Color color, math.Random random, Rect bound) {
  _Particle particle = _Particle();
  particle.color = color;
  particle.radius = V;
  if (random.nextDouble() < 0.2) {
    particle.baseRadius = V + ((X - V) * random.nextDouble());
  } else {
    particle.baseRadius = W + ((V - W) * random.nextDouble());
  }
  double nextDouble = random.nextDouble();
  particle.top = bound.height * ((0.18 * random.nextDouble()) + 0.2);
  particle.top = nextDouble < 0.2
      ? particle.top
      : particle.top + ((particle.top * 0.2) * random.nextDouble());
  particle.bottom = (bound.height * (random.nextDouble() - 0.5)) * 1.8;
  double f = nextDouble < 0.2
      ? particle.bottom
      : nextDouble < 0.8
          ? particle.bottom * 0.6
          : particle.bottom * 0.3;
  particle.bottom = f;
  particle.mag = 4.0 * particle.top / particle.bottom;
  particle.neg = (-particle.mag) / particle.bottom;
  f = bound.center.dx + (Y * (random.nextDouble() - 0.5));
  particle.baseCx = f;
  particle.cx = f;
  f = bound.center.dy + (Y * (random.nextDouble() - 0.5));
  particle.baseCy = f;
  particle.cy = f;
  particle.life = kEndValue / 10 * random.nextDouble();
  particle.overflow = 0.4 * random.nextDouble();
  particle.alpha = 1;
  return particle;
}

class _Particle {
  double alpha = 0;
  Color color = Colors.black;
  double cx = 0;
  double cy = 0;
  double radius = 0;
  double baseCx = 0;
  double baseCy = 0;
  double baseRadius = 0;
  double top = 0;
  double bottom = 0;
  double mag = 0;
  double neg = 0;
  double life = 0;
  double overflow = 0;

  void advance(double factor) {
    double f = 0;
    double normalization = factor / kEndValue;
    if (normalization < life || normalization > 1 - overflow) {
      alpha = 0;
      return;
    }
    normalization = (normalization - life) / (1 - life - overflow);
    double f2 = normalization * kEndValue;
    if (normalization >= 0.7) {
      f = (normalization - 0.7) / 0.3;
    }
    alpha = 1 - f;
    f = bottom * f2;
    cx = baseCx + f;
    cy = (baseCy - neg * math.pow(f, 2.0)) - f * mag;
    radius = V + (baseRadius - V) * f2;
  }
}

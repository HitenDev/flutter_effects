import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnvilEffectWidget extends StatefulWidget {
  final Widget child;

  const AnvilEffectWidget({super.key, required this.child});

  @override
  State<AnvilEffectWidget> createState() => _AnvilEffectWidgetState();
}

class _AnvilEffectWidgetState extends State<AnvilEffectWidget>
    with SingleTickerProviderStateMixin {
  late List<Image> _effectImages;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _effectImages = <Image>[];
    for (int i = 0; i <= 51; i++) {
      var str = i.toString();
      if (str.length == 1) {
        str = "0$str";
      }
      _effectImages.add(Image.asset(
        "assets/images/wenzi00$str.png",
        package: "anvil_effect",
      ));
    }
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Timer.periodic(const Duration(seconds: 1), (timer) {
          _animationController.value = 0;
          _animationController.forward();
          timer.cancel();
        });
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        double tr = _animationController.value < 0.7
            ? Curves.bounceOut.transform(_animationController.value / 0.7)
            : 1.0;
        Offset transform = Offset(0, -50 * (1 - tr));
        int imageIndex = _animationController.value >= 0.3
            ? 51 * (_animationController.value - 0.3) ~/ 0.7
            : -1;
        return Stack(alignment: Alignment.center, children: <Widget>[
          Opacity(
              opacity: tr,
              child: Transform.translate(offset: transform, child: child)),
          imageIndex < 0 ? Container() : _effectImages[imageIndex]
        ]);
      },
    );
  }
}

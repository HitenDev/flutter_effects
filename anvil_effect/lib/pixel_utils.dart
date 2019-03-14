import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

Color getColorByPixel(ByteData byteData, Size size, Offset pixel) {
  //rawRgba
  assert(byteData.lengthInBytes == size.width * size.height * 4);
  assert(pixel.dx < size.width && pixel.dy < size.height);
  int index = ((pixel.dy * size.width + pixel.dx) * 4).toInt();
  int r = byteData.getUint8(index);
  int g = byteData.getUint8(index + 1);
  int b = byteData.getUint8(index + 2);
  int a = byteData.getUint8(index + 3);
  return Color.fromARGB(a, r, g, b);
}

import 'dart:math';
import 'package:flutter/material.dart';

class GlitchPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random();

  GlitchPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.15)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 10; i++) {
      double y = size.height * (i / 10) + 20 * sin(animationValue * 10 + i);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (int i = 0; i < 5; i++) {
      double x = size.width * _random.nextDouble();
      double height = 40 + 20 * sin(animationValue * 15 + i);
      canvas.drawLine(Offset(x, size.height - height), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GlitchPainter oldDelegate) => true;
}

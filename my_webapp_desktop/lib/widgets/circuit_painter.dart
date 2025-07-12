import 'package:flutter/material.dart';

class CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    for (double radius in [10, 20, 30]) {
      canvas.drawCircle(center, radius, paint);
    }

    canvas.drawLine(center, Offset(center.dx, 0), paint);
    canvas.drawLine(center, Offset(center.dx, size.height), paint);
    canvas.drawLine(center, Offset(0, center.dy), paint);
    canvas.drawLine(center, Offset(size.width, center.dy), paint);

    const dotRadius = 3.0;
    canvas.drawCircle(Offset(0, 0), dotRadius, paint);
    canvas.drawCircle(Offset(size.width, 0), dotRadius, paint);
    canvas.drawCircle(Offset(0, size.height), dotRadius, paint);
    canvas.drawCircle(Offset(size.width, size.height), dotRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

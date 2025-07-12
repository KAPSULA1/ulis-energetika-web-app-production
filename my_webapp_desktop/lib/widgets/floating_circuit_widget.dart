import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sulisenergetika/widgets/circuit_painter.dart'; // იმპორტი CircuitPainter-ისთვის

class FloatingCircuitWidget extends StatelessWidget {
  final Animation<double> animation;
  const FloatingCircuitWidget({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rotation = animation.value * 2 * pi;
        final glowOpacity = 0.6 + 0.4 * animation.value;
        return Transform.rotate(
          angle: rotation,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.cyanAccent.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(glowOpacity),
                  blurRadius: 18,
                  spreadRadius: 8,
                ),
              ],
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(glowOpacity),
                width: 2,
              ),
            ),
            child: CustomPaint(
              painter: CircuitPainter(),
            ),
          ),
        );
      },
    );
  }
}

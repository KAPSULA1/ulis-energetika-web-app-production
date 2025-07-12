import 'dart:math';
import 'package:flutter/material.dart';

class RotatingEnergyOrbs extends StatelessWidget {
  final Animation<double> pulse;
  const RotatingEnergyOrbs({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final scale = 0.8 + 0.4 * sin(pulse.value * 2 * pi + index * pi / 2);
            final opacity = 0.5 + 0.5 * cos(pulse.value * 2 * pi + index * pi / 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 30 * scale,
              height: 30 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withOpacity(opacity),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(opacity * 0.7),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

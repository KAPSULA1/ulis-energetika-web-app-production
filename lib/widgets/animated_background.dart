import 'package:flutter/material.dart';
import 'package:sulisenergetika/widgets/glitch_painter.dart'; // იმპორტი GlitchPainter-ისთვის

class AnimatedBackground extends StatelessWidget {
  final Animation<double> animation;
  const AnimatedBackground({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final colors = [
          Colors.cyan.shade800,
          Colors.purple.shade900,
          Colors.indigo.shade900,
          Colors.blue.shade700,
          Colors.purple.shade700,
        ];
        final stop1 = 0.3 + 0.2 * animation.value;
        final stop2 = 0.6 - 0.3 * animation.value;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: [stop1, stop2, 1.0, 1.0, 1.0],
              tileMode: TileMode.mirror,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: GlitchPainter(animation.value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

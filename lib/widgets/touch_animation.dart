import 'dart:math';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; // საჭიროა AutoSizeText-ისთვის

// ეს კლასი აღწერს შეხების ეფექტის მონაცემებს (პოზიცია, სიტყვა)
class TouchEffect {
  final Offset offset;
  final String word;
  TouchEffect({required this.offset, required this.word});
}

// ეს ვიჯეტი ამუშავებს და აჩვენებს შეხების ანიმაციას
class TouchAnimation extends StatefulWidget {
  final TouchEffect touch;
  const TouchAnimation({super.key, required this.touch});

  @override
  State<TouchAnimation> createState() => _TouchAnimationState();
}

class _TouchAnimationState extends State<TouchAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final size = 80.0 * _animation.value;
        final opacity = 1.0 - _animation.value;
        return Positioned(
          left: widget.touch.offset.dx - size / 2,
          top: widget.touch.offset.dy - size / 2,
          child: Opacity(
            opacity: opacity,
            child: Column(
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyanAccent.withOpacity(0.4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.6),
                        blurRadius: 15.0,
                        spreadRadius: 8.0 * (1 - opacity),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.touch.word,
                  style: TextStyle(
                    color: Colors.cyanAccent.withOpacity(opacity),
                    fontSize: 18 + 12 * _animation.value,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Orbitron',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

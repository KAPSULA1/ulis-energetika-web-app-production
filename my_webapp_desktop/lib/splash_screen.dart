import 'dart:math';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:sulisenergetika/screens/todo_screen.dart'; // <--- იმპორტი TodoScreen-ისთვის

// ამ კლასს დაარქვით SplashScreen, რადგან ის არის ეკრანი
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AudioPlayer _bgPlayer;
  late final AudioPlayer _touchPlayer;

  final List<_TouchEffect> _touches = [];
  final List<String> _words = [
    "Focus", "Power", "Rise", "Create", "Flow",
    "Dream", "Bold", "Think", "Shine", "Grow"
  ];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _bgPlayer = AudioPlayer();
    _touchPlayer = AudioPlayer();

    _playBackgroundMusic();

    // ტაიმერი TodoScreen-ზე გადასასვლელად
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TodoScreen()), // <--- აქ გასწორებულია TodoScreen
        );
      }
    });
  }

  void _playBackgroundMusic() async {
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.play(AssetSource('audio/background.mp3'));
  }

  void _handleTap(TapUpDetails details) async {
    final offset = details.localPosition;
    final word = _words[_random.nextInt(_words.length)];

    setState(() {
      _touches.add(_TouchEffect(offset: offset, word: word));
    });

    _touchPlayer.stop();
    await _touchPlayer.play(AssetSource('audio/pop.wav'));

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        if (_touches.isNotEmpty) {
          _touches.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bgPlayer.dispose();
    _touchPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _handleTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            AnimatedBackground(animation: _pulseController),
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  double glow = 0.6 + 0.4 * _pulseController.value;
                  return AutoSizeText(
                    'SulisEnergetika',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 60,
                      color: Colors.cyanAccent.withOpacity(glow),
                      shadows: [
                        Shadow(
                            blurRadius: 24,
                            color: Colors.cyanAccent.withOpacity(glow),
                            offset: const Offset(0, 0)),
                        Shadow(
                            blurRadius: 36,
                            color: Colors.purpleAccent.withOpacity(glow * 0.8),
                            offset: const Offset(0, 0)),
                        Shadow(
                            blurRadius: 54,
                            color: const Color(0xFFFF00FF).withOpacity(glow * 0.6),
                            offset: const Offset(0, 0)),
                      ],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  );
                },
              ),
            ),
            ..._touches.map((touch) => _TouchAnimation(touch: touch)).toList(),
            Positioned(
              bottom: 40,
              right: 20,
              child: RotatingEnergyOrbs(pulse: _pulseController),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: FloatingCircuitWidget(animation: _pulseController),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ყველა დამხმარე კლასი, რომელიც ადრე main.dart-ში იყო ---

class _TouchEffect {
  final Offset offset;
  final String word;
  _TouchEffect({required this.offset, required this.word});
}

class _TouchAnimation extends StatefulWidget {
  final _TouchEffect touch;
  const _TouchAnimation({super.key, required this.touch});

  @override
  State<_TouchAnimation> createState() => _TouchAnimationState();
}

class _TouchAnimationState extends State<_TouchAnimation> with SingleTickerProviderStateMixin {
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

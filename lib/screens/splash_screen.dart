import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:sulisenergetika/screens/todo_screen.dart';
import 'package:sulisenergetika/widgets/animated_background.dart';
import 'package:sulisenergetika/widgets/rotating_energy_orbs.dart';
import 'package:sulisenergetika/widgets/floating_circuit_widget.dart';
import 'package:sulisenergetika/widgets/touch_animation.dart'; // ეს იმპორტი მოიცავს TouchEffect კლასსაც

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AudioPlayer _bgPlayer;
  late final AudioPlayer _touchPlayer;

  final List<TouchEffect> _touches = []; // ახლა TouchEffect იმპორტირებულია widgets/touch_animation.dart-დან
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

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TodoScreen()),
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
      _touches.add(TouchEffect(offset: offset, word: word));
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
            ..._touches.map((touch) => TouchAnimation(touch: touch)).toList(),
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

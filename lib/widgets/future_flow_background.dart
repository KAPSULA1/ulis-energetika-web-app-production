// lib/widgets/future_flow_background.dart
import 'package:flutter/material.dart';
import 'dart:math';

// Represents a single animated particle in the "Future Flow"
class FlowParticle {
  Offset position;
  Offset velocity;
  double radius;
  Color color;
  double opacity;
  double life; // 0.0 (dead) to 1.0 (full life)

  FlowParticle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
    required this.opacity,
    required this.life,
  });

  // Update particle's position and life
  void update(Size bounds) {
    position += velocity;
    life -= 0.005; // Adjust for desired lifespan (smaller value = longer life)

    // Wrap around screen edges (particles re-enter from opposite side)
    if (position.dx < 0) position = Offset(bounds.width, position.dy);
    if (position.dx > bounds.width) position = Offset(0, position.dy);
    if (position.dy < 0) position = Offset(position.dx, bounds.height);
    if (position.dy > bounds.height) position = Offset(position.dx, 0);

    // Apply a slight random drift to velocity for more organic movement
    velocity += Offset(
      (Random().nextDouble() - 0.5) * 0.02,
      (Random().nextDouble() - 0.5) * 0.02,
    );
    // Limit velocity to prevent particles from flying off too quickly
    velocity = Offset(
      velocity.dx.clamp(-1.0, 1.0), // Max horizontal speed
      velocity.dy.clamp(-1.0, 1.0), // Max vertical speed
    );
  }

  // Check if particle is still alive
  bool get isAlive => life > 0;
}

class FutureFlowBackground extends StatefulWidget {
  const FutureFlowBackground({super.key});

  @override
  State<FutureFlowBackground> createState() => _FutureFlowBackgroundState();
}

class _FutureFlowBackgroundState extends State<FutureFlowBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FlowParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Controls overall animation speed
    )..repeat(); // Loop indefinitely

    _controller.addListener(() {
      _addParticles(); // Continuously add new particles
      _updateParticles(); // Update existing particles
      setState(() {}); // Request repaint on each animation tick
    });
  }

  void _addParticles() {
    // Add new particles periodically based on a probability
    // This creates a continuous flow of new elements
    if (_random.nextDouble() < 0.1) { // 10% chance to add a particle per frame
      final initialPosition = Offset(
        _random.nextDouble() * MediaQuery.of(context).size.width,
        _random.nextDouble() * MediaQuery.of(context).size.height,
      );
      _particles.add(FlowParticle(
        position: initialPosition,
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 2, // Random initial velocity between -1 and 1
          (_random.nextDouble() - 0.5) * 2,
        ),
        radius: 1.0 + _random.nextDouble() * 2, // Random size between 1.0 and 3.0
        color: _getParticleColor(),
        opacity: 0.0, // Start with 0 opacity to fade in smoothly
        life: 1.0, // Full life initially
      ));
    }
  }

  void _updateParticles() {
    // Get the current screen bounds to handle particle wrapping
    final Size bounds = MediaQuery.of(context).size;
    
    // Update each particle and remove those that have "died" (life <= 0)
    _particles.removeWhere((p) {
      p.update(bounds);
      // Fade in/out logic for a smooth appearance and disappearance
      if (p.life > 0.8) { // Fade in during first 20% of life
        p.opacity = (1 - p.life) * 5; // Scales life from 1.0 to 0.8 to opacity 0.0 to 1.0
      } else if (p.life < 0.2) { // Fade out during last 20% of life
        p.opacity = p.life * 5; // Scales life from 0.2 to 0.0 to opacity 1.0 to 0.0
      } else {
        p.opacity = 1.0; // Full opacity in between
      }
      p.opacity = p.opacity.clamp(0.0, 1.0); // Ensure opacity stays between 0 and 1
      return !p.isAlive; // Remove if not alive
    });
  }

  // Define a set of "future" colors for the particles
  Color _getParticleColor() {
    final int colorIndex = _random.nextInt(4); // Cycle through 4 core colors
    switch (colorIndex) {
      case 0: return Colors.blue.shade300; // Bright, ethereal blue
      case 1: return Colors.purple.shade300; // Vivid purple
      case 2: return Colors.cyan.shade300; // Electric cyan
      case 3: return Colors.lime.shade300; // Neon green/yellow for contrast
      default: return Colors.white; // Fallback
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CustomPaint draws our animated background
    return CustomPaint(
      painter: FutureFlowPainter(
        animation: _controller,
        particles: _particles,
      ),
      child: Container(), // Empty container to occupy the space
    );
  }
}

// Custom Painter to draw the background and particles
class FutureFlowPainter extends CustomPainter {
  final Animation<double> animation;
  final List<FlowParticle> particles;

  FutureFlowPainter({
    required this.animation,
    required this.particles,
  }) : super(repaint: animation); // Repaint whenever the animation changes

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Space Background Gradient (Static but impactful, very dark)
    final Paint backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF010115).withOpacity(0.9), // Extremely dark blue-black
          const Color(0xFF0D021C).withOpacity(0.9), // Dark purple-black
          const Color(0xFF03030A).withOpacity(0.9), // Pure deep black
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // 2. Subtle Dynamic Gradient Overlay (Slowly shifts for a "living" background)
    // This creates a sense of subtle energy flow and depth
    final Paint dynamicOverlayPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade900.withOpacity(0.05 + 0.03 * sin(animation.value * pi * 2 * 0.2)), // Slight pulsing in opacity
          Colors.purple.shade900.withOpacity(0.05 + 0.03 * cos(animation.value * pi * 2 * 0.2)),
          Colors.black.withOpacity(0.1),
        ],
        begin: Alignment(
          sin(animation.value * pi * 2 * 0.1), // Slow horizontal movement
          cos(animation.value * pi * 2 * 0.1), // Slow vertical movement
        ),
        end: Alignment(
          -sin(animation.value * pi * 2 * 0.1),
          -cos(animation.value * pi * 2 * 0.1),
        ),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), dynamicOverlayPaint);

    // 3. Draw Particles with Glow
    // Each particle is drawn as a circle, then a larger, more blurred circle for the glow
    for (final particle in particles) {
      if (particle.isAlive) {
        // Main particle dot
        final Paint particlePaint = Paint()
          ..color = particle.color.withOpacity(particle.opacity);
        canvas.drawCircle(particle.position, particle.radius, particlePaint);

        // Glow effect for the particle
        final Paint glowPaint = Paint()
          ..color = particle.color.withOpacity(particle.opacity * 0.3) // Fainter glow
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.radius * 2); // Larger blur for a soft glow
        canvas.drawCircle(particle.position, particle.radius, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FutureFlowPainter oldDelegate) {
    // Only repaint if animation or particles list has changed
    return oldDelegate.animation != animation || oldDelegate.particles != particles;
  }
}

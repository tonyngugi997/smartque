import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Color primaryColor;
  final Color accentColor;

  const AnimatedBackground({
    super.key,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize particles
    for (int i = 0; i < 80; i++) {
      _particles.add(Particle(
        x: _random.nextDouble() * 400,
        y: _random.nextDouble() * 800,
        size: _random.nextDouble() * 4 + 1,
        speedX: _random.nextDouble() * 0.8 - 0.4,
        speedY: _random.nextDouble() * 0.8 - 0.4,
        color: i % 4 == 0
            ? widget.accentColor.withOpacity(0.15)
            : widget.primaryColor.withOpacity(0.1),
      ));
    }

    // Start animation loop
    _controller.addListener(() {
      setState(() {
        for (var particle in _particles) {
          particle.x += particle.speedX;
          particle.y += particle.speedY;

          // Wrap around edges
          if (particle.x < 0) particle.x = 400;
          if (particle.x > 400) particle.x = 0;
          if (particle.y < 0) particle.y = 800;
          if (particle.y > 800) particle.y = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0A0F),
            const Color(0xFF1A1A2E),
            widget.primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlays
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.8],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.accentColor.withOpacity(0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.8],
                ),
              ),
            ),
          ),

          // Particles
          CustomPaint(
            size: Size.infinite,
            painter: _ParticlePainter(
              particles: _particles,
              time: _controller.value,
            ),
          ),

          // Grid overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                primaryColor: widget.primaryColor,
                accentColor: widget.accentColor,
              ),
            ),
          ),

          // Shimmer effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.white.withOpacity(
                            0.01 * sin(_controller.value * 2 * pi)),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double time;

  _ParticlePainter({
    required this.particles,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      // Add pulsing effect
      final pulse = 1 + 0.3 * sin(time * 2 * pi + particle.x);
      final radius = particle.size * pulse;

      canvas.drawCircle(
        Offset(particle.x * size.width / 400, particle.y * size.height / 800),
        radius,
        paint,
      );

      // Add glow for some particles
      if (particle.size > 2) {
        final glowPaint = Paint()
          ..color = particle.color.withOpacity(0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawCircle(
          Offset(particle.x * size.width / 400, particle.y * size.height / 800),
          radius * 2,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GridPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  _GridPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw accent lines
    final accentPaint = Paint()
      ..color = accentColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Diagonal lines
    for (double i = -size.width; i < size.width; i += 80) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.width, size.height),
        accentPaint,
      );

      canvas.drawLine(
        Offset(i + size.width, 0),
        Offset(i, size.height),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  double x, y;
  double size;
  double speedX, speedY;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.color,
  });
}

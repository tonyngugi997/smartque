import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// Use static TextStyle to avoid runtime font fetching
import 'enhanced_login_screen.dart'; // Changed from 'login_screen.dart'

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) =>
              const EnhancedLoginScreen(), // Changed from const LoginScreen()
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SplashParticlesPainter(),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo with pulse effect
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6C63FF),
                              Color(0xFF00BFA6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(108, 99, 255, 100),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: Color.fromRGBO(0, 191, 166, 50),
                              blurRadius: 15,
                              spreadRadius: -5,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                )
                    .animate(
                      delay: 700.ms,
                    )
                    .scaleXY(
                      duration: 6.seconds,
                      begin: 0.95,
                      end: 1.01,
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(height: 40),

                // Brand Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SmarT',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Color.fromRGBO(108, 99, 255, 204),
                            blurRadius: 20,
                            offset: Offset.zero,
                          ),
                        ],
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Que',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BFA6),
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Color.fromRGBO(0, 191, 166, 204),
                            blurRadius: 20,
                            offset: Offset.zero,
                          ),
                        ],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                )
                    .animate()
                    .slideY(
                      begin: 1.0,
                      end: 0.0,
                      duration: 800.ms,
                    )
                    .fadeIn(
                      duration: 800.ms,
                    ),

                const SizedBox(height: 15),

                // Tagline
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'Intelligent Queue Management',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(255, 255, 255, 179),
                          letterSpacing: 1.5,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'By Brenda Kangacha',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF00BFA6),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Simple loading indicator
                SizedBox(
                  width: 60,
                  height: 20,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 3; i++)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BFA6),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          )
                              .animate(
                                delay: (i * 200).ms,
                              )
                              .scaleXY(
                                duration: 600.ms,
                                begin: 1,
                                end: 1.3,
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Loading text
                Text(
                  'Initializing Smart System...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(255, 255, 255, 153),
                    letterSpacing: 1.0,
                    fontFamily: 'Poppins',
                  ),
                )
                    .animate(
                      delay: 500.ms,
                    )
                    .fadeIn(
                      duration: 800.ms,
                    ),

                const SizedBox(height: 20),

                // Version info
                Text(
                  'v1.0.0 • © 2026 SmarTQue Inc.',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color.fromRGBO(255, 255, 255, 77),
                    fontFamily: 'Poppins',
                  ),
                )
                    .animate(
                      delay: 1.seconds,
                    )
                    .fadeIn(
                      duration: 500.ms,
                    ),
              ],
            ),
          ),

          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashParticlesPainter extends CustomPainter {
  final Random _random = Random(42); // Fixed seed for consistent particles

  @override
  void paint(Canvas canvas, Size size) {
    // Ensure size is valid
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = const Color.fromRGBO(108, 99, 255, 26)
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = const Color.fromRGBO(0, 191, 166, 13)
      ..style = PaintingStyle.fill;

    // Draw particles
    for (int i = 0; i < 20; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = 2 + (_random.nextDouble() * 4);

      // Ensure coordinates are valid numbers
      if (!x.isFinite || !y.isFinite || !radius.isFinite) continue;

      if (i % 3 == 0) {
        canvas.drawCircle(Offset(x, y), radius, accentPaint);
      } else {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }

    final linePaint = Paint()
      ..color = const Color.fromRGBO(108, 99, 255, 8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw lines
    for (int i = 0; i < 8; i++) {
      final x1 = _random.nextDouble() * size.width;
      final y1 = _random.nextDouble() * size.height;
      final x2 = _random.nextDouble() * size.width;
      final y2 = _random.nextDouble() * size.height;

      // Ensure coordinates are valid numbers
      if (!x1.isFinite || !y1.isFinite || !x2.isFinite || !y2.isFinite)
        continue;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:advanced_login_app/google_fonts_stub.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum SecurityLevel { weak, medium, strong, veryStrong }

class SecurityIndicator extends StatelessWidget {
  final SecurityLevel securityLevel;
  final double score;
  final bool isVisible;

  const SecurityIndicator({
    super.key,
    required this.securityLevel,
    required this.score,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final config = _getSecurityConfig(securityLevel);

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms),
        SlideEffect(
          begin: const Offset(0, 0.2),
          duration: 300.ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: config.backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: config.borderColor.withOpacity(0.3),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              config.backgroundColor.withOpacity(0.15),
              config.backgroundColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(config.icon, color: config.iconColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  config.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${score.toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: config.iconColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Progress
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 500),
                    widthFactor: score / 100,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: config.gradientColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: config.iconColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Security tips
            Row(
              children: [
                Expanded(
                  child: Text(
                    config.tip,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: config.iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: config.iconColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    config.levelText,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: config.iconColor,
                    ),
                  ),
                ),
              ],
            ),

            // Additional indicators for high security
            if (securityLevel == SecurityLevel.strong ||
                securityLevel == SecurityLevel.veryStrong) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSecurityIndicator(
                    'Length ≥ 8',
                    true,
                    config.iconColor,
                  ),
                  const SizedBox(width: 12),
                  _buildSecurityIndicator(
                    'Mixed Case',
                    true,
                    config.iconColor,
                  ),
                  const SizedBox(width: 12),
                  _buildSecurityIndicator(
                    'Numbers',
                    true,
                    config.iconColor,
                  ),
                  const SizedBox(width: 12),
                  _buildSecurityIndicator(
                    'Special Chars',
                    true,
                    config.iconColor,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityIndicator(String text, bool passed, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: passed ? color : Colors.grey.withOpacity(0.3),
            border: Border.all(
              color: passed ? color.withOpacity(0.5) : Colors.grey,
              width: 1,
            ),
          ),
          child: passed
              ? Icon(
                  Icons.check,
                  size: 8,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: passed ? color : Colors.white54,
            fontWeight: passed ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  _SecurityConfig _getSecurityConfig(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.weak:
        return _SecurityConfig(
          title: 'Weak Password',
          tip: 'Add more characters, numbers, and special symbols',
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFFF6B6B),
          backgroundColor: const Color(0xFFFF6B6B),
          borderColor: const Color(0xFFFF6B6B),
          gradientColors: const [
            Color(0xFFFF6B6B),
            Color(0xFFFF8A65),
          ],
          levelText: 'NEEDS IMPROVEMENT',
        );
      case SecurityLevel.medium:
        return _SecurityConfig(
          title: 'Medium Security',
          tip: 'Good start! Try adding special characters',
          icon: Icons.security_rounded,
          iconColor: const Color(0xFFFFA726),
          backgroundColor: const Color(0xFFFFA726),
          borderColor: const Color(0xFFFFA726),
          gradientColors: const [
            Color(0xFFFFA726),
            Color(0xFFFFCA28),
          ],
          levelText: 'ACCEPTABLE',
        );
      case SecurityLevel.strong:
        return _SecurityConfig(
          title: 'Strong Password',
          tip: 'Excellent! Your password meets security standards',
          icon: Icons.verified_rounded,
          iconColor: const Color(0xFF4CAF50),
          backgroundColor: const Color(0xFF4CAF50),
          borderColor: const Color(0xFF4CAF50),
          gradientColors: const [
            Color(0xFF4CAF50),
            Color(0xFF8BC34A),
          ],
          levelText: 'SECURE',
        );
      case SecurityLevel.veryStrong:
        return _SecurityConfig(
          title: 'Very Strong Password',
          tip: 'Maximum security achieved!',
          icon: Icons.shield_rounded,
          iconColor: const Color(0xFF00BFA6),
          backgroundColor: const Color(0xFF00BFA6),
          borderColor: const Color(0xFF00BFA6),
          gradientColors: const [
            Color(0xFF00BFA6),
            Color(0xFF00E5FF),
          ],
          levelText: 'MAXIMUM SECURITY',
        );
    }
  }
}

class _SecurityConfig {
  final String title;
  final String tip;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final List<Color> gradientColors;
  final String levelText;

  _SecurityConfig({
    required this.title,
    required this.tip,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.gradientColors,
    required this.levelText,
  });
}

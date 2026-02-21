import 'package:flutter/material.dart';
// Avoid runtime font fetching; use default TextStyle to prevent network calls

class AppColors {
  // Modern gradient colors
  static const Color primary = Color(0xFF2D6AEE); // Deep blue
  static const Color secondary = Color(0xFF00C6FF); // Cyan
  static const Color accent = Color(0xFFFF6B6B); // Coral red

  // Backgrounds
  static const Color background = Color(0xFFF8F9FD); // Light blue-gray
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A2E); // Dark blue
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textLight = Color(0xFF9CA3AF); // Light gray

  // Status colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red

  // Gradients
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient = const LinearGradient(
    colors: [accent, Color(0xFFFF9A9E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      brightness: Brightness.light,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          fontFamily: 'Poppins',
        ),
        displayMedium: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
        displaySmall: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        titleLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        bodyLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        bodyMedium: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        bodySmall: const TextStyle(
          color: AppColors.textLight,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textLight.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(
          color: AppColors.textLight,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 4,
        shadowColor: AppColors.textPrimary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
      ),
    );
  }

  /// Dark theme – matches current app styling.
  static ThemeData get darkTheme {
    const background = Color(0xFF0A0A0F);
    const primary = Color(0xFF6C63FF);
    const secondary = Color(0xFF4A44C6);
    const accent = Color(0xFF00BFA6);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: const Color.fromRGBO(108, 99, 255, 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: const Color.fromRGBO(108, 99, 255, 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: accent),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      fontFamily: 'Poppins',
    );
  }

  /// Cyber / neon theme – high‑contrast futuristic look.
  static ThemeData get cyberTheme {
    const background = Color(0xFF050712);
    const primary = Color(0xFF00E5FF); // neon cyan
    const secondary = Color(0xFF7C4DFF); // purple
    const accent = Color(0xFFFF4081); // pink

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardColor: const Color(0xFF0D1024),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF10132A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      fontFamily: 'Poppins',
    );
  }

  // Custom text styles
  static TextStyle get headlineStyle {
    return const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: -1,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle get subtitleStyle {
    return const TextStyle(
      fontSize: 16,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w400,
      fontFamily: 'Inter',
    );
  }

  static TextStyle get buttonTextStyle {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      fontFamily: 'Inter',
    );
  }
}

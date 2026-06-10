import 'package:flutter/material.dart';

class NovaTheme {
  // Brand Colors
  static const Color background = Color(0xFF050505); // True Black (OLED Base)
  static const Color surface = Color(0xFF131313); // Sectioning base
  static const Color surfaceLow = Color(0xFF1C1B1B);
  static const Color surfaceHigh = Color(0xFF2A2A2A);
  static const Color surfaceHighest = Color(0xFF353534);
  static const Color surfaceLowest = Color(0xFF0E0E0E);
  static const Color surfaceVariant = Color(0xFF353534);

  // Neon Accent Colors
  static const Color primary = Color(0xFFA855F7); // Electric Purple
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color tertiary = Color(0xFF3B82F6); // Blue
  static const Color error = Color(0xFFFFB4AB); // Material Error Red

  // Text / Outline Colors
  static const Color onBackground = Color(0xFFE5E2E1);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFCFC2D6);
  static const Color outline = Color(0xFF988D9F);
  static const Color outlineVariant = Color(0xFF4D4354);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFDDB7FF), Color(0xFF4CD7F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonPurpleCyanGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient timeAmbientGradient = RadialGradient(
    colors: [Color(0x26400071), Colors.transparent],
    center: Alignment.topRight,
    radius: 1.2,
  );

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        background: background,
        surface: surface,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        error: error,
        onBackground: onBackground,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      fontFamily: 'Inter',
      useMaterial3: true,
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }
}

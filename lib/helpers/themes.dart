import 'package:flutter/material.dart';

class AppThemes {
  static const Color _seed = Colors.deepPurple;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF6A1B9A),
      onPrimary: Colors.white,
      secondary: const Color(0xFF7C4DFF),
      error: const Color(0xFFB00020),
      surfaceTint: const Color(0xFF6A1B9A),
      surface: const Color(0xFFF6F6FB),
      onSurface: const Color(0xFF111111),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6A1B9A),
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFCE93D8),
      onPrimary: const Color(0xFF1A1220),
      secondary: const Color(0xFF9F7AE6),
      error: const Color(0xFFFF5252),
      surfaceTint: const Color(0xFFCE93D8),
      surface: const Color(0xFF0E0B10),
      onSurface: const Color(0xFFECE7F1),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFCE93D8),
      foregroundColor: Colors.black87,
    ),
  );
}

class AppColors {
  static const Color primary = Color(0xFF6A1B9A);
  static const Color primaryVariant = Color(0xFF4A0F6B);
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1E88E5);

  static const Color textSubtle = Color(0xFF9E9E9E);
  static const Color iconSubtle = Color(0xFFBDBDBD);
  static const Color textSubtleDark = Color(0xFF757575);

  static final Color errorContainer = error.withValues(alpha: 0.12);
  static final Color successContainer = success.withValues(alpha: 0.12);
  static final Color warningContainer = warning.withValues(alpha: 0.12);
  static final Color infoContainer = info.withValues(alpha: 0.08);

  static Color alarmColor({required bool isMissed, required bool isCompleted, required Brightness brightness}) {
    if (isMissed) return Colors.redAccent;
    if (isCompleted) return brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade600;
    return brightness == Brightness.dark ? const Color(0xFFBDBDBD) : const Color(0xFF616161);
  }

  static Color reminderTextColor({required bool isMissed, required Brightness brightness}) {
    return isMissed ? Colors.redAccent : (brightness == Brightness.dark ? const Color(0xFFE0E0E0) : const Color(0xFF616161));
  }

  static const List<Color> categoryColors = [
    Color(0xFFE53935),
    Color(0xFFD81B60),
    Color(0xFF8E24AA),
    Color(0xFF5E35B1),
    Color(0xFF3949AB),
    Color(0xFF1E88E5),
    Color(0xFF00ACC1),
    Color(0xFF00897B),
    Color(0xFF43A047),
    Color(0xFFFFB300),
    Color(0xFFFF8A65),
    Color(0xFF6D4C41),
  ];
}

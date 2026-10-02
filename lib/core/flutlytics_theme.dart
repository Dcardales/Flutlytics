import 'package:flutter/material.dart';

abstract final class FlutlyticsColors {
  static const primary = Color(0xFF5B5BD6);
  static const primaryDark = Color(0xFF4338CA);
  static const accent = Color(0xFF06B6D4);
  static const background = Color(0xFFF6F7FB);
  static const surface = Colors.white;
  static const text = Color(0xFF171923);
  static const secondaryText = Color(0xFF667085);
  static const outline = Color(0xFFE4E7EC);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
}

abstract final class FlutlyticsTheme {
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: FlutlyticsColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: FlutlyticsColors.primary,
          onPrimary: Colors.white,
          secondary: FlutlyticsColors.accent,
          surface: FlutlyticsColors.surface,
          onSurface: FlutlyticsColors.text,
          outline: FlutlyticsColors.outline,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: FlutlyticsColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: FlutlyticsColors.background,
        foregroundColor: FlutlyticsColors.text,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: FlutlyticsColors.surface,
        elevation: 1,
        shadowColor: FlutlyticsColors.text.withValues(alpha: 0.06),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: FlutlyticsColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FlutlyticsColors.background,
        selectedColor: FlutlyticsColors.primary.withValues(alpha: 0.12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FlutlyticsColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FlutlyticsColors.outline),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: FlutlyticsColors.text,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: FlutlyticsColors.text,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: FlutlyticsColors.text,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: FlutlyticsColors.text),
        bodySmall: TextStyle(color: FlutlyticsColors.secondaryText),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Type scale. Colours are applied by [AppTheme] so this stays theme-agnostic.
abstract final class AppTypography {
  /// Myanmar glyphs fall back to the system Myanmar font when the Latin font
  /// lacks them, so Burmese text renders correctly in both locales.
  static const List<String> fontFallback = ['Noto Sans Myanmar', 'Padauk'];

  static const TextTheme textTheme = TextTheme(
    displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.15),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
  );
}

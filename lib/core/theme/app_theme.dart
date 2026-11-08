import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] from the same design tokens.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.accent,
      tertiary: colors.highlight,
      error: colors.danger,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    );
    final text = AppTypography.textTheme
        .apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary)
        .apply(fontFamilyFallback: AppTypography.fontFallback);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: text,
      extensions: [colors],
      inputDecorationTheme: _inputTheme(colors),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static InputDecorationTheme _inputTheme(AppColors colors) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      hintStyle: TextStyle(color: colors.textHint),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      enabledBorder: border(colors.surface),
      focusedBorder: border(colors.primary, 1.5),
      errorBorder: border(colors.danger),
      focusedErrorBorder: border(colors.danger, 1.5),
    );
  }
}

/// Short accessors so widgets write `context.colors.accent`.
extension ThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

import 'package:flutter/material.dart';

/// Brand colour tokens. Widgets read these via `context.colors`, never raw hex.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.highlight,
    required this.success,
    required this.danger,
    required this.background,
    required this.backgroundTint,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.disabled,
    required this.border,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.tierSilver,
    required this.tierGold,
    required this.tierPlatinum,
    required this.headerTint,
    required this.glazeLight,
    required this.glazeDeep,
  });

  /// Sky-blue call-to-action colour (Continue, Let's explore, nav bar).
  final Color primary;
  final Color onPrimary;

  /// Pink brand accent (links, progress ring, active nav pill).
  final Color accent;

  /// Orange highlight (badges, discount chips, Rewards pill).
  final Color highlight;
  final Color success;
  final Color danger;
  final Color background;

  /// Soft pink wash behind onboarding and registration screens.
  final Color backgroundTint;
  final Color surface;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color disabled;
  final Color border;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color tierSilver;
  final Color tierGold;
  final Color tierPlatinum;

  /// Home member-header background.
  final Color headerTint;

  /// Rewards points-ring glaze (strawberry in light, caramel in dark).
  final Color glazeLight;
  final Color glazeDeep;

  static const light = AppColors(
    primary: Color(0xFF56CFEB),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFEF5DA8),
    highlight: Color(0xFFFF7A1A),
    success: Color(0xFF7CB342),
    danger: Color(0xFFE5484D),
    background: Color(0xFFFFFFFF),
    backgroundTint: Color(0xFFFCE8F1),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEBF0F0),
    textPrimary: Color(0xFF1F1F24),
    textSecondary: Color(0xFF6B6B75),
    textHint: Color(0xFFA3A3AD),
    disabled: Color(0xFFE4E4E7),
    border: Color(0xFFE9E9EE),
    skeletonBase: Color(0xFFE6EAEA),
    skeletonHighlight: Color(0xFFF6F8F8),
    tierSilver: Color(0xFFB8B8BE),
    tierGold: Color(0xFFF1D27A),
    tierPlatinum: Color(0xFF9EDCF0),
    headerTint: Color(0xFFF6DCC4),
    glazeLight: Color(0xFFF79AC6),
    glazeDeep: Color(0xFFEC4F9A),
  );

  /// "Chocolate & caramel": warm cocoa surfaces, caramel actions, cream
  /// accents. Dark mode is not in the client designs, so it has its own,
  /// donut-themed palette instead of glowing cyan/pink on black.
  static const dark = AppColors(
    primary: Color(0xFFE0A458),
    onPrimary: Color(0xFF2A1A0E),
    accent: Color(0xFFF2D3A9),
    highlight: Color(0xFFE8794A),
    success: Color(0xFF9CCC65),
    danger: Color(0xFFFF7A6B),
    background: Color(0xFF16110E),
    backgroundTint: Color(0xFF1E1612),
    surface: Color(0xFF221A15),
    surfaceMuted: Color(0xFF1B1511),
    textPrimary: Color(0xFFF5ECE4),
    textSecondary: Color(0xFFC9B8AA),
    textHint: Color(0xFF8C7A6C),
    disabled: Color(0xFF3A2F27),
    border: Color(0xFF33281F),
    skeletonBase: Color(0xFF2A211B),
    skeletonHighlight: Color(0xFF3A2E26),
    tierSilver: Color(0xFFB5B0AA),
    tierGold: Color(0xFFE0B860),
    tierPlatinum: Color(0xFFA9CFDB),
    headerTint: Color(0xFF2B2019),
    glazeLight: Color(0xFFEDBB7A),
    glazeDeep: Color(0xFFC9853D),
  );

  @override
  AppColors copyWith({Color? primary, Color? accent}) => AppColors(
    primary: primary ?? this.primary,
    onPrimary: onPrimary,
    accent: accent ?? this.accent,
    highlight: highlight,
    success: success,
    danger: danger,
    background: background,
    backgroundTint: backgroundTint,
    surface: surface,
    surfaceMuted: surfaceMuted,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textHint: textHint,
    disabled: disabled,
    border: border,
    skeletonBase: skeletonBase,
    skeletonHighlight: skeletonHighlight,
    tierSilver: tierSilver,
    tierGold: tierGold,
    tierPlatinum: tierPlatinum,
    headerTint: headerTint,
    glazeLight: glazeLight,
    glazeDeep: glazeDeep,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      accent: mix(accent, other.accent),
      highlight: mix(highlight, other.highlight),
      success: mix(success, other.success),
      danger: mix(danger, other.danger),
      background: mix(background, other.background),
      backgroundTint: mix(backgroundTint, other.backgroundTint),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textHint: mix(textHint, other.textHint),
      disabled: mix(disabled, other.disabled),
      border: mix(border, other.border),
      skeletonBase: mix(skeletonBase, other.skeletonBase),
      skeletonHighlight: mix(skeletonHighlight, other.skeletonHighlight),
      tierSilver: mix(tierSilver, other.tierSilver),
      tierGold: mix(tierGold, other.tierGold),
      tierPlatinum: mix(tierPlatinum, other.tierPlatinum),
      headerTint: mix(headerTint, other.headerTint),
      glazeLight: mix(glazeLight, other.glazeLight),
      glazeDeep: mix(glazeDeep, other.glazeDeep),
    );
  }
}

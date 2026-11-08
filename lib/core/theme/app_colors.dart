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
  );

  static const dark = AppColors(
    primary: Color(0xFF4CC3E0),
    onPrimary: Color(0xFF0B1F26),
    accent: Color(0xFFF27BB8),
    highlight: Color(0xFFFF8F3D),
    success: Color(0xFF9CCC65),
    danger: Color(0xFFFF6B6F),
    background: Color(0xFF121216),
    backgroundTint: Color(0xFF241820),
    surface: Color(0xFF1E1E24),
    surfaceMuted: Color(0xFF17191B),
    textPrimary: Color(0xFFF2F2F5),
    textSecondary: Color(0xFFB4B4BE),
    textHint: Color(0xFF75757F),
    disabled: Color(0xFF34343B),
    border: Color(0xFF2E2E36),
    skeletonBase: Color(0xFF26282B),
    skeletonHighlight: Color(0xFF33363A),
    tierSilver: Color(0xFF9A9AA2),
    tierGold: Color(0xFFD9B85E),
    tierPlatinum: Color(0xFF7CC4DB),
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
    );
  }
}

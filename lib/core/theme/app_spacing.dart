/// Spacing scale (logical pixels). Use these instead of literal paddings.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Horizontal page gutter used by every screen.
  static const double pageGutter = 24;
}

/// Corner radius scale.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

/// Fixed component sizes from the designs.
abstract final class AppSizes {
  static const double buttonHeight = 52;
  static const double inputHeight = 56;
  static const double otpBoxSize = 48;
  static const double iconButton = 40;
  static const double progressRing = 32;
  static const double bottomNavHeight = 72;
}

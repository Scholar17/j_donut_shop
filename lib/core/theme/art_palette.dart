import 'package:flutter/painting.dart';

/// Illustration colours (donut art, onboarding circles). Kept in the theme
/// folder with the other tokens; these stay the same in light and dark
/// because they depict food, not UI chrome.
abstract final class ArtPalette {
  static const dough = Color(0xFFE2A866);
  static const unfrosted = Color(0xFFE9E9EC);
  static const strawberry = Color(0xFFF58BB4);
  static const grape = Color(0xFF9C7BF2);
  static const chocolate = Color(0xFF6B3E2E);
  static const vanilla = Color(0xFFFFF3E0);
  static const sprinkles = [
    Color(0xFFFFFFFF),
    Color(0xFF5EC8EA),
    Color(0xFFFFD45C),
    Color(0xFF7BD389),
    Color(0xFFB57BFF),
  ];

  static const circlePeach = Color(0xFFF6DCC4);
  static const circleSky = Color(0xFF55D5EE);
  static const circleLilac = Color(0xFFC9D8F2);
  static const circleButter = Color(0xFFFFD99A);
  static const circleBlush = Color(0xFFF9C9DA);
  static const highlight = Color(0x59FFFFFF);
  static const shadow = Color(0xFF000000);
}

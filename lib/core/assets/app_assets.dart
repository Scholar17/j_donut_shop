/// Paths of bundled image assets. Never write asset strings in widgets.
abstract final class AppAssets {
  static const _onboarding = 'assets/images/onboarding';
  static const onboardingCenter = '$_onboarding/onb_circle_center.png';
  static const onboardingTopLeft = '$_onboarding/onb_circle_top_left.png';
  static const onboardingTopRight = '$_onboarding/onb_circle_top_right.png';
  static const onboardingLeft = '$_onboarding/onb_circle_left.png';
  static const onboardingRight = '$_onboarding/onb_circle_right.png';
  static const onboardingBottom = '$_onboarding/onb_circle_bottom.png';

  static const _catalog = 'assets/images/catalog';

  /// Rewards challenge artwork (also catalogue product photos).
  static const challengeDonut = '$_catalog/p_strawberry_choco.png';
  static const challengeCoffee = '$_catalog/p_iced_americano.png';
}

import 'package:flutter/widgets.dart';

/// Every animation duration and curve in the app lives here.
///
/// Widgets never write `Duration(milliseconds: ...)` inline; they pick a named
/// token and pass it through [MotionContext.motion] so Reduce Motion is honoured
/// in one place.
abstract final class AppDurations {
  static const instant = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 450);
  static const emphasized = Duration(milliseconds: 700);
  static const pageTransition = Duration(milliseconds: 380);

  /// Delay between items of a staggered entrance.
  static const staggerStep = Duration(milliseconds: 70);

  static const otpShake = Duration(milliseconds: 420);
  static const progressRing = Duration(milliseconds: 600);
  static const ringToCheckMorph = Duration(milliseconds: 360);
  static const challengeFill = Duration(milliseconds: 900);
  static const navPillGrow = Duration(milliseconds: 300);
  static const earnPulse = Duration(milliseconds: 1100);
  static const shimmerCycle = Duration(milliseconds: 1300);
  static const bannerAutoPlay = Duration(seconds: 5);
  static const bannerSlide = Duration(milliseconds: 500);
  static const onboardingDrift = Duration(milliseconds: 1200);

  /// One master timeline for the Rewards entrance (intervals inside).
  static const rewardsEntrance = Duration(milliseconds: 1800);
  static const tabSwitch = Duration(milliseconds: 380);
  static const onboardingContentDelay = Duration(milliseconds: 250);
  static const welcomeTitleDelay = Duration(milliseconds: 450);
}

abstract final class AppCurves {
  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubicEmphasized;
  static const entrance = Curves.easeOutQuart;
  static const exit = Curves.easeInCubic;
  static const overshoot = Curves.easeOutBack;
  static const pop = Curves.elasticOut;
  static const sweep = Curves.easeInOutCubic;

  /// Active nav pill growing to fit its label.
  static const navPillGrow = Curves.easeOutCubic;

  /// Banner auto-advance: gentle start and stop, no fast middle snap.
  static const bannerSlide = Curves.easeInOutSine;
}

/// Press-scale and offsets used by interactive feedback.
abstract final class AppMotionValues {
  static const double pressedScale = 0.96;
  static const double entranceOffset = 24;
  static const double shakeOffset = 10;
  static const int shakeCycles = 3;
  static const double earnPulseScale = 1.06;
  static const double fadeThroughStartScale = 0.96;
}

/// Reduce-Motion aware helpers.
extension MotionContext on BuildContext {
  /// True when the OS asks for reduced motion.
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  /// Returns [duration], or [Duration.zero] when Reduce Motion is on.
  Duration motion(Duration duration) => reduceMotion ? Duration.zero : duration;
}

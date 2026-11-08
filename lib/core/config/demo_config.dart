/// Settings for the demo build (no real back end).
abstract final class DemoConfig {
  /// The only OTP the fake auth accepts. Shown as a hint on the OTP screen.
  static const otpCode = '123456';

  /// Set to false when a real SMS provider replaces the fake repository.
  static const showOtpHint = true;
}

/// One-time-password rules shared by the bloc and the fake repository.
abstract final class OtpRules {
  static const length = 6;

  /// Wrong codes allowed before entry locks until the user taps Resend.
  static const maxWrongAttempts = 3;

  /// Resend becomes available after this countdown.
  static const resendCooldown = Duration(minutes: 5);

  static final RegExp _digits = RegExp(r'^\d+$');
}

/// True when [code] is exactly [OtpRules.length] ASCII digits.
bool isOtpComplete(String code) =>
    code.length == OtpRules.length && OtpRules._digits.hasMatch(code);

/// Keeps only digits and truncates to [OtpRules.length] (used for paste).
String sanitizeOtpInput(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.length > OtpRules.length
      ? digits.substring(0, OtpRules.length)
      : digits;
}

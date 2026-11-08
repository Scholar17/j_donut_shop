import 'auth_user.dart';

/// Result of a correct OTP: either the user is signed in, or a new phone is
/// verified and registration continues.
sealed class OtpOutcome {
  const OtpOutcome();
}

/// Log-in path: a session now exists for [user].
final class SignedIn extends OtpOutcome {
  const SignedIn(this.user);
  final AuthUser user;
}

/// Register path: the phone is verified; collect name and date of birth next.
final class PhoneVerified extends OtpOutcome {
  const PhoneVerified(this.phone);
  final String phone;
}

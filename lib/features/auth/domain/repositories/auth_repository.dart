import '../../../../core/result/result.dart';
import '../entities/auth_mode.dart';
import '../entities/auth_user.dart';
import '../entities/new_user_profile.dart';
import '../entities/otp_outcome.dart';
import '../entities/profile_update.dart';

/// Auth contract. The UI only knows this interface, so the fake can be
/// swapped for a real API by changing one DI registration.
abstract interface class AuthRepository {
  /// Sends an OTP to [phone] (E.164). Fails with `phoneNotRegistered` on
  /// log-in for an unknown number, `phoneAlreadyRegistered` on register and
  /// on change-phone when another account owns the number.
  Future<Result<void>> requestOtp({
    required String phone,
    required AuthMode mode,
  });

  /// Checks [code]. Log-in signs the user in; register returns PhoneVerified.
  Future<Result<OtpOutcome>> verifyOtp({
    required String phone,
    required String code,
    required AuthMode mode,
  });

  /// Creates the account and signs the user in.
  Future<Result<AuthUser>> register(NewUserProfile profile);

  /// Saves edited profile data for the signed-in user. A changed phone must
  /// have been verified with [verifyOtp] in [AuthMode.changePhone] first.
  Future<Result<AuthUser>> updateProfile(ProfileUpdate update);

  /// The signed-in user from the persisted session, or `null`.
  Future<AuthUser?> restoreSession();

  Future<void> logOut();
}

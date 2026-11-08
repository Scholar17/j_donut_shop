import '../../l10n/generated/app_localizations.dart';
import '../result/failure.dart';

/// Maps every typed [Failure] to a user-facing, localized message.
/// Exhaustive `switch`: adding a Failure subtype is a compile error here.
extension FailureMessage on Failure {
  String message(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetwork,
    AuthFailure(:final reason) => _authMessage(reason, l10n),
    ServerFailure() ||
    CacheFailure() ||
    NotFoundFailure() ||
    ValidationFailure() ||
    UnexpectedFailure() => l10n.errorGeneric,
  };

  static String _authMessage(AuthFailureReason reason, AppLocalizations l10n) =>
      switch (reason) {
        AuthFailureReason.phoneNotRegistered => l10n.phoneNotRegistered,
        AuthFailureReason.phoneAlreadyRegistered => l10n.phoneAlreadyRegistered,
        AuthFailureReason.invalidOtp => l10n.otpWrong(0),
        AuthFailureReason.otpLocked => l10n.otpLocked,
        AuthFailureReason.sessionExpired => l10n.errorGeneric,
      };
}

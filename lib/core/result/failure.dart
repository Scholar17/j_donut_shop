/// Typed failures shared by every feature.
///
/// Presentation maps each subtype to a localized message, so no raw exception
/// text ever reaches the user.
sealed class Failure {
  const Failure([this.debugMessage]);

  /// Developer-facing detail for logs; never shown in the UI.
  final String? debugMessage;
}

/// The device has no reachable network.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.debugMessage]);
}

/// The server answered with an error envelope or an unexpected status.
final class ServerFailure extends Failure {
  const ServerFailure([super.debugMessage]);
}

/// Reading or writing the local database failed.
final class CacheFailure extends Failure {
  const CacheFailure([super.debugMessage]);
}

/// A requested record does not exist locally.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.debugMessage]);
}

/// Auth-specific failures (wrong OTP, unknown phone, locked entry...).
final class AuthFailure extends Failure {
  const AuthFailure(this.reason, [super.debugMessage]);
  final AuthFailureReason reason;
}

enum AuthFailureReason {
  phoneNotRegistered,
  phoneAlreadyRegistered,
  invalidOtp,
  otpLocked,
  sessionExpired,
}

/// Anything not covered above; carries the original error for logging.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.debugMessage]);
}

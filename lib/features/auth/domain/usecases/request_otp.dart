import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../entities/auth_mode.dart';
import '../repositories/auth_repository.dart';
import '../validators/phone_validator.dart';

/// Normalizes the typed phone and asks the repository to send an OTP.
class RequestOtp {
  const RequestOtp(this._repository);

  final AuthRepository _repository;

  /// On success returns the E.164 number the OTP was sent to.
  Future<Result<String>> call({
    required String rawPhone,
    required AuthMode mode,
  }) async {
    final phone = normalizePhone(rawPhone);
    if (phone == null) {
      return const Result.failure(ValidationFailure('Invalid phone'));
    }
    final sent = await _repository.requestOtp(phone: phone, mode: mode);
    return sent.fold(
      onSuccess: (_) => Result.success(phone),
      onFailure: Result.failure,
    );
  }
}

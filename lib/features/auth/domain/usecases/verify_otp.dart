import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../entities/auth_mode.dart';
import '../entities/otp_outcome.dart';
import '../repositories/auth_repository.dart';
import '../validators/otp_validator.dart';

class VerifyOtp {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<OtpOutcome>> call({
    required String phone,
    required String code,
    required AuthMode mode,
  }) async {
    if (!isOtpComplete(code)) {
      return const Result.failure(ValidationFailure('OTP must be 6 digits'));
    }
    return _repository.verifyOtp(phone: phone, code: code, mode: mode);
  }
}

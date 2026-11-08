import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../entities/auth_user.dart';
import '../entities/profile_update.dart';
import '../repositories/auth_repository.dart';
import '../validators/name_validator.dart';
import '../validators/phone_validator.dart';

/// Validates and saves an edited profile (same rules as registration).
class UpdateProfile {
  const UpdateProfile(this._repository);

  final AuthRepository _repository;

  /// [rawPhone] is what the user typed after `+95`.
  Future<Result<AuthUser>> call({
    required String firstName,
    required String lastName,
    required String rawPhone,
    String? photoPath,
  }) async {
    final phone = normalizePhone(rawPhone);
    if (phone == null ||
        validateFirstName(firstName) != null ||
        validateLastName(lastName) != null) {
      return const Result.failure(ValidationFailure('Invalid profile'));
    }
    final last = lastName.trim();
    return _repository.updateProfile(
      ProfileUpdate(
        firstName: firstName.trim(),
        lastName: last.isEmpty ? null : last,
        phone: phone,
        photoPath: photoPath,
      ),
    );
  }
}

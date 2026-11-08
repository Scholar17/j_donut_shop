import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../entities/auth_user.dart';
import '../entities/new_user_profile.dart';
import '../repositories/auth_repository.dart';
import '../validators/date_of_birth_validator.dart';
import '../validators/name_validator.dart';

/// Re-validates the whole profile (defence in depth: the UI may be bypassed)
/// and stores trimmed names.
class RegisterUser {
  const RegisterUser(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AuthRepository _repository;
  final DateTime Function() _clock;

  Future<Result<AuthUser>> call(NewUserProfile profile) async {
    if (!_isValid(profile)) {
      return const Result.failure(ValidationFailure('Invalid profile'));
    }
    final lastName = profile.lastName?.trim();
    return _repository.register(
      NewUserProfile(
        phone: profile.phone,
        firstName: profile.firstName.trim(),
        lastName: (lastName == null || lastName.isEmpty) ? null : lastName,
        dateOfBirth: profile.dateOfBirth,
      ),
    );
  }

  bool _isValid(NewUserProfile profile) {
    final dob = profile.dateOfBirth;
    return validateFirstName(profile.firstName) == null &&
        validateLastName(profile.lastName ?? '') == null &&
        validateDateOfBirth(
              month: dob.month,
              day: dob.day,
              year: dob.year,
              today: _clock(),
            ) ==
            null;
  }
}

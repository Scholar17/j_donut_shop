import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Restores the signed-in user on app launch.
class RestoreSession {
  const RestoreSession(this._repository);
  final AuthRepository _repository;

  Future<AuthUser?> call() => _repository.restoreSession();
}

class LogOut {
  const LogOut(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.logOut();
}

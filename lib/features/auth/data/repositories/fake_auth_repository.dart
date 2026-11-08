import 'dart:math';

import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/session/session_storage.dart';
import '../../domain/entities/auth_mode.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/new_user_profile.dart';
import '../../domain/entities/otp_outcome.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../models/user_entity.dart';

/// Fake back-end settings, documented in the README.
abstract final class FakeAuthConfig {
  /// The only OTP the fake accepts.
  static const otpCode = '123456';

  /// Simulated network latency for every call.
  static const latency = Duration(seconds: 1);
}

/// Local stand-in for a real auth API: users live in ObjectBox, the session
/// token in secure storage. Replace with an HTTP implementation by changing
/// the get_it registration; nothing in the UI changes.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(
    this._users,
    this._session, {
    this.latency = FakeAuthConfig.latency,
    Random? random,
  }) : _random = random ?? Random.secure();

  final UserLocalDataSource _users;
  final SessionStorage _session;
  final Duration latency;
  final Random _random;

  @override
  Future<Result<void>> requestOtp({
    required String phone,
    required AuthMode mode,
  }) async {
    await _simulateNetwork();
    final exists = _users.findByPhone(phone) != null;
    return switch ((mode, exists)) {
      (AuthMode.login, false) => const Result.failure(
        AuthFailure(AuthFailureReason.phoneNotRegistered),
      ),
      (AuthMode.register, true) => const Result.failure(
        AuthFailure(AuthFailureReason.phoneAlreadyRegistered),
      ),
      _ => const Result.success(null),
    };
  }

  @override
  Future<Result<OtpOutcome>> verifyOtp({
    required String phone,
    required String code,
    required AuthMode mode,
  }) async {
    await _simulateNetwork();
    if (code != FakeAuthConfig.otpCode) {
      return const Result.failure(AuthFailure(AuthFailureReason.invalidOtp));
    }
    if (mode == AuthMode.register) return Result.success(PhoneVerified(phone));
    final user = _users.findByPhone(phone);
    if (user == null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.phoneNotRegistered),
      );
    }
    await _startSession(user.userId);
    return Result.success(SignedIn(user.toDomain()));
  }

  @override
  Future<Result<AuthUser>> register(NewUserProfile profile) async {
    await _simulateNetwork();
    if (_users.findByPhone(profile.phone) != null) {
      return const Result.failure(
        AuthFailure(AuthFailureReason.phoneAlreadyRegistered),
      );
    }
    final user = AuthUser(
      id: 'u_${_randomHex()}',
      phone: profile.phone,
      firstName: profile.firstName,
      lastName: profile.lastName,
      dateOfBirth: profile.dateOfBirth,
    );
    await _users.save(UserEntity.fromDomain(user));
    await _startSession(user.id);
    return Result.success(user);
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final session = await _session.read();
    if (session == null) return null;
    final user = _users.findById(session.userId);
    if (user == null) await _session.clear();
    return user?.toDomain();
  }

  @override
  Future<void> logOut() => _session.clear();

  Future<void> _startSession(String userId) => _session.write(
    StoredSession(userId: userId, token: 'fake_${_randomHex()}'),
  );

  Future<void> _simulateNetwork() => Future<void>.delayed(latency);

  String _randomHex() =>
      List.generate(16, (_) => _random.nextInt(16).toRadixString(16)).join();
}

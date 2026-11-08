import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/core/session/session_storage.dart';
import 'package:j_donut_shop/features/auth/data/datasources/user_local_data_source.dart';
import 'package:j_donut_shop/features/auth/data/models/user_entity.dart';
import 'package:j_donut_shop/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_user.dart';
import 'package:j_donut_shop/features/auth/domain/entities/new_user_profile.dart';
import 'package:j_donut_shop/features/auth/domain/entities/otp_outcome.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/auth_mocks.dart';
import '../../../helpers/in_memory_session_storage.dart';

class MockUserLocalDataSource extends Mock implements UserLocalDataSource {}

void main() {
  const phone = '+959254135592';
  late MockUserLocalDataSource users;
  late InMemorySessionStorage session;
  late FakeAuthRepository repository;
  final storedSession = StoredSession(userId: testUser.id, token: 't');

  setUpAll(() => registerFallbackValue(UserEntity.fromDomain(testUser)));

  setUp(() {
    users = MockUserLocalDataSource();
    session = InMemorySessionStorage();
    repository = FakeAuthRepository(users, session, latency: Duration.zero);
    when(() => users.findByPhone(any())).thenReturn(null);
    when(() => users.save(any())).thenAnswer((_) async {});
  });

  AuthFailureReason? reasonOf(Result<Object?> result) => result.fold(
    onSuccess: (_) => null,
    onFailure: (failure) => (failure as AuthFailure).reason,
  );

  test(
    'log in with an unregistered number fails with phoneNotRegistered',
    () async {
      final result = await repository.requestOtp(
        phone: phone,
        mode: AuthMode.login,
      );
      expect(reasonOf(result), AuthFailureReason.phoneNotRegistered);
    },
  );

  test(
    'register with an existing number fails with phoneAlreadyRegistered',
    () async {
      when(() => users.findByPhone(phone))
          .thenReturn(UserEntity.fromDomain(testUser));
      final result = await repository.requestOtp(
        phone: phone,
        mode: AuthMode.register,
      );
      expect(reasonOf(result), AuthFailureReason.phoneAlreadyRegistered);
    },
  );

  test('any code other than 123456 is rejected', () async {
    final result = await repository.verifyOtp(
      phone: phone,
      code: '000000',
      mode: AuthMode.register,
    );
    expect(reasonOf(result), AuthFailureReason.invalidOtp);
  });

  test(
    'the fake code verifies the phone on register without a session',
    () async {
      final result = await repository.verifyOtp(
        phone: phone,
        code: FakeAuthConfig.otpCode,
        mode: AuthMode.register,
      );
      expect((result as Success<OtpOutcome>).value, isA<PhoneVerified>());
      expect(session.value, isNull);
    },
  );

  test(
    'the fake code signs an existing user in and stores a session',
    () async {
      when(() => users.findByPhone(phone))
          .thenReturn(UserEntity.fromDomain(testUser));
      final result = await repository.verifyOtp(
        phone: phone,
        code: FakeAuthConfig.otpCode,
        mode: AuthMode.login,
      );
      expect(
        ((result as Success<OtpOutcome>).value as SignedIn).user,
        testUser,
      );
      expect(session.value?.userId, testUser.id);
    },
  );

  test('register saves the user and starts a session', () async {
    final result = await repository.register(
      NewUserProfile(
        phone: phone,
        firstName: 'Ye Min',
        dateOfBirth: DateTime(1980, 5),
      ),
    );
    final user = (result as Success<AuthUser>).value;
    verify(() => users.save(any())).called(1);
    expect(session.value?.userId, user.id);
  });

  test('restoreSession returns the stored user after relaunch', () async {
    when(() => users.findById(testUser.id))
        .thenReturn(UserEntity.fromDomain(testUser));
    await session.write(storedSession);
    expect(await repository.restoreSession(), testUser);
  });

  test('logOut clears the session so restore returns null', () async {
    await session.write(storedSession);
    await repository.logOut();
    expect(await repository.restoreSession(), isNull);
  });
}

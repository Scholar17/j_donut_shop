import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_user.dart';
import 'package:j_donut_shop/features/auth/domain/entities/new_user_profile.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/register_user.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_mocks.dart';

void main() {
  late MockAuthRepository repository;
  late RegisterUser registerUser;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repository = MockAuthRepository();
    registerUser = RegisterUser(repository, clock: () => DateTime(2026, 11, 8));
    when(() => repository.register(any()))
        .thenAnswer((_) async => Result.success(testUser));
  });

  NewUserProfile profile({
    String first = 'Ye Min',
    String? last,
    DateTime? dob,
  }) => NewUserProfile(
    phone: '+959254135592',
    firstName: first,
    lastName: last,
    dateOfBirth: dob ?? DateTime(1980, 5),
  );

  test('trims names and drops a blank last name before saving', () async {
    await registerUser(profile(first: '  Ye Min ', last: '   '));

    final saved =
        verify(() => repository.register(captureAny())).captured.single
            as NewUserProfile;
    expect(saved.firstName, 'Ye Min');
    expect(saved.lastName, isNull);
  });

  test('rejects a first name with digits', () async {
    final result = await registerUser(profile(first: 'Ye Min 2'));

    expect((result as Error<AuthUser>).failure, isA<ValidationFailure>());
    verifyNever(() => repository.register(any()));
  });

  test('rejects a user younger than the minimum age', () async {
    final result = await registerUser(profile(dob: DateTime(2020)));

    expect((result as Error<AuthUser>).failure, isA<ValidationFailure>());
  });

  test('returns the created user for a valid profile', () async {
    final result = await registerUser(profile(last: 'Phyoe Win'));

    expect((result as Success<AuthUser>).value, testUser);
  });
}

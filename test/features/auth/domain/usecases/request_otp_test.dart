import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/request_otp.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_mocks.dart';

void main() {
  late MockAuthRepository repository;
  late RequestOtp requestOtp;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repository = MockAuthRepository();
    requestOtp = RequestOtp(repository);
  });

  test('sends the OTP to the normalized E.164 number', () async {
    when(
      () => repository.requestOtp(
        phone: any(named: 'phone'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await requestOtp(
      rawPhone: '09 254 135 592',
      mode: AuthMode.register,
    );

    expect((result as Success<String>).value, '+959254135592');
    verify(
      () => repository.requestOtp(
        phone: '+959254135592',
        mode: AuthMode.register,
      ),
    ).called(1);
  });

  test('rejects an invalid phone without calling the repository', () async {
    final result = await requestOtp(rawPhone: '123', mode: AuthMode.login);

    expect((result as Error<String>).failure, isA<ValidationFailure>());
    verifyNever(
      () => repository.requestOtp(
        phone: any(named: 'phone'),
        mode: any(named: 'mode'),
      ),
    );
  });

  test('passes through an unregistered-number failure on log in', () async {
    const failure = AuthFailure(AuthFailureReason.phoneNotRegistered);
    when(
      () => repository.requestOtp(
        phone: any(named: 'phone'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer((_) async => const Result.failure(failure));

    final result = await requestOtp(
      rawPhone: '09254135592',
      mode: AuthMode.login,
    );

    expect((result as Error<String>).failure, failure);
  });
}

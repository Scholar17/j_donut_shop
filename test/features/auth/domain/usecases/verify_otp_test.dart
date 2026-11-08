import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/domain/entities/otp_outcome.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/verify_otp.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_mocks.dart';

void main() {
  late MockAuthRepository repository;
  late VerifyOtp verifyOtp;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repository = MockAuthRepository();
    verifyOtp = VerifyOtp(repository);
  });

  test('rejects an incomplete code without calling the repository', () async {
    final result = await verifyOtp(
      phone: '+959254135592',
      code: '123',
      mode: AuthMode.login,
    );

    expect((result as Error<OtpOutcome>).failure, isA<ValidationFailure>());
    verifyZeroInteractions(repository);
  });

  test('returns the signed-in user for a correct code on log in', () async {
    when(
      () => repository.verifyOtp(
        phone: any(named: 'phone'),
        code: any(named: 'code'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer((_) async => Result.success(SignedIn(testUser)));

    final result = await verifyOtp(
      phone: '+959254135592',
      code: '123456',
      mode: AuthMode.login,
    );

    expect(((result as Success<OtpOutcome>).value as SignedIn).user, testUser);
  });
}

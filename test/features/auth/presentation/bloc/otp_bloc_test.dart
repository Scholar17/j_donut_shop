import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/domain/entities/otp_outcome.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/request_otp.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/verify_otp.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_mocks.dart';

const _phone = '+959254135592';

void main() {
  late MockAuthRepository repository;
  late StreamController<int> ticks;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repository = MockAuthRepository();
    ticks = StreamController<int>.broadcast();
  });

  tearDown(() => ticks.close());

  OtpBloc build() => OtpBloc(
    verifyOtp: VerifyOtp(repository),
    requestOtp: RequestOtp(repository),
    mode: AuthMode.register,
    phone: _phone,
    ticker: (_) => ticks.stream,
  );

  void stubVerify(Result<OtpOutcome> result) => when(
    () => repository.verifyOtp(
      phone: any(named: 'phone'),
      code: any(named: 'code'),
      mode: any(named: 'mode'),
    ),
  ).thenAnswer((_) async => result);

  const wrong = Result<OtpOutcome>.failure(
    AuthFailure(AuthFailureReason.invalidOtp),
  );

  /// Enters [code] and waits until verification has finished either way.
  Future<void> enterCode(OtpBloc bloc, String code) async {
    final shakes = bloc.state.shakeCount;
    final done = bloc.stream.firstWhere(
      (s) => s.status == OtpStatus.verified || s.shakeCount > shakes,
    );
    bloc.add(OtpCodeChanged(code));
    await done;
  }

  test('starts with a 5:00 resend countdown', () {
    expect(build().state.secondsLeft, 300);
  });

  test('verifies automatically once all six digits are entered', () async {
    stubVerify(const Result.success(PhoneVerified(_phone)));
    final bloc = build();

    await enterCode(bloc, '123456');

    expect(bloc.state.status, OtpStatus.verified);
    expect(bloc.state.outcome, isA<PhoneVerified>());
  });

  test('a wrong code clears the boxes and triggers a shake', () async {
    stubVerify(wrong);
    final bloc = build();

    await enterCode(bloc, '000000');

    expect(bloc.state.code, isEmpty);
    expect(bloc.state.shakeCount, 1);
    expect(bloc.state.attemptsLeft, 2);
  });

  test('three wrong codes lock entry', () async {
    stubVerify(wrong);
    final bloc = build();
    for (var i = 0; i < 3; i++) {
      await enterCode(bloc, '000000');
    }

    expect(bloc.state.isLocked, isTrue);
    bloc.add(const OtpCodeChanged('1'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.code, isEmpty);
  });

  blocTest<OtpBloc, OtpState>(
    'Resend is ignored while the countdown is running',
    build: build,
    act: (bloc) => bloc.add(const OtpResendPressed()),
    expect: () => <OtpState>[],
    verify: (_) => verifyNever(
      () => repository.requestOtp(
        phone: any(named: 'phone'),
        mode: any(named: 'mode'),
      ),
    ),
  );

  test('Resend at 0:00 unlocks entry and restarts the timer', () async {
    stubVerify(wrong);
    when(
      () => repository.requestOtp(
        phone: any(named: 'phone'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer((_) async => const Result.success(null));
    final bloc = build();
    for (var i = 0; i < 3; i++) {
      await enterCode(bloc, '000000');
    }
    ticks.add(0);
    await bloc.stream.firstWhere((s) => s.canResend);

    bloc.add(const OtpResendPressed());
    await bloc.stream.firstWhere(
      (s) => s.status == OtpStatus.editing && s.secondsLeft == 300,
    );

    expect(bloc.state.isLocked, isFalse);
    verify(() => repository.requestOtp(phone: _phone, mode: AuthMode.register))
        .called(1);
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/request_otp.dart';
import 'package:j_donut_shop/features/auth/domain/validators/phone_validator.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/phone_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUpAll(registerAuthFallbacks);
  setUp(() => repository = MockAuthRepository());

  PhoneBloc build({AuthMode mode = AuthMode.register}) =>
      PhoneBloc(RequestOtp(repository), mode: mode);

  void stubRequest(Future<Result<void>> Function() answer) => when(
    () => repository.requestOtp(
      phone: any(named: 'phone'),
      mode: any(named: 'mode'),
    ),
  ).thenAnswer((_) => answer());

  test('Continue is disabled until the number is valid', () {
    final bloc = build();
    expect(bloc.state.canSubmit, isFalse);
    bloc.add(const PhoneChanged('09254135592'));
    expectLater(bloc.stream.map((s) => s.canSubmit), emits(isTrue));
  });

  blocTest<PhoneBloc, PhoneState>(
    'hides the inline error while typing and shows it after focus is lost',
    build: build,
    act: (bloc) => bloc
      ..add(const PhoneChanged('0925'))
      ..add(const PhoneFocusLost()),
    expect: () => [
      isA<PhoneState>().having((s) => s.visibleError, 'visibleError', isNull),
      isA<PhoneState>().having(
        (s) => s.visibleError,
        'visibleError',
        PhoneValidationError.invalid,
      ),
    ],
  );

  blocTest<PhoneBloc, PhoneState>(
    'a double tap on Continue sends exactly one request',
    setUp: () => stubRequest(() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return const Result.success(null);
    }),
    build: build,
    seed: () => const PhoneState(raw: '09254135592'),
    act: (bloc) => bloc
      ..add(const PhoneSubmitted())
      ..add(const PhoneSubmitted()),
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<PhoneState>().having(
        (s) => s.status,
        'status',
        SubmitStatus.submitting,
      ),
      isA<PhoneState>()
          .having((s) => s.status, 'status', SubmitStatus.success)
          .having((s) => s.sentTo, 'sentTo', '+959254135592'),
    ],
    verify: (_) => verify(
      () => repository.requestOtp(
        phone: any(named: 'phone'),
        mode: any(named: 'mode'),
      ),
    ).called(1),
  );

  blocTest<PhoneBloc, PhoneState>(
    'log in with an unregistered number surfaces phoneNotRegistered',
    setUp: () => stubRequest(
      () async => const Result.failure(
        AuthFailure(AuthFailureReason.phoneNotRegistered),
      ),
    ),
    build: () => build(mode: AuthMode.login),
    seed: () => const PhoneState(raw: '09254135592'),
    act: (bloc) => bloc.add(const PhoneSubmitted()),
    skip: 1,
    expect: () => [
      isA<PhoneState>().having(
        (s) => (s.failure! as AuthFailure).reason,
        'reason',
        AuthFailureReason.phoneNotRegistered,
      ),
    ],
  );

  blocTest<PhoneBloc, PhoneState>(
    'editing the number clears a previous failure',
    build: build,
    seed: () => const PhoneState(
      raw: '09254135592',
      status: SubmitStatus.failure,
      failure: AuthFailure(AuthFailureReason.phoneNotRegistered),
    ),
    act: (bloc) => bloc.add(const PhoneChanged('0925413559')),
    expect: () => [
      isA<PhoneState>().having((s) => s.failure, 'failure', isNull),
    ],
  );
}

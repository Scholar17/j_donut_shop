import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/domain/entities/otp_outcome.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/request_otp.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/verify_otp.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:j_donut_shop/features/auth/presentation/pages/otp_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockAuthRepository repository;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repository = MockAuthRepository();
    when(
      () => repository.verifyOtp(
        phone: any(named: 'phone'),
        code: any(named: 'code'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer((invocation) async {
      final code = invocation.namedArguments[#code] as String;
      return code == '123456'
          ? const Result.success(PhoneVerified('+959254135592'))
          : const Result.failure(AuthFailure(AuthFailureReason.invalidOtp));
    });
  });

  Future<void> pumpOtp(WidgetTester tester) => tester.pumpPage(
    BlocProvider(
      create: (_) => OtpBloc(
        verifyOtp: VerifyOtp(repository),
        requestOtp: RequestOtp(repository),
        mode: AuthMode.register,
        phone: '+959254135592',
        ticker: (_) => const Stream<int>.empty(),
      ),
      child: const OtpPage(),
    ),
  );

  Finder field() => find.byKey(const Key('otp.field'));

  testWidgets('shows the number the code was sent to and a 5:00 countdown', (
    tester,
  ) async {
    await pumpOtp(tester);

    expect(
      find.text("We've sent 6 digit OTP to +959254135592"),
      findsOneWidget,
    );
    expect(find.textContaining('5:00'), findsOneWidget);
  });

  testWidgets('a pasted code fills all six boxes', (tester) async {
    // Keep verification pending so the filled boxes stay on screen.
    when(
      () => repository.verifyOtp(
        phone: any(named: 'phone'),
        code: any(named: 'code'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer((_) => Completer<Result<OtpOutcome>>().future);
    await pumpOtp(tester);
    await tester.enterText(field(), '654321');
    await tester.pump();

    for (final digit in '654321'.split('')) {
      expect(find.text(digit), findsWidgets);
    }
  });

  testWidgets('a wrong code clears the boxes and explains attempts left', (
    tester,
  ) async {
    await pumpOtp(tester);
    await tester.enterText(field(), '000000');
    await tester.pumpAndSettle();

    expect(find.text('Wrong code. 2 attempts left'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('three wrong codes lock entry until Resend', (tester) async {
    await pumpOtp(tester);
    for (var i = 0; i < 3; i++) {
      await tester.enterText(field(), '000000');
      await tester.pumpAndSettle();
    }

    expect(
      find.text('Too many wrong codes. Tap Resend to get a new code.'),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(field()).enabled, isFalse);
  });

  testWidgets('the fake code 123456 continues to the name step', (
    tester,
  ) async {
    await pumpOtp(tester);
    await tester.enterText(field(), '123456');
    await tester.pumpAndSettle();

    expect(find.text('route:/register/name'), findsOneWidget);
  });
}

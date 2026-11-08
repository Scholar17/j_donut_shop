import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/request_otp.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/auth_flow_cubit.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/phone_bloc.dart';
import 'package:j_donut_shop/features/auth/presentation/pages/phone_page.dart';
import 'package:j_donut_shop/core/widgets/primary_button.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockAuthRepository repository;

  setUpAll(registerAuthFallbacks);
  setUp(() => repository = MockAuthRepository());

  Future<void> pumpPhone(
    WidgetTester tester, {
    AuthMode mode = AuthMode.register,
  }) => tester.pumpPage(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthFlowCubit(mode)),
        BlocProvider(
          create: (_) => PhoneBloc(RequestOtp(repository), mode: mode),
        ),
      ],
      child: const PhonePage(),
    ),
  );

  PrimaryButton continueButton(WidgetTester tester) =>
      tester.widget<PrimaryButton>(find.byKey(const Key('phone.continue')));

  testWidgets('Continue stays disabled for an invalid number', (tester) async {
    await pumpPhone(tester);
    await tester.enterText(find.byKey(const Key('phone.field')), '0925');
    await tester.pump();

    expect(continueButton(tester).onPressed, isNull);
  });

  testWidgets('shows the inline error only after the field loses focus', (
    tester,
  ) async {
    await pumpPhone(tester);
    await tester.enterText(find.byKey(const Key('phone.field')), '0925');
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid Myanmar mobile number'), findsNothing);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid Myanmar mobile number'), findsOneWidget);
  });

  testWidgets('a valid number enables Continue and opens the OTP step', (
    tester,
  ) async {
    when(
      () => repository.requestOtp(
        phone: any(named: 'phone'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer((_) async => const Result.success(null));
    await pumpPhone(tester);
    await tester.enterText(
      find.byKey(const Key('phone.field')),
      '09 254 135 592',
    );
    await tester.pump();
    expect(continueButton(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('phone.continue')));
    await tester.pumpAndSettle();

    expect(find.text('route:/register/otp'), findsOneWidget);
  });

  testWidgets('log in with an unregistered number offers Register instead', (
    tester,
  ) async {
    when(
      () => repository.requestOtp(
        phone: any(named: 'phone'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer(
      (_) async => const Result.failure(
        AuthFailure(AuthFailureReason.phoneNotRegistered),
      ),
    );
    await pumpPhone(tester, mode: AuthMode.login);
    await tester.enterText(find.byKey(const Key('phone.field')), '09254135592');
    await tester.pump();
    await tester.tap(find.byKey(const Key('phone.continue')));
    await tester.pumpAndSettle();

    expect(find.text("This number isn't registered yet."), findsOneWidget);
    expect(find.text('Register instead'), findsOneWidget);
  });
}

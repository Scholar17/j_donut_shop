import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/result.dart';
import 'package:j_donut_shop/core/widgets/primary_button.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/register_user.dart';
import 'package:j_donut_shop/features/auth/domain/usecases/session_usecases.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/auth_flow_cubit.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/dob_bloc.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/session_cubit.dart';
import 'package:j_donut_shop/features/auth/presentation/pages/dob_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockAuthRepository repository;
  late SessionCubit session;
  final today = DateTime(2026, 11, 8);

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repository = MockAuthRepository();
    session = SessionCubit(RestoreSession(repository), LogOut(repository));
  });

  Future<void> pumpDob(WidgetTester tester, {int? month}) => tester.pumpPage(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider(
          create: (_) => AuthFlowCubit(AuthMode.register)
            ..otpSent('+959254135592')
            ..nameChanged(first: 'Ye Min', last: 'Phyoe Win'),
        ),
        BlocProvider(
          create: (_) => DobBloc(
            RegisterUser(repository, clock: () => today),
            clock: () => today,
            month: month,
          ),
        ),
      ],
      child: const DobPage(),
    ),
  );

  Future<void> enterDate(
    WidgetTester tester, {
    required String day,
    required String year,
  }) async {
    await tester.enterText(find.byKey(const Key('dob.day')), day);
    await tester.enterText(find.byKey(const Key('dob.year')), year);
    await tester.pumpAndSettle();
  }

  bool continueEnabled(WidgetTester tester) =>
      tester
          .widget<PrimaryButton>(find.byKey(const Key('dob.continue')))
          .onPressed !=
      null;

  testWidgets('31 April is rejected inline and Continue stays disabled', (
    tester,
  ) async {
    await pumpDob(tester, month: 4);
    await enterDate(tester, day: '31', year: '1990');

    expect(find.text("This date doesn't exist"), findsOneWidget);
    expect(continueEnabled(tester), isFalse);
  });

  testWidgets('29 February is accepted only in a leap year', (tester) async {
    await pumpDob(tester, month: 2);
    await enterDate(tester, day: '29', year: '2001');
    expect(find.text("This date doesn't exist"), findsOneWidget);

    await enterDate(tester, day: '29', year: '2000');
    expect(find.text("This date doesn't exist"), findsNothing);
    expect(continueEnabled(tester), isTrue);
  });

  testWidgets('someone younger than 13 cannot continue', (tester) async {
    await pumpDob(tester, month: 1);
    await enterDate(tester, day: '1', year: '2020');

    expect(find.text('You must be at least 13 years old'), findsOneWidget);
    expect(continueEnabled(tester), isFalse);
  });

  testWidgets('picking a month from the sheet fills the field', (tester) async {
    await pumpDob(tester);
    await tester.tap(find.byKey(const Key('dob.month')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('May').last);
    await tester.pumpAndSettle();

    expect(find.text('May'), findsOneWidget);
  });

  testWidgets('a double tap on Continue registers once and marks a new user', (
    tester,
  ) async {
    when(() => repository.register(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return Result.success(testUser);
    });
    await pumpDob(tester, month: 5);
    await enterDate(tester, day: '1', year: '1980');

    await tester.tap(find.byKey(const Key('dob.continue')));
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('dob.continue')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    verify(() => repository.register(any())).called(1);
    expect(session.state, SessionAuthenticated(testUser, pendingWelcome: true));
  });
}

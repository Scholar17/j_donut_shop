import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/widgets/primary_button.dart';
import 'package:j_donut_shop/features/auth/domain/entities/auth_mode.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/auth_flow_cubit.dart';
import 'package:j_donut_shop/features/auth/presentation/bloc/name_cubit.dart';
import 'package:j_donut_shop/features/auth/presentation/pages/name_page.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late AuthFlowCubit flow;

  Future<void> pumpName(WidgetTester tester, {String first = ''}) {
    flow = AuthFlowCubit(AuthMode.register);
    return tester.pumpPage(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: flow),
          BlocProvider(create: (_) => NameCubit(first: first)),
        ],
        child: const NamePage(),
      ),
    );
  }

  bool continueEnabled(WidgetTester tester) =>
      tester
          .widget<PrimaryButton>(find.byKey(const Key('name.continue')))
          .onPressed !=
      null;

  Future<void> blur(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  testWidgets('Continue is disabled until a first name is entered', (
    tester,
  ) async {
    await pumpName(tester);
    expect(continueEnabled(tester), isFalse);

    await tester.enterText(find.byKey(const Key('name.first')), 'Ye Min');
    await tester.pump();

    expect(continueEnabled(tester), isTrue);
  });

  testWidgets('a digit in the first name shows an inline message after blur', (
    tester,
  ) async {
    await pumpName(tester);
    await tester.enterText(find.byKey(const Key('name.first')), 'Ye Min 2');
    await blur(tester);

    expect(find.text('Use letters and spaces only'), findsOneWidget);
    expect(continueEnabled(tester), isFalse);
  });

  testWidgets('accepts a Myanmar-script name and an empty last name', (
    tester,
  ) async {
    await pumpName(tester);
    await tester.enterText(find.byKey(const Key('name.first')), 'မောင်မောင်');
    await blur(tester);

    expect(find.text('Use letters and spaces only'), findsNothing);
    expect(continueEnabled(tester), isTrue);
  });

  testWidgets('an invalid last name blocks Continue', (tester) async {
    await pumpName(tester, first: 'Ye Min');
    await tester.enterText(find.byKey(const Key('name.last')), 'Win9');
    await blur(tester);

    expect(find.text('Use letters and spaces only'), findsOneWidget);
    expect(continueEnabled(tester), isFalse);
  });

  testWidgets(
    'Continue saves the names into the draft and opens date of birth',
    (tester) async {
      await pumpName(tester);
      await tester.enterText(find.byKey(const Key('name.first')), 'Ye Min');
      await tester.enterText(find.byKey(const Key('name.last')), 'Phyoe Win');
      await tester.pump();
      await tester.tap(find.byKey(const Key('name.continue')));
      await tester.pumpAndSettle();

      expect(flow.state.firstName, 'Ye Min');
      expect(flow.state.lastName, 'Phyoe Win');
      expect(find.text('route:/register/dob'), findsOneWidget);
    },
  );
}

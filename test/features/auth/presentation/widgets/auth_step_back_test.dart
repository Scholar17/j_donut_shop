import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:j_donut_shop/core/theme/app_theme.dart';
import 'package:j_donut_shop/features/auth/presentation/widgets/auth_step_scaffold.dart';
import 'package:j_donut_shop/l10n/generated/app_localizations.dart';

/// Same shape as the app: Onboarding, then the steps inside a ShellRoute
/// (which has its own nested Navigator).
GoRouter _router() => GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, _) => Scaffold(
        body: TextButton(
          onPressed: () => context.push('/register/phone'),
          child: const Text('onboarding'),
        ),
      ),
    ),
    ShellRoute(
      builder: (_, _, child) => child,
      routes: [
        GoRoute(
          path: '/register/phone',
          builder: (context, _) => AuthStepScaffold(
            step: 1,
            title: 'phone',
            body: TextButton(
              onPressed: () => context.push('/register/otp'),
              child: const Text('next'),
            ),
          ),
        ),
        GoRoute(
          path: '/register/otp',
          builder: (_, _) =>
              const AuthStepScaffold(step: 2, title: 'otp', body: SizedBox()),
        ),
      ],
    ),
  ],
);

Future<void> _pump(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapBack(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_rounded));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('back on the first step returns to Onboarding', (tester) async {
    final router = _router();
    await _pump(tester, router);
    await tester.tap(find.text('onboarding'));
    await tester.pumpAndSettle();
    expect(find.text('phone'), findsOneWidget);

    await _tapBack(tester);

    expect(find.text('onboarding'), findsOneWidget);
  });

  testWidgets('back on a later step returns to the previous step', (
    tester,
  ) async {
    final router = _router();
    await _pump(tester, router);
    await tester.tap(find.text('onboarding'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();
    expect(find.text('otp'), findsOneWidget);

    await _tapBack(tester);

    expect(find.text('phone'), findsOneWidget);
  });

  testWidgets('back with nothing to pop goes to Onboarding', (tester) async {
    final router = _router()..go('/register/phone');
    await _pump(tester, router);

    await _tapBack(tester);

    expect(find.text('onboarding'), findsOneWidget);
  });
}

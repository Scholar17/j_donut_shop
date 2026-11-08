import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:j_donut_shop/core/theme/app_theme.dart';
import 'package:j_donut_shop/l10n/generated/app_localizations.dart';

/// Pumps [page] at `/` inside a minimal router with the real theme and
/// localizations. Any other path renders a marker text, so tests can assert
/// navigation by finding `Text('route:<path>')`.
extension PumpApp on WidgetTester {
  Future<void> pumpPage(
    Widget page, {
    Locale locale = const Locale('en'),
  }) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => page),
        GoRoute(
          path: '/:a/:b',
          builder: (_, state) =>
              Scaffold(body: Text('route:${state.uri.path}')),
        ),
      ],
    );
    await pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
    await pumpAndSettle();
  }
}

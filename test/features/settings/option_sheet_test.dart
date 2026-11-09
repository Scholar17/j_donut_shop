import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/theme/app_theme.dart';
import 'package:j_donut_shop/features/settings/domain/app_preferences.dart';
import 'package:j_donut_shop/features/settings/presentation/widgets/option_sheet.dart';

/// A tab-shell look-alike: a nested Navigator for the body and a bottom bar
/// owned by the outer Scaffold, like the app's StatefulShellRoute.
Widget _shell(void Function(BuildContext) onOpen) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => onOpen(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
    bottomNavigationBar: const SizedBox(
      key: Key('navBar'),
      height: 72,
      child: Text('nav'),
    ),
  ),
);

void main() {
  testWidgets('returns the tapped option', (tester) async {
    AppLanguage? picked;
    await tester.pumpWidget(
      _shell((context) async {
        picked = await showOptionSheet(
          context,
          title: 'Language',
          current: AppLanguage.english,
          options: const {
            AppLanguage.english: 'English',
            AppLanguage.myanmar: 'မြန်မာ',
          },
        );
      }),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('မြန်မာ'));
    await tester.pumpAndSettle();

    expect(picked, AppLanguage.myanmar);
    expect(find.text('Language'), findsNothing);
  });

  testWidgets('opens over the bottom navigation bar', (tester) async {
    await tester.pumpWidget(
      _shell(
        (context) => showOptionSheet(
          context,
          title: 'Appearance',
          current: ThemePreference.system,
          options: const {
            ThemePreference.system: 'System',
            ThemePreference.light: 'Light',
            ThemePreference.dark: 'Dark',
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final sheetBottom = tester.getBottomLeft(find.byType(BottomSheet)).dy;
    final navTop = tester.getTopLeft(find.byKey(const Key('navBar'))).dy;
    final screenBottom =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(navTop, lessThan(screenBottom));
    expect(sheetBottom, screenBottom);
  });
}

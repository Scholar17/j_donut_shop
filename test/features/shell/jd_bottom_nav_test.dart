import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/theme/app_theme.dart';
import 'package:j_donut_shop/features/shell/presentation/jd_bottom_nav.dart';

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  var index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: JdBottomNav(
      currentIndex: index,
      onSelected: (i) => setState(() => index = i),
      items: const [
        JdNavItem(icon: Icons.home_outlined, label: 'Home'),
        JdNavItem(icon: Icons.emoji_events_outlined, label: 'Reward'),
        JdNavItem(icon: Icons.receipt_long_outlined, label: 'Order'),
        JdNavItem(icon: Icons.wallet_outlined, label: 'Wallet'),
        JdNavItem(icon: Icons.settings_outlined, label: 'Settings'),
      ],
    ),
  );
}

void main() {
  Future<void> pumpNav(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: const _Host()),
  );

  double slotWidth(WidgetTester tester, int i) =>
      tester.getSize(find.byKey(Key('nav.$i'))).width;

  testWidgets('the pill appears on the tapped tab and grows there', (
    tester,
  ) async {
    await pumpNav(tester);
    final activeWidth = slotWidth(tester, 0);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav.1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    // Mid-animation: label already lives in the new tab, which is still
    // narrower than a settled active tab; the old tab lost its label.
    expect(find.text('Reward'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(slotWidth(tester, 1), lessThan(activeWidth));

    // Step every frame: the growing slot must never overflow.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpAndSettle();
    expect(slotWidth(tester, 1), moreOrLessEquals(activeWidth));
  });

  testWidgets('marks only the current tab as selected', (tester) async {
    await pumpNav(tester);
    await tester.tap(find.byKey(const Key('nav.4')));
    await tester.pumpAndSettle();

    bool? selected(int i) => tester
        .widget<Semantics>(
          find
              .ancestor(
                of: find.byKey(Key('nav.$i')),
                matching: find.byType(Semantics),
              )
              .first,
        )
        .properties
        .selected;

    expect(selected(4), isTrue);
    expect(selected(0), isFalse);
  });

  testWidgets('cyan bar is inset over a grey band and a pink strip', (
    tester,
  ) async {
    await pumpNav(tester);

    final screen = tester.getSize(find.byType(Scaffold));
    final strip = tester.getRect(find.byKey(const Key('nav.baseStrip')));
    // The Container's own rect includes its margin; measure the painted bar.
    final bar = tester.getRect(
      find
          .descendant(
            of: find.byKey(const Key('nav.bar')),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );

    // Full-width strip from the screen bottom up to the bar's middle.
    expect(strip.width, screen.width);
    expect(strip.bottom, screen.height);
    expect(strip.top, moreOrLessEquals(bar.center.dy, epsilon: 1));
    // Grey band from the bar's top edge down to the pink strip.
    final top = tester.getRect(find.byKey(const Key('nav.topStrip')));
    expect(top.width, screen.width);
    expect(top.top, moreOrLessEquals(bar.top, epsilon: 1));
    expect(top.bottom, moreOrLessEquals(strip.top, epsilon: 1));
    // The bar leaves a gap at both screen edges.
    expect(bar.left, greaterThan(0));
    expect(bar.right, lessThan(screen.width));
  });

  testWidgets('upper band colour is configurable per tab', (tester) async {
    Color bandColor() =>
        tester.widget<ColoredBox>(find.byKey(const Key('nav.topStrip'))).color;

    Future<void> pumpBand(Color? color) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: JdBottomNav(
            currentIndex: 0,
            onSelected: (_) {},
            upperBandColor: color,
            items: const [
              JdNavItem(icon: Icons.home_outlined, label: 'Home'),
              JdNavItem(icon: Icons.settings_outlined, label: 'Settings'),
            ],
          ),
        ),
      ),
    );

    await pumpBand(null);
    expect(bandColor(), AppTheme.light.colorScheme.surface);

    await pumpBand(const Color(0xFFEBF0F0));
    expect(bandColor(), const Color(0xFFEBF0F0));
  });
}

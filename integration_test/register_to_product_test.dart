import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:j_donut_shop/bootstrap.dart';

/// Register → Home → Product detail on a real device or simulator, against
/// the real ObjectBox store, secure storage and fake auth (1 s per call).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a new user registers, lands on Home and opens a product', (
    tester,
  ) async {
    await tester.pumpWidget(await bootstrap());
    await _pumpUntil(tester, find.byKey(const Key('onboarding.getStarted')));

    await tester.tap(find.byKey(const Key('onboarding.getStarted')));
    await _enterAndContinue(tester, 'phone', _uniquePhone());

    await _pumpUntil(tester, find.byKey(const Key('otp.field')));
    await tester.enterText(find.byKey(const Key('otp.field')), '123456');

    await _pumpUntil(tester, find.byKey(const Key('name.first')));
    await tester.enterText(find.byKey(const Key('name.first')), 'Ye Min');
    await tester.enterText(find.byKey(const Key('name.last')), 'Phyoe Win');
    await _tapWhenReady(tester, const Key('name.continue'));

    await _pumpUntil(tester, find.byKey(const Key('dob.month')));
    await tester.tap(find.byKey(const Key('dob.month')));
    await _pumpUntil(tester, find.text('May'));
    await tester.tap(find.text('May').last);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byKey(const Key('dob.day')), '1');
    await tester.enterText(find.byKey(const Key('dob.year')), '1980');
    await _tapWhenReady(tester, const Key('dob.continue'));

    await _pumpUntil(tester, find.byKey(const Key('welcome.explore')));
    await _tapWhenReady(tester, const Key('welcome.explore'));

    // Home greets the registered user from the single member record.
    await _pumpUntil(tester, find.text('Ye Min'));
    expect(find.text('Silver member'), findsOneWidget);

    // First Seasonal special: fully on screen on every phone size.
    await tester.tap(find.text('Mistletoe Romance box').first);

    await _pumpUntil(tester, find.byKey(const Key('product.addToCart')));
    expect(find.text('JD050010'), findsOneWidget);
    expect(find.text('18,000 MMK'), findsNWidgets(2)); // price + button total
    await tester.tap(find.byKey(const Key('qty.plus')));
    await tester.pump(const Duration(milliseconds: 400));
    // Live total on the button: 2 × 18,000.
    expect(find.text('36,000 MMK'), findsOneWidget);
  });
}

/// A never-registered number per run (registered users persist on device).
String _uniquePhone() {
  final digits = DateTime.now().millisecondsSinceEpoch.toString();
  return '09${digits.substring(digits.length - 9)}';
}

Future<void> _enterAndContinue(
  WidgetTester tester,
  String step,
  String text,
) async {
  await _pumpUntil(tester, find.byKey(Key('$step.field')));
  await tester.enterText(find.byKey(Key('$step.field')), text);
  await _tapWhenReady(tester, Key('$step.continue'));
}

Future<void> _tapWhenReady(WidgetTester tester, Key key) async {
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.byKey(key));
  await tester.pump();
}

/// Pumps frames until [finder] matches; avoids pumpAndSettle, which never
/// settles while shimmer or the banner carousel are animating.
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  final texts = find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>()
      .take(40)
      .join(' | ');
  final types =
      [
            'ProductDetailPage',
            'HomePage',
            '_DetailSkeleton',
            '_DetailError',
            'Skeleton',
          ]
          .map(
            (t) =>
                '$t=${find.byWidgetPredicate((w) => w.runtimeType.toString() == t, skipOffstage: false).evaluate().length}',
          )
          .join(', ');
  final all = find
      .byType(Text, skipOffstage: false)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>()
      .take(25)
      .join(' | ');
  throw TestFailure(
    'Timed out waiting for $finder.\nVisible: $texts\nTypes: $types\nAll: $all',
  );
}

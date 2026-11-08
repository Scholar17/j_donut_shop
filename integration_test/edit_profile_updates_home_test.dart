import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:j_donut_shop/bootstrap.dart';

/// Register → Home → Product detail on a real device or simulator, against
/// the real ObjectBox store, secure storage and fake auth (1 s per call).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('edited profile name shows on Home', (tester) async {
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

    // Edit profile → Home header shows the new name.
    await tester.tap(find.byKey(const Key('nav.4')));
    await _pumpUntil(tester, find.byKey(const Key('settings.profile')));
    await tester.tap(find.byKey(const Key('settings.profile')));
    await _pumpUntil(tester, find.byKey(const Key('profile.first')));
    await tester.enterText(find.byKey(const Key('profile.first')), 'Thaw Zin');
    await _tapWhenReady(tester, const Key('profile.save'));
    await _pumpUntil(tester, find.text('Profile saved'));
    await tester.tap(find.byKey(const Key('nav.0')));
    await _pumpUntil(tester, find.text('Thaw Zin'));
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

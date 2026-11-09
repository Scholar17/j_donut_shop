import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/load_state.dart';
import 'package:j_donut_shop/features/home/domain/entities/shop.dart';
import 'package:j_donut_shop/features/home/domain/repositories/catalog_repository.dart';
import 'package:j_donut_shop/features/home/presentation/pages/shops_page.dart';
import 'package:j_donut_shop/features/home/presentation/widgets/nearby_shops.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockCatalog extends Mock implements CatalogRepository {}

const _shops = [
  Shop(
    id: 's_hledan',
    name: 'Hledan T\'Donuts',
    address: 'Hledan Centre, Kamayut Township, Yangon.',
  ),
  Shop(
    id: 's_kandawgyi',
    name: 'Kandawgyi T\'Donuts',
    address: 'Natmauk Road, Bahan Township, Yangon.',
  ),
];

void main() {
  testWidgets('Explore now calls onExplore', (tester) async {
    var opened = 0;
    await tester.pumpPage(
      Scaffold(
        body: SingleChildScrollView(
          child: NearbyShops(
            shops: const Loaded(_shops),
            onRetry: () {},
            onExplore: () => opened++,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('home.exploreShops')));

    expect(opened, 1);
  });

  testWidgets('ShopsPage lists every shop with its details', (tester) async {
    final catalog = _MockCatalog();
    when(catalog.watchShops).thenAnswer((_) => Stream.value(_shops));

    await tester.pumpPage(ShopsPage(catalog: catalog));

    expect(find.text('Our shops'), findsOneWidget);
    for (final shop in _shops) {
      expect(find.byKey(Key('shops.${shop.id}')), findsOneWidget);
      expect(find.text(shop.name), findsOneWidget);
      expect(find.text(shop.address), findsOneWidget);
    }
    expect(find.text('ORDER ONLINE'), findsNWidgets(_shops.length));
  });

  testWidgets('ShopsPage shows an empty state with no shops', (tester) async {
    final catalog = _MockCatalog();
    when(catalog.watchShops).thenAnswer((_) => Stream.value(const []));

    await tester.pumpPage(ShopsPage(catalog: catalog));

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('ShopsPage shows an error with Retry that re-subscribes', (
    tester,
  ) async {
    final catalog = _MockCatalog();
    var calls = 0;
    when(catalog.watchShops).thenAnswer(
      (_) => calls++ == 0
          ? Stream.error(StateError('db closed'))
          : Stream.value(_shops),
    );

    await tester.pumpPage(ShopsPage(catalog: catalog));
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text(_shops.first.name), findsOneWidget);
  });
}

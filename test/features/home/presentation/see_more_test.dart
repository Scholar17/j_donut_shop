import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/load_state.dart';
import 'package:j_donut_shop/features/home/domain/entities/home_section.dart';
import 'package:j_donut_shop/features/home/domain/repositories/catalog_repository.dart';
import 'package:j_donut_shop/features/home/presentation/pages/section_products_page.dart';
import 'package:j_donut_shop/features/home/presentation/widgets/product_section.dart';
import 'package:j_donut_shop/features/product/domain/entities/product.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockCatalog extends Mock implements CatalogRepository {}

const _products = [
  Product(
    id: 'p_butter_croissant',
    code: 'JD070001',
    name: 'Butter Croissant',
    priceMmk: 2500,
    description: '',
  ),
  Product(
    id: 'p_red_velvet_cake',
    code: 'JD090001',
    name: 'Red Velvet Cake Slice',
    priceMmk: 4800,
    description: '',
    discountPercent: 10,
  ),
];

void main() {
  group('ProductSection see-more arrow', () {
    Widget section({VoidCallback? onSeeMore}) => Scaffold(
      body: ProductSection(
        section: HomeSection.popular,
        state: const Loaded(_products),
        onProductTap: (_, _) {},
        onRetry: () {},
        onSeeMore: onSeeMore,
      ),
    );

    testWidgets('calls onSeeMore when tapped', (tester) async {
      var opened = 0;
      await tester.pumpPage(section(onSeeMore: () => opened++));

      await tester.tap(find.byKey(const Key('home.seeMore.popular')));

      expect(opened, 1);
    });

    testWidgets('is hidden without a handler', (tester) async {
      await tester.pumpPage(section());

      expect(find.byKey(const Key('home.seeMore.popular')), findsNothing);
    });
  });

  group('SectionProductsPage', () {
    late _MockCatalog catalog;

    setUp(() {
      catalog = _MockCatalog();
      when(() => catalog.watchSection(HomeSection.popular))
          .thenAnswer((_) => Stream.value(_products));
    });

    testWidgets('lists every product in the section vertically', (
      tester,
    ) async {
      await tester.pumpPage(
        SectionProductsPage(section: HomeSection.popular, catalog: catalog),
      );

      expect(find.text('Popular 🔥'), findsOneWidget);
      expect(find.text('Butter Croissant'), findsOneWidget);
      expect(find.text('2,500 MMK'), findsOneWidget);
      expect(find.text('Red Velvet Cake Slice'), findsOneWidget);
      expect(find.text('10% off'), findsOneWidget);
    });

    testWidgets('tapping a row opens the product detail', (tester) async {
      await tester.pumpPage(
        SectionProductsPage(section: HomeSection.popular, catalog: catalog),
      );

      await tester.tap(find.text('Butter Croissant'));
      await tester.pumpAndSettle();

      expect(find.text('route:/product/p_butter_croissant'), findsOneWidget);
    });
  });
}

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_donut_shop/core/result/failure.dart';
import 'package:j_donut_shop/core/result/load_state.dart';
import 'package:j_donut_shop/features/product/domain/entities/product.dart';
import 'package:j_donut_shop/features/product/domain/repositories/product_repository.dart';
import 'package:j_donut_shop/features/product/presentation/bloc/product_detail_cubit.dart';

class FakeProductRepository implements ProductRepository {
  final controller = StreamController<Product?>.broadcast();

  @override
  Stream<Product?> watchProduct(String id) => controller.stream;
}

const coconut = Product(
  id: 'p_coconut',
  code: 'JD022123',
  name: 'Coconut Donut',
  priceMmk: 3200,
  description: 'Soft and sweet.',
  isNew: true,
);

void main() {
  late FakeProductRepository repository;

  setUp(() => repository = FakeProductRepository());

  test('total is quantity × price', () {
    const state = ProductDetailState(product: Loaded(coconut), quantity: 3);
    expect(state.total, 9600);
  });

  blocTest<ProductDetailCubit, ProductDetailState>(
    'shows the product read from the local database',
    build: () => ProductDetailCubit(repository, 'p_coconut'),
    act: (_) => repository.controller.add(coconut),
    expect: () => [const ProductDetailState(product: Loaded(coconut))],
  );

  blocTest<ProductDetailCubit, ProductDetailState>(
    'an unknown product id becomes a not-found state',
    build: () => ProductDetailCubit(repository, 'nope'),
    act: (_) => repository.controller.add(null),
    expect: () => [
      isA<ProductDetailState>().having(
        (s) => (s.product as Failed<Product>).failure,
        'failure',
        isA<NotFoundFailure>(),
      ),
    ],
  );

  blocTest<ProductDetailCubit, ProductDetailState>(
    'quantity never drops below 1',
    build: () => ProductDetailCubit(repository, 'p_coconut'),
    act: (cubit) => cubit
      ..decrement()
      ..increment()
      ..decrement()
      ..decrement(),
    expect: () => [
      const ProductDetailState(quantity: 2),
      const ProductDetailState(),
    ],
  );
}

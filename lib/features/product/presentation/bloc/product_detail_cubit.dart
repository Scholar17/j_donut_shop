import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/load_state.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.product = const Loading(),
    this.quantity = minQuantity,
    this.addedCount = 0,
  });

  static const minQuantity = 1;

  final LoadState<Product> product;
  final int quantity;

  /// Incremented on every Add to cart; the UI plays its feedback on change.
  final int addedCount;

  int get total => switch (product) {
    Loaded(:final value) => value.totalFor(quantity),
    _ => 0,
  };

  ProductDetailState copyWith({
    LoadState<Product>? product,
    int? quantity,
    int? addedCount,
  }) => ProductDetailState(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
    addedCount: addedCount ?? this.addedCount,
  );

  @override
  List<Object?> get props => [product, quantity, addedCount];
}

/// Product detail: reads the product from the local database (works
/// offline), quantity stepper with a minimum of 1, Add to cart feedback.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(ProductRepository repository, String productId)
    : super(const ProductDetailState()) {
    _subscription = repository
        .watchProduct(productId)
        .listen(
          (product) => emit(
            state.copyWith(
              product: product == null
                  ? const Failed(NotFoundFailure())
                  : Loaded(product),
            ),
          ),
          onError: (Object error) =>
              emit(state.copyWith(product: Failed(CacheFailure('$error')))),
        );
  }

  late final StreamSubscription<Product?> _subscription;

  void increment() => emit(state.copyWith(quantity: state.quantity + 1));

  void decrement() {
    if (state.quantity <= ProductDetailState.minQuantity) return;
    emit(state.copyWith(quantity: state.quantity - 1));
  }

  /// Visual feedback only (no persistent cart, per the spec).
  void addToCart() => emit(state.copyWith(addedCount: state.addedCount + 1));

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

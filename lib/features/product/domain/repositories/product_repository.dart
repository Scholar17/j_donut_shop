import '../entities/product.dart';

abstract interface class ProductRepository {
  /// Emits the product from the local database, and again whenever a refresh
  /// updates it. Emits `null` if no product has [id].
  Stream<Product?> watchProduct(String id);
}

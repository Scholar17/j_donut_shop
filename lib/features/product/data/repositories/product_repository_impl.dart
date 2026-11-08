import '../../../home/data/datasources/catalog_local_data_source.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._local);

  final CatalogLocalDataSource _local;

  @override
  Stream<Product?> watchProduct(String id) =>
      _local.watchProduct(id).map((row) => row?.toDomain());
}

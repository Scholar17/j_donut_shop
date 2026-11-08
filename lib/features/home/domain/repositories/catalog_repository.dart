import '../../../../core/result/result.dart';
import '../../../product/domain/entities/product.dart';
import '../entities/home_section.dart';
import '../entities/promo_banner.dart';
import '../entities/shop.dart';

/// Public catalogue (banners, sections, shops, products).
///
/// Every `watch*` stream reads the local database only, so the UI works the
/// same online and offline. [refresh] is the only path to the network: it
/// writes into the database, and the streams then emit the new data.
abstract interface class CatalogRepository {
  /// Imports the bundled seed JSON once per seed version (first launch).
  Future<Result<void>> seedIfNeeded();

  Stream<List<PromoBanner>> watchBanners();
  Stream<List<Product>> watchSection(HomeSection section);
  Stream<List<Shop>> watchShops();

  /// Fetches the latest catalogue from the server into the database.
  Future<Result<void>> refresh();

  /// When the last successful refresh happened, `null` if never.
  DateTime? get lastSyncedAt;
}

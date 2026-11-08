import '../../../../objectbox.g.dart';
import '../../../product/data/models/product_entity.dart';
import '../models/catalog_entities.dart';
import 'catalog_snapshot.dart';

/// ObjectBox access for the public catalogue.
class CatalogLocalDataSource {
  CatalogLocalDataSource(this._store);

  final Store _store;

  Box<ProductEntity> get _products => _store.box<ProductEntity>();
  Box<SectionEntity> get _sections => _store.box<SectionEntity>();
  Box<BannerEntity> get _banners => _store.box<BannerEntity>();
  Box<ShopEntity> get _shops => _store.box<ShopEntity>();

  Stream<List<BannerEntity>> watchBanners() =>
      (_banners.query()..order(BannerEntity_.sortOrder))
          .watch(triggerImmediately: true)
          .map((query) => query.find());

  Stream<List<ShopEntity>> watchShops() =>
      (_shops.query()..order(ShopEntity_.sortOrder))
          .watch(triggerImmediately: true)
          .map((query) => query.find());

  /// Sections and products are always written in the same transaction, so
  /// watching the product table is enough to see section changes too.
  Stream<List<ProductEntity>> watchSection(String key) => _products
      .query()
      .watch(triggerImmediately: true)
      .map((_) => _sectionProducts(key));

  Stream<ProductEntity?> watchProduct(String productId) => _products
      .query(ProductEntity_.productId.equals(productId))
      .watch(triggerImmediately: true)
      .map((query) => query.findFirst());

  List<ProductEntity> _sectionProducts(String key) {
    final section = _sections
        .query(SectionEntity_.key.equals(key))
        .build()
        .findFirst();
    if (section == null) return const [];
    final byId = {
      for (final product
          in _products
              .query(ProductEntity_.productId.oneOf(section.productIds))
              .build()
              .find())
        product.productId: product,
    };
    return [for (final id in section.productIds) ?byId[id]];
  }

  bool get isEmpty => _products.isEmpty();

  void _carryOverAssets(CatalogSnapshot snapshot) {
    final products = {
      for (final p in _products.getAll()) p.productId: p.imageAsset,
    };
    final banners = {
      for (final b in _banners.getAll()) b.bannerId: b.imageAsset,
    };
    final shops = {for (final s in _shops.getAll()) s.shopId: s.imageAsset};
    for (final p in snapshot.products) {
      p.imageAsset ??= products[p.productId];
    }
    for (final b in snapshot.banners) {
      b.imageAsset ??= banners[b.bannerId];
    }
    for (final s in snapshot.shops) {
      s.imageAsset ??= shops[s.shopId];
    }
  }

  /// Replaces the whole catalogue atomically: watchers fire once, and a
  /// failed write leaves the previous catalogue untouched.
  ///
  /// Bundled `imageAsset` paths are kept by id: the server does not know about
  /// app assets, and they are what makes images render offline.
  void replaceAll(CatalogSnapshot snapshot) {
    _store.runInTransaction(TxMode.write, () {
      _carryOverAssets(snapshot);
      for (final box in [_products, _sections, _banners, _shops]) {
        box.removeAll();
      }
      _products.putMany(snapshot.products);
      _sections.putMany(snapshot.sections);
      _banners.putMany(snapshot.banners);
      _shops.putMany(snapshot.shops);
    });
  }
}

import '../../../../core/data/json_reader.dart';
import '../../../product/data/models/product_entity.dart';
import '../models/catalog_entities.dart';

/// Everything a refresh or the seed writes into the catalogue tables.
class CatalogSnapshot {
  const CatalogSnapshot({
    required this.products,
    required this.sections,
    required this.banners,
    required this.shops,
  });

  /// Parses the seed file or a combined server payload.
  factory CatalogSnapshot.fromJson(
    Map<String, dynamic> json,
  ) => CatalogSnapshot(
    products: json.readList('products').map(ProductEntity.fromJson).toList(),
    sections: json.readList('sections').map(SectionEntity.fromJson).toList(),
    banners: _indexed(json.readList('banners'), BannerEntity.fromJson),
    shops: _indexed(json.readList('shops'), ShopEntity.fromJson),
  );

  final List<ProductEntity> products;
  final List<SectionEntity> sections;
  final List<BannerEntity> banners;
  final List<ShopEntity> shops;

  /// List position becomes the display order.
  static List<T> _indexed<T>(
    List<Map<String, dynamic>> items,
    T Function(Map<String, dynamic>, int) parse,
  ) => [for (var i = 0; i < items.length; i++) parse(items[i], i)];
}

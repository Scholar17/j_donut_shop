import 'package:objectbox/objectbox.dart';

import '../../../../core/data/json_reader.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/entities/shop.dart';

@Entity()
class BannerEntity {
  BannerEntity({
    required this.bannerId,
    required this.title,
    required this.sortOrder,
    this.badge,
    this.imageUrl,
    this.imageAsset,
    this.id = 0,
  });

  factory BannerEntity.fromJson(Map<String, dynamic> json, int order) =>
      BannerEntity(
        bannerId: json.read<String>('id'),
        title: json.read<String>('title'),
        badge: json.readOrNull<String>('badge'),
        imageUrl: json.readOrNull<String>('imageUrl'),
        imageAsset: json.readOrNull<String>('imageAsset'),
        sortOrder: order,
      );

  @Id()
  int id;
  @Unique(onConflict: ConflictStrategy.replace)
  String bannerId;
  String title;
  String? badge;
  String? imageUrl;
  String? imageAsset;
  int sortOrder;

  PromoBanner toDomain() => PromoBanner(
    id: bannerId,
    title: title,
    badge: badge,
    imageUrl: imageUrl,
    imageAsset: imageAsset,
  );
}

/// Ordered product ids of one Home section.
@Entity()
class SectionEntity {
  SectionEntity({required this.key, required this.productIds, this.id = 0});

  factory SectionEntity.fromJson(Map<String, dynamic> json) => SectionEntity(
    key: json.read<String>('key'),
    productIds: json.read<List<dynamic>>('productIds').cast<String>(),
  );

  @Id()
  int id;
  @Unique(onConflict: ConflictStrategy.replace)
  String key;
  List<String> productIds;
}

@Entity()
class ShopEntity {
  ShopEntity({
    required this.shopId,
    required this.name,
    required this.address,
    required this.sortOrder,
    this.imageUrl,
    this.imageAsset,
    this.id = 0,
  });

  factory ShopEntity.fromJson(Map<String, dynamic> json, int order) =>
      ShopEntity(
        shopId: json.read<String>('id'),
        name: json.read<String>('name'),
        address: json.read<String>('address'),
        imageUrl: json.readOrNull<String>('imageUrl'),
        imageAsset: json.readOrNull<String>('imageAsset'),
        sortOrder: order,
      );

  @Id()
  int id;
  @Unique(onConflict: ConflictStrategy.replace)
  String shopId;
  String name;
  String address;
  String? imageUrl;
  String? imageAsset;
  int sortOrder;

  Shop toDomain() => Shop(
    id: shopId,
    name: name,
    address: address,
    imageUrl: imageUrl,
    imageAsset: imageAsset,
  );
}

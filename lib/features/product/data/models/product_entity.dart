import 'package:objectbox/objectbox.dart';

import '../../../../core/data/json_reader.dart';
import '../../domain/entities/product.dart';

@Entity()
class ProductEntity {
  ProductEntity({
    required this.productId,
    required this.code,
    required this.name,
    required this.priceMmk,
    required this.description,
    this.isNew = false,
    this.discountPercent,
    this.imageUrl,
    this.imageAsset,
    this.id = 0,
  });

  factory ProductEntity.fromJson(Map<String, dynamic> json) => ProductEntity(
    productId: json.read<String>('id'),
    code: json.read<String>('code'),
    name: json.read<String>('name'),
    priceMmk: json.read<int>('priceMmk'),
    description: json.read<String>('description'),
    isNew: json.readOrNull<bool>('isNew') ?? false,
    discountPercent: json.readOrNull<int>('discountPercent'),
    imageUrl: json.readOrNull<String>('imageUrl'),
    imageAsset: json.readOrNull<String>('imageAsset'),
  );

  @Id()
  int id;

  /// Upsert key: a refresh replaces the row with the same product id.
  @Unique(onConflict: ConflictStrategy.replace)
  String productId;
  String code;
  String name;
  int priceMmk;
  String description;
  bool isNew;
  int? discountPercent;
  String? imageUrl;
  String? imageAsset;

  Product toDomain() => Product(
    id: productId,
    code: code,
    name: name,
    priceMmk: priceMmk,
    description: description,
    isNew: isNew,
    discountPercent: discountPercent,
    imageUrl: imageUrl,
    imageAsset: imageAsset,
  );
}

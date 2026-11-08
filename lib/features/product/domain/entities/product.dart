import 'package:equatable/equatable.dart';

/// A sellable item (donut, drink, box). Prices are whole kyat (MMK).
class Product extends Equatable {
  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.priceMmk,
    required this.description,
    this.isNew = false,
    this.discountPercent,
    this.imageUrl,
    this.imageAsset,
  });

  final String id;

  /// Shop code shown on detail, e.g. `JD022123`.
  final String code;
  final String name;
  final int priceMmk;
  final String description;
  final bool isNew;

  /// `null` when there is no discount badge.
  final int? discountPercent;

  /// Remote image (cached on disk after first load).
  final String? imageUrl;

  /// Bundled seed image: shown offline before the remote one was ever cached.
  final String? imageAsset;

  /// Live total for the Add to cart button.
  int totalFor(int quantity) => priceMmk * quantity;

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    priceMmk,
    description,
    isNew,
    discountPercent,
    imageUrl,
    imageAsset,
  ];
}

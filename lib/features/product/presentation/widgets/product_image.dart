import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/donut_art.dart';
import '../../domain/entities/product.dart';

/// Product photo with an offline chain: disk cache → bundled asset → a
/// painted donut picked deterministically from the product id.
class ProductImage extends StatelessWidget {
  const ProductImage({
    required this.product,
    this.fit = BoxFit.cover,
    super.key,
  });

  final Product product;
  final BoxFit fit;

  static const _artRatio = 0.8;

  static const _styles = [
    DonutStyle.strawberry,
    DonutStyle.chocolate,
    DonutStyle.grape,
    DonutStyle.vanilla,
  ];

  @override
  Widget build(BuildContext context) => AppNetworkImage(
    url: product.imageUrl,
    asset: product.imageAsset,
    fit: fit,
    fallback: LayoutBuilder(
      builder: (_, constraints) => Center(
        child: DonutArt(
          size: constraints.biggest.shortestSide * _artRatio,
          style: _styles[product.id.hashCode.abs() % _styles.length],
          seed: product.id.hashCode,
        ),
      ),
    ),
  );
}

/// Hero tag for a product image; [scope] keeps tags unique when the same
/// product appears in two sections on one screen.
String productHeroTag(String productId, String scope) =>
    'product-$scope-$productId';

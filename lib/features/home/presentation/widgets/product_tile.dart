import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/widgets/product_image.dart';

/// Visual variants from the design.
enum ProductTileStyle {
  /// Seasonal specials: wide photo card.
  wide(width: 160, imageHeight: 110, onCard: false),

  /// Popular: tall white card with the item standing in it.
  tall(width: 110, imageHeight: 160, onCard: true),

  /// Order again: square white card.
  square(width: 110, imageHeight: 110, onCard: true);

  const ProductTileStyle({
    required this.width,
    required this.imageHeight,
    required this.onCard,
  });

  final double width;
  final double imageHeight;

  /// Image sits on a white card (contain) instead of filling it (cover).
  final bool onCard;

  static const _nameLines = 2;
  static const _nameLineHeight = 22.0;

  /// Image + gap + two lines of name, grown with the user's text scale so
  /// 1.3× text never overflows.
  double heightFor(TextScaler scaler) =>
      imageHeight + AppSpacing.xs + scaler.scale(_nameLineHeight) * _nameLines;
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    required this.product,
    required this.style,
    required this.heroTag,
    required this.onTap,
    super.key,
  });

  final Product product;
  final ProductTileStyle style;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: product.name,
      child: PressableScale(
        onTap: onTap,
        child: SizedBox(
          width: style.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageCard(context),
              const SizedBox(height: AppSpacing.xs),
              // Flexible: font metrics differ per platform; never overflow.
              Flexible(
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageCard(BuildContext context) => SizedBox(
    height: style.imageHeight,
    width: style.width,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: context.colors.surface),
          Padding(
            padding: EdgeInsets.all(style.onCard ? AppSpacing.sm : 0),
            child: Hero(
              tag: heroTag,
              child: ProductImage(
                product: product,
                fit: style.onCard ? BoxFit.contain : BoxFit.cover,
              ),
            ),
          ),
          if (product.discountPercent != null)
            Positioned(
              right: AppSpacing.xs,
              bottom: AppSpacing.xs,
              child: DiscountBadge(percent: product.discountPercent!),
            ),
        ],
      ),
    ),
  );
}

/// Orange "50% off" pill, value from data.
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({required this.percent, super.key});
  final int percent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xs,
      vertical: AppSpacing.xxs / 2,
    ),
    decoration: BoxDecoration(
      color: context.colors.highlight,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Text(
      AppLocalizations.of(context).percentOff(percent),
      style: context.text.labelSmall?.copyWith(color: context.colors.onPrimary),
    ),
  );
}

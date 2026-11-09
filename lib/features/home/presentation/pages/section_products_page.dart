import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/formatters.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/widgets/product_image.dart';
import '../../domain/entities/home_section.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../widgets/product_section.dart';
import '../widgets/product_tile.dart';
import '../widgets/watched_list_view.dart';

/// "See more" for a Home section: every product in it as a vertical list.
/// Reads the same local stream as Home, so it updates after a sync.
class SectionProductsPage extends StatelessWidget {
  const SectionProductsPage({
    required this.section,
    required this.catalog,
    super.key,
  });

  final HomeSection section;
  final CatalogRepository catalog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.colors.surfaceMuted,
      appBar: AppBar(
        title: Text(ProductSection.titleFor(section, l10n)),
        backgroundColor: context.colors.surfaceMuted,
      ),
      body: WatchedListView<Product>(
        watch: () => catalog.watchSection(section),
        skeleton: const Skeleton(height: _ProductRow.height),
        itemBuilder: (context, product) => _ProductRow(
          product: product,
          heroTag: productHeroTag(product.id, 'list-${section.key}'),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.heroTag});

  final Product product;
  final String heroTag;

  static const height = 96.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: product.name,
      child: PressableScale(
        onTap: () =>
            context.push(AppRoutes.product(product.id), extra: heroTag),
        child: Container(
          constraints: const BoxConstraints(minHeight: height),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: height - AppSpacing.sm * 2,
                child: Hero(
                  tag: heroTag,
                  child: ProductImage(product: product, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _NameAndPrice(product: product)),
              _Tag(product: product),
              const SizedBox(width: AppSpacing.xxs),
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameAndPrice extends StatelessWidget {
  const _NameAndPrice({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          AppLocalizations.of(context)
              .priceMmk(formatThousands(product.priceMmk)),
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Discount badge if any, otherwise "New" if new, otherwise nothing.
class _Tag extends StatelessWidget {
  const _Tag({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final percent = product.discountPercent;
    if (percent != null) return DiscountBadge(percent: percent);
    if (!product.isNew) return const SizedBox.shrink();
    return Text(
      AppLocalizations.of(context).newBadge,
      style: context.text.labelMedium?.copyWith(color: context.colors.accent),
    );
  }
}

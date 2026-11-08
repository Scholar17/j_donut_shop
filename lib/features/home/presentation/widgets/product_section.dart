import 'package:flutter/material.dart';

import '../../../../core/result/load_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/widgets/product_image.dart';
import '../../domain/entities/home_section.dart';
import 'product_tile.dart';
import 'section_message.dart';

/// Title row plus a horizontal product list with its own load states.
class ProductSection extends StatelessWidget {
  const ProductSection({
    required this.section,
    required this.state,
    required this.onProductTap,
    required this.onRetry,
    super.key,
  });

  final HomeSection section;
  final LoadState<List<Product>> state;
  final void Function(Product product, String heroTag) onProductTap;
  final VoidCallback onRetry;

  static const _skeletonCount = 3;

  double _height(BuildContext context) =>
      _style.heightFor(MediaQuery.textScalerOf(context));

  ProductTileStyle get _style => switch (section) {
    HomeSection.seasonalSpecials => ProductTileStyle.wide,
    HomeSection.popular => ProductTileStyle.tall,
    HomeSection.orderAgain => ProductTileStyle.square,
  };

  String _title(AppLocalizations l10n) => switch (section) {
    HomeSection.seasonalSpecials => l10n.seasonalSpecials,
    HomeSection.popular => '${l10n.popular} 🔥',
    HomeSection.orderAgain => l10n.orderAgain,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TitleRow(title: _title(AppLocalizations.of(context))),
        const SizedBox(height: AppSpacing.sm),
        switch (state) {
          Loading() => _list(
            context,
            _skeletonCount,
            (_) => Skeleton(width: _style.width, height: _style.imageHeight),
          ),
          Failed() => SectionMessage.error(
            onRetry: onRetry,
            height: _height(context),
          ),
          Loaded(:final value) when value.isEmpty => SectionMessage.empty(
            height: _height(context),
          ),
          Loaded(:final value) => _list(
            context,
            value.length,
            (i) => _tile(value[i]),
          ),
        },
      ],
    );
  }

  Widget _tile(Product product) {
    final tag = productHeroTag(product.id, section.key);
    return ProductTile(
      product: product,
      style: _style,
      heroTag: tag,
      onTap: () => onProductTap(product, tag),
    );
  }

  Widget _list(
    BuildContext context,
    int count,
    Widget Function(int) itemBuilder,
  ) => SizedBox(
    height: _height(context),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
      itemBuilder: (_, i) => itemBuilder(i),
    ),
  );
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
    child: Row(
      children: [
        Expanded(child: Text(title, style: context.text.titleLarge)),
        PressableScale(
          onTap: () {},
          child: CircleAvatar(
            radius: AppSpacing.sm,
            backgroundColor: context.colors.surface,
            child: Icon(
              Icons.chevron_right_rounded,
              size: AppSpacing.md,
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

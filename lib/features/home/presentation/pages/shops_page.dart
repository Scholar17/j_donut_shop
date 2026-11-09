import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../widgets/watched_list_view.dart';

/// "Explore now" on Home: every shop as a vertical list of detail cards.
/// Reads the same local stream as Home, so it updates after a sync.
class ShopsPage extends StatelessWidget {
  const ShopsPage({required this.catalog, super.key});

  final CatalogRepository catalog;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surfaceMuted,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).shopsTitle),
        backgroundColor: colors.surfaceMuted,
      ),
      body: WatchedListView<Shop>(
        watch: catalog.watchShops,
        skeleton: const Skeleton(height: _ShopDetailCard.imageHeight * 1.6),
        itemBuilder: (context, shop) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: _ShopDetailCard(shop: shop),
        ),
      ),
    );
  }
}

class _ShopDetailCard extends StatelessWidget {
  const _ShopDetailCard({required this.shop});

  final Shop shop;

  static const imageHeight = 150.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('shops.${shop.id}'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: imageHeight,
            child: AppNetworkImage(url: shop.imageUrl, asset: shop.imageAsset),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shop.name, style: context.text.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                _AddressLine(address: shop.address),
                const SizedBox(height: AppSpacing.sm),
                const Align(
                  alignment: Alignment.centerRight,
                  child: _OrderOnlineButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pin icon and the shop address.
class _AddressLine extends StatelessWidget {
  const _AddressLine({required this.address});

  final String address;

  static const _iconSize = AppSpacing.md + AppSpacing.xxs;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on_outlined, size: _iconSize, color: colors.accent),
        const SizedBox(width: AppSpacing.xxs),
        Expanded(
          child: Text(
            address,
            style: context.text.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Ordering is not built yet: press feedback and a coming-soon snackbar.
class _OrderOnlineButton extends StatelessWidget {
  const _OrderOnlineButton();

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).orderOnline;
    final colors = context.colors;
    return PressableScale(
      onTap: () => showComingSoon(context, label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label.toUpperCase(),
          style: context.text.labelMedium?.copyWith(color: colors.onPrimary),
        ),
      ),
    );
  }
}

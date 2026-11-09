import 'package:flutter/material.dart';

import '../../../../core/result/load_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/shop.dart';
import 'section_message.dart';

/// "There are 4 T'Donuts shops near you." "Explore now" opens the shop list;
/// the cards' "Order online" still only gives press feedback.
class NearbyShops extends StatelessWidget {
  const NearbyShops({
    required this.shops,
    required this.onRetry,
    this.onExplore,
    this.bottomInset = 0,
    super.key,
  });

  final LoadState<List<Shop>> shops;
  final VoidCallback onRetry;
  final VoidCallback? onExplore;

  /// Space under the cards for the nav bar; the background fills it too.
  final double bottomInset;

  static const _cardWidth = 200.0;
  static const _imageHeight = 110.0;
  static const _textBlock = 84.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final count = shops is Loaded<List<Shop>>
        ? (shops as Loaded<List<Shop>>).value.length
        : 0;
    return Container(
      color: colors.surfaceMuted,
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.lg + bottomInset,
      ),
      child: _content(context, l10n, count),
    );
  }

  Widget _content(BuildContext context, AppLocalizations l10n, int count) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageGutter,
          ),
          child: Text(
            '${l10n.nearbyShops(count)} 😋',
            style: context.text.titleLarge?.copyWith(color: colors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageGutter,
          ),
          child: _Pill(label: l10n.exploreNow, onTap: onExplore),
        ),
        const SizedBox(height: AppSpacing.md),
        _cards(context),
      ],
    );
  }

  Widget _cards(BuildContext context) {
    final height =
        _imageHeight + MediaQuery.textScalerOf(context).scale(_textBlock);
    return switch (shops) {
      Loading() => _row(height, 2, (_) => const Skeleton(width: _cardWidth)),
      Failed() => SectionMessage.error(onRetry: onRetry, height: height),
      Loaded(:final value) when value.isEmpty => SectionMessage.empty(
        height: height,
      ),
      Loaded(:final value) => _row(
        height,
        value.length,
        (i) => _ShopCard(shop: value[i]),
      ),
    };
  }

  Widget _row(double height, int count, Widget Function(int) builder) =>
      SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageGutter,
          ),
          itemCount: count,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) => SizedBox(width: _cardWidth, child: builder(i)),
        ),
      );
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop});
  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: NearbyShops._imageHeight - AppSpacing.xs,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: AppNetworkImage(
                url: shop.imageUrl,
                asset: shop.imageAsset,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            shop.name,
            style: context.text.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            shop.address,
            style: context.text.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          PressableScale(
            onTap: () {},
            child: Text(
              AppLocalizations.of(context).orderOnline,
              style: context.text.labelMedium?.copyWith(color: colors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => PressableScale(
    key: const Key('home.exploreShops'),
    onTap: onTap ?? () {},
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label.toUpperCase(),
        style: context.text.labelMedium?.copyWith(
          color: context.colors.primary,
        ),
      ),
    ),
  );
}

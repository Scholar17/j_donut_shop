import 'package:flutter/material.dart';

import '../../../../core/l10n/formatters.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_detail_cubit.dart';
import 'product_image.dart';
import 'quantity_stepper.dart';

/// White card on Product detail: code, name, price, the New badge and the
/// Hero image, with the quantity stepper overlapping its bottom edge.
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.heroTag,
    required this.state,
    required this.cubit,
    super.key,
  });

  final Product product;
  final String heroTag;
  final ProductDetailState state;
  final ProductDetailCubit cubit;

  static const imageHeight = 240.0;
  static const _stepperOverlap = 26.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: _stepperOverlap),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Titles(product: product)),
                  if (product.isNew) _NewBadge(label: l10n.newBadge),
                ],
              ),
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Hero(
                  tag: heroTag,
                  child: ProductImage(product: product, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
        QuantityStepper(
          quantity: state.quantity,
          canDecrement: state.quantity > ProductDetailState.minQuantity,
          onIncrement: cubit.increment,
          onDecrement: cubit.decrement,
        ),
      ],
    );
  }
}

class _Titles extends StatelessWidget {
  const _Titles({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.code,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.textHint,
          ),
        ),
        Text(product.name, style: context.text.headlineSmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          l10n.priceMmk(formatThousands(product.priceMmk)),
          style: context.text.titleSmall,
        ),
      ],
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xxs,
    ),
    decoration: BoxDecoration(
      color: context.colors.highlight,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: Text(
      label,
      style: context.text.labelMedium?.copyWith(
        color: context.colors.onPrimary,
      ),
    ),
  );
}

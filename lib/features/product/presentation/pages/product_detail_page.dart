import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/result/failure.dart';
import '../../../../core/result/load_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_detail_cubit.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/product_card.dart';

/// Screen 9. Coconut Donut is the reference design.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({required this.heroTag, super.key});

  /// Matches the tapped tile's Hero so the image flies into place.
  final String heroTag;

  void _onAdded(BuildContext context, ProductDetailState state) {
    final product = (state.product as Loaded<Product>).value;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .addedToCart(state.quantity, product.name),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductDetailCubit, ProductDetailState>(
      listenWhen: (prev, next) => next.addedCount > prev.addedCount,
      listener: _onAdded,
      child: Scaffold(
        backgroundColor: context.colors.surfaceMuted,
        body: SafeArea(
          child: Stack(
            children: [
              BlocBuilder<ProductDetailCubit, ProductDetailState>(
                builder: (context, state) => switch (state.product) {
                  Loading() => const _DetailSkeleton(),
                  Failed(:final failure) => _DetailError(failure: failure),
                  Loaded(:final value) => _DetailBody(
                    product: value,
                    state: state,
                    heroTag: heroTag,
                  ),
                },
              ),
              const Align(
                alignment: Alignment.topCenter,
                child: OfflineBanner(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.product,
    required this.state,
    required this.heroTag,
  });

  final Product product;
  final ProductDetailState state;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductDetailCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BackButton(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductCard(
                    product: product,
                    heroTag: heroTag,
                    state: state,
                    cubit: cubit,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Description(text: product.description),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: AddToCartButton(
              total: state.total,
              addedCount: state.addedCount,
              onPressed: cubit.addToCart,
            ),
          ),
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: AppSpacing.sm - 2,
                backgroundColor: colors.success,
                child: Icon(
                  Icons.question_mark_rounded,
                  size: AppSpacing.sm,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                AppLocalizations.of(context).whatsThis.replaceFirst(' ', '\n'),
                style: context.text.titleSmall,
              ),
            ],
          ),
          VerticalDivider(width: AppSpacing.lg, color: colors.border),
          Expanded(
            child: Text(
              text,
              style: context.text.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Semantics(
      button: true,
      label: AppLocalizations.of(context).back,
      child: PressableScale(
        key: const Key('product.back'),
        onTap: () => Navigator.of(context).maybePop(),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Icon(Icons.arrow_back_rounded),
        ),
      ),
    ),
  );
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.pageGutter),
    child: Column(
      children: [
        SizedBox(height: AppSpacing.xxl),
        Skeleton(
          height: ProductCard.imageHeight + AppSpacing.xxl * 2,
          radius: AppRadius.lg,
        ),
        SizedBox(height: AppSpacing.lg),
        Skeleton(height: AppSpacing.xxl * 2),
      ],
    ),
  );
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.failure});
  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = failure is NotFoundFailure
        ? l10n.productNotFound
        : failure.message(l10n);
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
          child: _BackButton(),
        ),
        Expanded(
          child: Center(child: Text(message, style: context.text.titleMedium)),
        ),
      ],
    );
  }
}

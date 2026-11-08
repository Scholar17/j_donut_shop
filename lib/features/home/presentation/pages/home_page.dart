import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/connectivity/connectivity_cubit.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/art_palette.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../product/domain/entities/product.dart';
import '../../domain/entities/home_section.dart';
import '../bloc/home_bloc.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/home_header.dart';
import '../widgets/nearby_shops.dart';
import '../widgets/product_section.dart';

/// Screen 8. Renders only local data; refreshes in the background when the
/// network returns and on pull-to-refresh.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openProduct(BuildContext context, Product product, String heroTag) =>
      context.push(AppRoutes.product(product.id), extra: heroTag);

  void _refresh(BuildContext context, {bool force = false}) =>
      context.read<HomeBloc>().add(HomeRefreshRequested(force: force));

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Back online → refresh in the background.
        BlocListener<ConnectivityCubit, bool>(
          listenWhen: (was, now) => !was && now,
          listener: (context, _) => _refresh(context),
        ),
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (prev, next) =>
              next.refreshFailure != null &&
              prev.refreshFailure != next.refreshFailure,
          listener: _showRefreshFailure,
        ),
      ],
      child: Scaffold(
        backgroundColor: context.colors.surfaceMuted,
        body: Stack(
          children: [
            RefreshIndicator(
              color: context.colors.accent,
              onRefresh: () async {
                _refresh(context, force: true);
                await context.read<HomeBloc>().stream.firstWhere(
                  (s) => !s.isRefreshing,
                );
              },
              child: _HomeContent(
                onProductTap: (p, tag) => _openProduct(context, p, tag),
              ),
            ),
            const SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: OfflineBanner(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRefreshFailure(BuildContext context, HomeState state) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.refreshFailure!.message(l10n))),
    );
    context.read<HomeBloc>().add(const HomeRefreshFailureShown());
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.onProductTap});

  final void Function(Product, String) onProductTap;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    void retry() => bloc.add(const HomeRefreshRequested(force: true));
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final blocks = <Widget>[
          for (final section in HomeSection.values)
            ProductSection(
              section: section,
              state: state.section(section),
              onProductTap: onProductTap,
              onRetry: retry,
            ),
          NearbyShops(shops: state.shops, onRetry: retry),
        ];
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          // Bottom inset includes the nav bar (Scaffold.extendBody).
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            _TopBlock(state: state, onRetry: retry),
            for (var i = 0; i < blocks.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  top: i == blocks.length - 1 ? AppSpacing.xl : AppSpacing.lg,
                ),
                child: StaggeredEntrance(index: i + 1, child: blocks[i]),
              ),
          ],
        );
      },
    );
  }
}

/// Peach header with member info and the banner carousel overlapping it.
class _TopBlock extends StatelessWidget {
  const _TopBlock({required this.state, required this.onRetry});

  final HomeState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ArtPalette.circlePeach,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
            ),
            child: StaggeredEntrance(
              index: 0,
              child: HomeHeader(
                member: state.member,
                progress: state.tierProgress,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BannerCarousel(banners: state.banners, onRetry: onRetry),
        ],
      ),
    );
  }
}

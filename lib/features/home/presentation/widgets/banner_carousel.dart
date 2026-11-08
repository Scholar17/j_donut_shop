import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/result/load_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../domain/entities/promo_banner.dart';
import 'section_message.dart';

/// Auto-playing banner carousel. Pauses while the user drags, and does not
/// auto-advance at all with Reduce Motion on.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    required this.banners,
    required this.onRetry,
    super.key,
  });

  final LoadState<List<PromoBanner>> banners;
  final VoidCallback onRetry;

  static const height = 170.0;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _controller = PageController(viewportFraction: 0.86);
  Timer? _timer;
  int _page = 0;

  int get _count => switch (widget.banners) {
    Loaded(:final value) => value.length,
    _ => 0,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (context.reduceMotion) return;
    _timer = Timer.periodic(AppDurations.bannerAutoPlay, (_) => _advance());
  }

  void _advance() {
    if (_count < 2 || !_controller.hasClients) return;
    _controller.animateToPage(
      (_page + 1) % _count,
      duration: AppDurations.bannerSlide,
      curve: AppCurves.emphasized,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.banners) {
      Loading() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
        child: Skeleton(height: BannerCarousel.height, radius: AppRadius.lg),
      ),
      Failed() => SectionMessage.error(
        onRetry: widget.onRetry,
        height: BannerCarousel.height,
      ),
      Loaded(:final value) when value.isEmpty => const SectionMessage.empty(
        height: BannerCarousel.height,
      ),
      Loaded(:final value) => _carousel(value),
    };
  }

  Widget _carousel(List<PromoBanner> banners) => Column(
    children: [
      SizedBox(
        height: BannerCarousel.height,
        child: NotificationListener<ScrollStartNotification>(
          onNotification: (n) {
            if (n.dragDetails != null) _restartTimer();
            return false;
          },
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (_, i) => _BannerCard(banner: banners[i]),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      _Dots(count: banners.length, active: _page),
    ],
  );
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});
  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              url: banner.imageUrl,
              asset: banner.imageAsset,
              fallback: ColoredBox(color: colors.tierPlatinum),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.textPrimary.withValues(alpha: 0.55),
                    colors.textPrimary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (banner.badge != null) _Badge(text: banner.badge!),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    banner.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleLarge?.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
    decoration: BoxDecoration(
      color: context.colors.highlight,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Text(
      text,
      style: context.text.labelSmall?.copyWith(color: context.colors.onPrimary),
    ),
  );
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});
  final int count;
  final int active;

  static const _dot = 6.0;
  static const _activeDot = 18.0;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < count; i++)
        AnimatedContainer(
          duration: context.motion(AppDurations.medium),
          curve: AppCurves.standard,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: i == active ? _activeDot : _dot,
          height: _dot,
          decoration: BoxDecoration(
            color: i == active ? context.colors.accent : context.colors.border,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
    ],
  );
}

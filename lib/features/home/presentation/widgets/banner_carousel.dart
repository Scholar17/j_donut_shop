import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion.dart';
import '../../../../core/result/load_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/art_palette.dart';
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
  /// Endless loop: an unbounded page list (`itemCount: null`) mapped onto the
  /// real banners with `%`, starting far from page 0 so swiping back also
  /// keeps going. (A huge finite count trips a floating-point layout assert.)
  static const _startPage = 5000;

  /// Leaves ~11% of the screen each side for the neighbouring banners to peek.
  static const _viewportFraction = 0.78;

  /// Side banners shrink by this much (centre page enlarged).
  static const _enlargeFactor = 0.1;

  late final PageController _controller = PageController(
    viewportFraction: _viewportFraction,
    initialPage: _startPage,
  );
  Timer? _timer;

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
    if (!_controller.hasClients) return;
    _controller.nextPage(
      duration: AppDurations.bannerSlide,
      curve: AppCurves.bannerSlide,
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
      Loaded(:final value) when value.length == 1 => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
        child: SizedBox(
          height: BannerCarousel.height,
          child: _BannerCard(banner: value.first),
        ),
      ),
      Loaded(:final value) => _carousel(value),
    };
  }

  Widget _carousel(List<PromoBanner> banners) => SizedBox(
    height: BannerCarousel.height,
    child: NotificationListener<ScrollStartNotification>(
      // A user swipe restarts the auto-play countdown.
      onNotification: (n) {
        if (n.dragDetails != null) _restartTimer();
        return false;
      },
      child: PageView.builder(
        controller: _controller,
        itemBuilder: (_, i) =>
            _enlarged(i, _BannerCard(banner: banners[i % banners.length])),
      ),
    ),
  );

  /// Scales each page by its distance from the centre, like an enlarged
  /// centre-page carousel. Side pages shrink towards the centre page, so
  /// their inner edge stays in view as a peek.
  Widget _enlarged(int index, Widget child) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final page = _controller.hasClients && _controller.position.haveDimensions
          ? _controller.page ?? _controller.initialPage.toDouble()
          : _controller.initialPage.toDouble();
      final offset = (index - page).clamp(-1.0, 1.0);
      return Transform.scale(
        scale: 1 - _enlargeFactor * offset.abs(),
        // Left neighbour anchors on its right edge, right one on its left.
        alignment: Alignment(-offset, 0),
        child: child,
      );
    },
    child: child,
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
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ArtPalette.photoScrim, ArtPalette.photoScrimClear],
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
                      color: ArtPalette.onPhoto,
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

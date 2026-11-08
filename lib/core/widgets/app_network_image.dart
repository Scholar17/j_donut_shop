import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../motion/app_motion.dart';
import '../network/api_config.dart';
import '../theme/app_theme.dart';
import 'skeleton.dart';

/// Offline-first image.
///
/// 1. A remote [url] is loaded through `cached_network_image` (disk cache), so
///    once seen it renders in airplane mode too.
/// 2. While loading, or if the URL fails / was never cached, the bundled seed
///    [asset] is shown, so a first launch without network still has images.
/// 3. With neither, [fallback] (or a branded icon) is the error state.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    this.file,
    this.url,
    this.asset,
    this.fallback,
    this.fit = BoxFit.cover,
    super.key,
  });

  /// Local file (e.g. a photo the user picked); shown first when set.
  final String? file;

  /// Absolute, or server-relative like `/images/products/x.png`.
  final String? url;
  final String? asset;
  final Widget? fallback;
  final BoxFit fit;

  static String resolve(String url) => url.startsWith('/')
      ? '${ApiConfig.baseUrl}${ApiConfig.apiVersion}$url'
      : url;

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Image.file(
        File(file!),
        fit: fit,
        errorBuilder: (_, _, _) => _offline(context),
      );
    }
    final offline = _offline(context);
    if (url == null) return offline;
    return CachedNetworkImage(
      imageUrl: resolve(url!),
      fit: fit,
      fadeInDuration: context.motion(AppDurations.medium),
      placeholder: (_, _) =>
          asset != null ? offline : const Skeleton(radius: 0),
      errorWidget: (_, _, _) => offline,
    );
  }

  Widget _offline(BuildContext context) {
    if (asset != null) {
      return Image.asset(
        asset!,
        fit: fit,
        errorBuilder: (_, _, _) => _error(context),
      );
    }
    return _error(context);
  }

  Widget _error(BuildContext context) =>
      fallback ??
      ColoredBox(
        color: context.colors.surfaceMuted,
        child: Center(
          child: Icon(
            Icons.bakery_dining_rounded,
            color: context.colors.textHint,
          ),
        ),
      );
}

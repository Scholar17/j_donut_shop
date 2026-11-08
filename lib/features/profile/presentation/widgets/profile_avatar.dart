import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/pressable_scale.dart';

/// Round profile photo (or initial) with an optional camera badge.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.name,
    required this.photoPath,
    required this.size,
    this.onTap,
    super.key,
  });

  final String name;
  final String? photoPath;
  final double size;

  /// Shows the camera badge when set.
  final VoidCallback? onTap;

  static const _ringRatio = 0.04;
  static const _badgeRatio = 0.3;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().characters.first.toUpperCase();
    final avatar = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * _ringRatio),
      decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
      child: ClipOval(
        child: AppNetworkImage(
          key: ValueKey(photoPath),
          file: photoPath,
          fallback: ColoredBox(
            color: colors.surface,
            child: Center(
              child: Text(
                initial,
                style: context.text.headlineMedium?.copyWith(
                  fontSize: size * 0.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (onTap == null) return avatar;
    return PressableScale(
      key: const Key('profile.avatar'),
      onTap: onTap,
      child: Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * _badgeRatio,
              height: size * _badgeRatio,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.surface,
                  width: AppSpacing.xxs / 2,
                ),
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                size: size * _badgeRatio * 0.55,
                color: colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

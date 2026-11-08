import 'package:flutter/material.dart';

import '../../../../core/l10n/formatters.dart';
import '../../../../core/result/load_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../member/domain/entities/member.dart';
import '../../../member/domain/entities/tier.dart';
import '../../../member/presentation/tier_labels.dart';

/// Member photo, name, tier, points to the next tier and the bell.
class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.member, required this.progress, super.key});

  final LoadState<Member?> member;
  final TierProgress? progress;

  static const _avatarSize = 52.0;

  @override
  Widget build(BuildContext context) {
    final current = member;
    if (current is! Loaded<Member?> ||
        current.value == null ||
        progress == null) {
      return const _HeaderSkeleton();
    }
    final value = current.value!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Avatar(member: value, size: _avatarSize),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _NameAndTier(name: value.name, progress: progress!),
            ),
            _Bell(count: value.notificationCount),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _PointsPill(progress: progress!),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.member, required this.size});
  final Member member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = member.name.isEmpty
        ? '?'
        : member.name.characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(AppSpacing.xxs / 2),
      decoration: BoxDecoration(
        color: context.colors.accent,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: AppNetworkImage(
          url: member.photoUrl,
          asset: member.photoAsset,
          fallback: ColoredBox(
            color: context.colors.surface,
            child: Center(child: Text(initial, style: context.text.titleLarge)),
          ),
        ),
      ),
    );
  }
}

class _NameAndTier extends StatelessWidget {
  const _NameAndTier({required this.name, required this.progress});
  final String name;
  final TierProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: context.text.headlineSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          l10n.memberTier(progress.current.level.label(l10n)),
          style: context.text.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PointsPill extends StatelessWidget {
  const _PointsPill({required this.progress});
  final TierProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final next = progress.next;
    final text = next == null
        ? l10n.topTierReached
        : l10n.pointsToNextTier(
            formatThousands(progress.pointsToNext),
            next.level.label(l10n),
          );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(text, style: context.text.labelSmall),
    );
  }
}

class _Bell extends StatelessWidget {
  const _Bell({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: AppLocalizations.of(context).notificationsLabel(count),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.highlight,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: colors.onPrimary,
              size: AppSpacing.lg - 2,
            ),
            if (count > 0) ...[
              const SizedBox(width: AppSpacing.xxs),
              CircleAvatar(
                radius: AppSpacing.sm - 3,
                backgroundColor: colors.surface,
                child: Text('$count', style: context.text.labelSmall),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  static const _nameWidth = 120.0;
  static const _nameHeight = 20.0;
  static const _tierWidth = 180.0;
  static const _tierHeight = 14.0;

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Skeleton(
        width: HomeHeader._avatarSize,
        height: HomeHeader._avatarSize,
        radius: AppRadius.pill,
      ),
      SizedBox(width: AppSpacing.sm),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: _nameWidth, height: _nameHeight),
          SizedBox(height: AppSpacing.xs),
          Skeleton(width: _tierWidth, height: _tierHeight),
        ],
      ),
    ],
  );
}

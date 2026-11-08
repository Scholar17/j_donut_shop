import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/session_cubit.dart';
import 'profile_avatar.dart';

/// Settings header: photo, name and phone of the signed-in user.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  static const _avatarSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    if (session is! SessionAuthenticated) return const SizedBox.shrink();
    final user = session.user;
    final colors = context.colors;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).editProfile,
      child: PressableScale(
        key: const Key('settings.profile'),
        onTap: () => context.push(AppRoutes.profile),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              ProfileAvatar(
                name: user.firstName,
                photoPath: user.photoPath,
                size: _avatarSize,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: context.text.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.phone,
                      style: context.text.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_rounded, color: colors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

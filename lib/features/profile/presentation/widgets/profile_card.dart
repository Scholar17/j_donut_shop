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

/// Settings header row: photo, name, phone and an "EDIT" link to the
/// profile editor. Sits on the tinted header band of the Settings page.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  static const _avatarSize = 64.0;
  static const _editLetterSpacing = 1.5;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    if (session is! SessionAuthenticated) return const SizedBox.shrink();
    final user = session.user;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.editProfile,
      child: PressableScale(
        key: const Key('settings.profile'),
        onTap: () => context.push(AppRoutes.profile),
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
                    style: context.text.headlineSmall,
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
            ExcludeSemantics(
              child: Text(
                l10n.edit,
                style: context.text.labelLarge?.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: _editLetterSpacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/session_cubit.dart';

/// Log out row (round icon) with a confirmation dialog. The router guard
/// sends the user to Onboarding once the session is cleared.
class LogOutRow extends StatelessWidget {
  const LogOutRow({super.key});

  static const _iconCircle = 44.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      key: const Key('settings.logOut'),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageGutter - AppSpacing.xs,
      ),
      leading: Container(
        width: _iconCircle,
        height: _iconCircle,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.logout_rounded, color: colors.onPrimary),
      ),
      title: Text(
        AppLocalizations.of(context).logOut,
        style: context.text.titleSmall,
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
      onTap: () => _confirm(context),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.logOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<SessionCubit>().logOut();
    }
  }
}

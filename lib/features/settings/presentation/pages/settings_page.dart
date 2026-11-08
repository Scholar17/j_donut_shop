import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/session_cubit.dart';
import '../../domain/app_preferences.dart';
import '../cubit/preferences_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preferences = context.watch<PreferencesCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageGutter),
        children: [
          _SectionLabel(l10n.appearance),
          _ThemeSelector(selected: preferences.theme),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(l10n.language),
          _LanguageSelector(selected: preferences.language),
          const SizedBox(height: AppSpacing.xl),
          const _LogOutTile(),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Text(label, style: context.text.titleSmall),
  );
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.selected});
  final ThemePreference selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<ThemePreference>(
      segments: [
        ButtonSegment(
          value: ThemePreference.system,
          label: Text(l10n.themeSystem),
          icon: const Icon(Icons.brightness_auto_rounded),
        ),
        ButtonSegment(
          value: ThemePreference.light,
          label: Text(l10n.themeLight),
          icon: const Icon(Icons.light_mode_rounded),
        ),
        ButtonSegment(
          value: ThemePreference.dark,
          label: Text(l10n.themeDark),
          icon: const Icon(Icons.dark_mode_rounded),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (value) =>
          context.read<PreferencesCubit>().setTheme(value.single),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.selected});
  final AppLanguage selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<AppLanguage>(
      segments: [
        ButtonSegment(
          value: AppLanguage.english,
          label: Text(l10n.languageEnglish),
        ),
        ButtonSegment(
          value: AppLanguage.myanmar,
          label: Text(l10n.languageMyanmar),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (value) =>
          context.read<PreferencesCubit>().setLanguage(value.single),
    );
  }
}

class _LogOutTile extends StatelessWidget {
  const _LogOutTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      key: const Key('settings.logOut'),
      leading: Icon(Icons.logout_rounded, color: context.colors.danger),
      title: Text(l10n.logOut, style: TextStyle(color: context.colors.danger)),
      tileColor: context.colors.surfaceMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/app_preferences.dart';
import '../cubit/preferences_cubit.dart';
import '../widgets/log_out_row.dart';
import '../widgets/option_sheet.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_menu_row.dart';

/// Shown in the footer. Keep in sync with pubspec.
const _appVersion = '1.0.0';

/// Settings: tinted profile header, then a flat menu. Rows without an
/// action are not built yet and show a "Soon" chip (see [SettingsMenuRow]).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: ListView(
        // Bottom inset includes the nav bar (Scaffold.extendBody).
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
        ),
        children: [
          const SettingsHeader(),
          const SizedBox(height: AppSpacing.sm),
          ..._menu(context, l10n),
          const SizedBox(height: AppSpacing.xs),
          const LogOutRow(),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.appVersion(_appVersion),
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Menu rows in display order; a `null` action marks a coming-soon row.
  List<Widget> _menu(BuildContext context, AppLocalizations l10n) {
    final prefs = context.watch<PreferencesCubit>().state;
    final rows = <(String, IconData, String, String?, VoidCallback?)>[
      ('orders', Icons.receipt_long_outlined, l10n.myOrders, null, null),
      (
        'favorites',
        Icons.favorite_border_rounded,
        l10n.myFavorites,
        null,
        null,
      ),
      (
        'account',
        Icons.person_outline_rounded,
        l10n.account,
        null,
        () => context.push(AppRoutes.profile),
      ),
      (
        'promotions',
        Icons.confirmation_number_outlined,
        l10n.promotions,
        null,
        null,
      ),
      (
        'appearance',
        Icons.palette_outlined,
        l10n.appearance,
        _themeLabel(l10n, prefs.theme),
        () => _pickTheme(context, prefs.theme),
      ),
      (
        'language',
        Icons.translate_rounded,
        l10n.language,
        _languageLabel(l10n, prefs.language).toUpperCase(),
        () => _pickLanguage(context, prefs.language),
      ),
      ('about', Icons.info_outline_rounded, l10n.about, null, null),
      ('terms', Icons.article_outlined, l10n.termsAndConditions, null, null),
      ('privacy', Icons.fact_check_outlined, l10n.privacyPolicy, null, null),
    ];
    return [
      for (final (id, icon, label, value, onTap) in rows)
        SettingsMenuRow(
          key: Key('settings.$id'),
          icon: icon,
          label: label,
          value: value,
          onTap: onTap,
        ),
    ];
  }

  static String _themeLabel(AppLocalizations l10n, ThemePreference theme) =>
      switch (theme) {
        ThemePreference.system => l10n.themeSystem,
        ThemePreference.light => l10n.themeLight,
        ThemePreference.dark => l10n.themeDark,
      };

  static String _languageLabel(AppLocalizations l10n, AppLanguage language) =>
      switch (language) {
        AppLanguage.english => l10n.languageEnglish,
        AppLanguage.myanmar => l10n.languageMyanmar,
      };

  Future<void> _pickTheme(BuildContext context, ThemePreference current) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PreferencesCubit>();
    final picked = await showOptionSheet(
      context,
      title: l10n.appearance,
      current: current,
      options: {
        for (final theme in ThemePreference.values)
          theme: _themeLabel(l10n, theme),
      },
    );
    if (picked != null) await cubit.setTheme(picked);
  }

  Future<void> _pickLanguage(BuildContext context, AppLanguage current) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PreferencesCubit>();
    final picked = await showOptionSheet(
      context,
      title: l10n.language,
      current: current,
      options: {
        for (final language in AppLanguage.values)
          language: _languageLabel(l10n, language),
      },
    );
    if (picked != null) await cubit.setLanguage(picked);
  }
}

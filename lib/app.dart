import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/domain/app_preferences.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';
import 'l10n/generated/app_localizations.dart';

/// Root widget: wires theme, locale and router from app-wide blocs.
class JDonutsApp extends StatelessWidget {
  const JDonutsApp({
    required this.router,
    required this.preferencesCubit,
    super.key,
  });

  final GoRouter router;
  final PreferencesCubit preferencesCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: preferencesCubit,
      child: BlocBuilder<PreferencesCubit, AppPreferences>(
        builder: (context, preferences) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: preferences.themeMode,
          locale: preferences.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
  }
}

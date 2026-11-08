import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/app_preferences.dart';
import '../../domain/preferences_repository.dart';

/// App-wide theme and language. A Cubit because there are no events to
/// transform: each setter is a direct state change plus a save.
class PreferencesCubit extends Cubit<AppPreferences> {
  PreferencesCubit(this._repository) : super(_repository.load());

  final PreferencesRepository _repository;

  Future<void> setTheme(ThemePreference theme) =>
      _update(state.copyWith(theme: theme));

  Future<void> setLanguage(AppLanguage language) =>
      _update(state.copyWith(language: language));

  Future<void> _update(AppPreferences next) async {
    if (next == state) return;
    emit(next);
    await _repository.save(next);
  }
}

/// Maps domain preferences to Flutter types at the presentation boundary.
extension AppPreferencesX on AppPreferences {
  ThemeMode get themeMode => switch (theme) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
      };

  Locale get locale => Locale(language.code);
}

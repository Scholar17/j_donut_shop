/// User's appearance choice; [system] follows the OS setting.
enum ThemePreference { system, light, dark }

/// Languages the app ships with. English is the default.
enum AppLanguage {
  english('en'),
  myanmar('my');

  const AppLanguage(this.code);
  final String code;

  static AppLanguage fromCode(String? code) => AppLanguage.values.firstWhere(
    (language) => language.code == code,
    orElse: () => AppLanguage.english,
  );
}

/// Persisted UI preferences. Immutable; use [copyWith] to change.
class AppPreferences {
  const AppPreferences({
    this.theme = ThemePreference.system,
    this.language = AppLanguage.english,
  });

  final ThemePreference theme;
  final AppLanguage language;

  AppPreferences copyWith({ThemePreference? theme, AppLanguage? language}) =>
      AppPreferences(
        theme: theme ?? this.theme,
        language: language ?? this.language,
      );

  @override
  bool operator ==(Object other) =>
      other is AppPreferences &&
      other.theme == theme &&
      other.language == language;

  @override
  int get hashCode => Object.hash(theme, language);
}

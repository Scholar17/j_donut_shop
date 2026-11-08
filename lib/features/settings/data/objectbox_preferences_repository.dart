import '../../../objectbox.g.dart';
import '../domain/app_preferences.dart';
import '../domain/preferences_repository.dart';
import 'preferences_entity.dart';

class ObjectBoxPreferencesRepository implements PreferencesRepository {
  ObjectBoxPreferencesRepository(Store store)
      : _box = store.box<PreferencesEntity>();

  final Box<PreferencesEntity> _box;

  @override
  AppPreferences load() {
    final row = _box.getAll().firstOrNull;
    if (row == null) return const AppPreferences();
    return AppPreferences(
      theme: ThemePreference.values.asNameMap()[row.themeName] ??
          ThemePreference.system,
      language: AppLanguage.fromCode(row.languageCode),
    );
  }

  @override
  Future<void> save(AppPreferences preferences) async {
    final row = _box.getAll().firstOrNull ?? PreferencesEntity();
    row
      ..themeName = preferences.theme.name
      ..languageCode = preferences.language.code;
    await _box.putAsync(row);
  }
}

import 'app_preferences.dart';

/// Reads and writes [AppPreferences]. Synchronous read so the first frame
/// already has the right theme and locale (no flash of the wrong theme).
abstract interface class PreferencesRepository {
  AppPreferences load();
  Future<void> save(AppPreferences preferences);
}

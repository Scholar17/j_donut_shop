import 'package:objectbox/objectbox.dart';

/// ObjectBox row for [AppPreferences]; enums stored by name for stability.
@Entity()
class PreferencesEntity {
  PreferencesEntity({
    this.id = 0,
    this.themeName = 'system',
    this.languageCode = 'en',
  });

  @Id()
  int id;
  String themeName;
  String languageCode;
}

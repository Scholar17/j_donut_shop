import 'package:objectbox/objectbox.dart';

/// Single row recording which data migrations and seed have been applied.
///
/// ObjectBox migrates the *schema* automatically from `objectbox-model.json`
/// (stable UIDs make renames safe). This row versions the *data* on top, so
/// each step in [DatabaseMigrator] runs exactly once per install.
@Entity()
class DbMetaEntity {
  DbMetaEntity({
    this.id = 0,
    this.schemaVersion = 0,
    this.seedVersion = 0,
    this.lastSyncedAt,
  });

  @Id()
  int id;
  int schemaVersion;
  int seedVersion;

  /// Last successful catalogue refresh from the server.
  @Property(type: PropertyType.date)
  DateTime? lastSyncedAt;
}

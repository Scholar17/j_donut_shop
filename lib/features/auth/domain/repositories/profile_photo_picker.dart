/// Where a new profile photo comes from.
enum PhotoSource { camera, gallery }

/// Picks a photo and stores it in app storage. Returns the saved file path,
/// or `null` if the user cancelled.
abstract interface class ProfilePhotoPicker {
  Future<String?> pick(PhotoSource source);
}

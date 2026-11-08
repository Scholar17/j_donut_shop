import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/repositories/profile_photo_picker.dart';

/// `image_picker` implementation. The picker's temp file may be purged by
/// the OS, so the photo is copied into the app documents directory.
class ImageProfilePhotoPicker implements ProfilePhotoPicker {
  ImageProfilePhotoPicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _maxDimension = 800.0;
  static const _jpegQuality = 85;
  static const _folder = 'profile';

  @override
  Future<String?> pick(PhotoSource source) async {
    final picked = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _jpegQuality,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null) return null;
    final docs = await getApplicationDocumentsDirectory();
    final dir = await Directory(p.join(docs.path, _folder))
        .create(recursive: true);
    // Unique name so Image caches never show a stale photo.
    final target = p.join(
      dir.path,
      'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await File(picked.path).copy(target);
    return target;
  }
}

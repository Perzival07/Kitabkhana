import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, gallery }

/// Lets the user take or choose a photo. Returns the raw bytes, or null if
/// they cancelled. (On web, "camera" opens the browser's file/camera chooser.)
abstract interface class PhotoPicker {
  Future<Uint8List?> pick(PhotoSource source);
}

class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      // The cover store resizes to 360px; avoid loading 12 MP originals.
      maxWidth: 1600,
      imageQuality: 90,
    );
    return file?.readAsBytes();
  }
}

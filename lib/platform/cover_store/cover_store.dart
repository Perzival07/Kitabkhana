import 'dart:typed_data';

import 'package:flutter/painting.dart';

import '../../core/result.dart';

/// Keeps one processed cover image per book on the device.
///
/// The `reference` returned by the save methods is what `Book.coverLocalPath`
/// stores. It is opaque to callers and stable across app updates (it is not
/// an absolute path, because iOS can move the app container).
abstract interface class CoverStore {
  /// Downloads [url], processes it (max 360px wide JPEG) and stores it for
  /// [bookId]. `Ok(null)` means the server had no real cover (a placeholder
  /// or an unreadable image), so the caller should keep the generated cover.
  Future<Result<String?>> saveFromUrl(String bookId, String url);

  /// Processes and stores a photo the user took or chose.
  Future<Result<String>> saveFromBytes(String bookId, Uint8List bytes);

  /// The stored JPEG for [reference], or null if missing (used by backup).
  Future<Uint8List?> readBytes(String reference);

  /// A displayable image for [reference], or null if it is missing.
  Future<ImageProvider?> imageFor(String reference);

  /// Removes the stored cover for [bookId]; a no-op if there is none.
  Future<void> delete(String bookId);
}

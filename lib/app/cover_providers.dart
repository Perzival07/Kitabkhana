import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/image/cover_processor.dart';
import '../data/db/database_provider.dart';
import '../platform/cover_store/cover_store.dart';
import '../platform/cover_store/mobile_cover_store.dart';
import '../platform/cover_store/web_cover_store.dart';
import 'lookup_providers.dart';
import 'providers.dart';

part 'cover_providers.g.dart';

/// The platform's cover store: files on mobile, database blobs on web.
/// Image decoding and resizing run off the UI thread via `compute`.
@Riverpod(keepAlive: true)
CoverStore coverStore(Ref ref) {
  final client = ref.watch(httpClientProvider);
  if (kIsWeb) {
    return WebCoverStore(
      client: client,
      db: ref.watch(appDatabaseProvider),
      clock: ref.watch(clockProvider),
      process: (bytes) => compute(processCoverDefault, bytes),
    );
  }
  return MobileCoverStore(
    client: client,
    documentsDir: getApplicationDocumentsDirectory,
    clock: ref.watch(clockProvider),
    process: (bytes) => compute(processCoverDefault, bytes),
  );
}

/// Resolves a `Book.coverLocalPath` reference to an image (null if none).
@riverpod
Future<ImageProvider?> coverImage(Ref ref, String? reference) async {
  if (reference == null || reference.isEmpty) return null;
  return ref.watch(coverStoreProvider).imageFor(reference);
}

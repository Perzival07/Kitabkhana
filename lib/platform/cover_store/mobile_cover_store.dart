import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;

import '../../core/clock.dart';
import '../../core/failure.dart';
import '../../core/image/cover_processor.dart';
import '../../core/result.dart';
import 'cover_downloader.dart';
import 'cover_store.dart';

/// Stores covers as `<documents>/covers/<bookId>.jpg`. References are the
/// relative path plus a version, `covers/<bookId>.jpg?v=<millis>`; replacing a
/// cover changes the version so image caches never show the old picture.
class MobileCoverStore implements CoverStore {
  MobileCoverStore({
    required http.Client client,
    required this._documentsDir,
    required this._clock,
    Future<CoverProcessResult> Function(Uint8List bytes)? process,
  }) : _downloader = CoverDownloader(client),
       _process = process ?? ((b) async => processCoverDefault(b));

  final CoverDownloader _downloader;
  final Future<Directory> Function() _documentsDir;
  final Clock _clock;
  final Future<CoverProcessResult> Function(Uint8List bytes) _process;

  static String pathFor(String bookId) => 'covers/$bookId.jpg';

  static String referenceFor(String bookId, DateTime at) =>
      '${pathFor(bookId)}?v=${at.toUtc().millisecondsSinceEpoch}';

  static final RegExp _reference = RegExp(
    r'^(covers/[A-Za-z0-9_-]{1,64}\.jpg)(?:\?v=\d+)?$',
  );

  /// The relative file path inside a valid reference, else null.
  String? _pathOf(String reference) =>
      _reference.firstMatch(reference)?.group(1);

  Future<File> _fileFor(String relativePath) async {
    final root = await _documentsDir();
    return File('${root.path}/$relativePath');
  }

  Future<String> _write(String bookId, Uint8List jpeg) async {
    final file = await _fileFor(pathFor(bookId));
    await file.parent.create(recursive: true);
    // Write to a temp file and rename so a crash never leaves a torn image.
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsBytes(jpeg, flush: true);
    await tmp.rename(file.path);
    return referenceFor(bookId, _clock.now());
  }

  Err<T> _badId<T>() => Err<T>(
    const ValidationFailure(field: 'bookId', messageKey: 'failureValidation'),
  );

  @override
  Future<Result<String?>> saveFromUrl(String bookId, String url) async {
    if (!isSafeBookId(bookId)) return _badId<String?>();
    final downloaded = await _downloader.download(url);
    if (downloaded is Err<Uint8List>) {
      final f = downloaded.failure;
      // A missing image is "no cover", not an error.
      return f is NotFoundFailure ? const Ok<String?>(null) : Err<String?>(f);
    }
    final processed = await _process(downloaded.getOrNull()!);
    if (processed.status != CoverProcessStatus.ok) {
      return const Ok<String?>(null);
    }
    try {
      return Ok<String?>(await _write(bookId, processed.jpeg!));
    } on FileSystemException catch (e) {
      return Err<String?>(StorageFailure(e));
    }
  }

  @override
  Future<Result<String>> saveFromBytes(String bookId, Uint8List bytes) async {
    if (!isSafeBookId(bookId)) return _badId<String>();
    final processed = await _process(bytes);
    if (processed.status != CoverProcessStatus.ok) {
      return const Err<String>(
        ValidationFailure(field: 'photo', messageKey: 'failureValidation'),
      );
    }
    try {
      return Ok<String>(await _write(bookId, processed.jpeg!));
    } on FileSystemException catch (e) {
      return Err<String>(StorageFailure(e));
    }
  }

  @override
  Future<Uint8List?> readBytes(String reference) async {
    final path = _pathOf(reference);
    if (path == null) return null;
    final file = await _fileFor(path);
    return await file.exists() ? file.readAsBytes() : null;
  }

  @override
  Future<ImageProvider?> imageFor(String reference) async {
    // Bytes rather than FileImage: Flutter caches FileImage by path, which
    // would keep showing the old picture after a cover is replaced.
    final bytes = await readBytes(reference);
    return bytes == null ? null : MemoryImage(bytes);
  }

  @override
  Future<void> delete(String bookId) async {
    if (!isSafeBookId(bookId)) return;
    final file = await _fileFor(pathFor(bookId));
    if (await file.exists()) await file.delete();
  }
}

import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;

import '../../core/clock.dart';
import '../../core/failure.dart';
import '../../core/image/cover_processor.dart';
import '../../core/result.dart';
import '../../data/db/app_database.dart';
import 'cover_downloader.dart';
import 'cover_store.dart';

/// Stores processed covers in the `cover_blobs` table, so they persist in the
/// browser's IndexedDB with the rest of the data and work offline.
/// References look like `cover:<bookId>?v=<millis>`; the version changes when
/// a cover is replaced so image caches never show the old picture.
class WebCoverStore implements CoverStore {
  WebCoverStore({
    required http.Client client,
    required this._db,
    required this._clock,
    Future<CoverProcessResult> Function(Uint8List bytes)? process,
  }) : _downloader = CoverDownloader(client),
       _process = process ?? ((b) async => processCoverDefault(b));

  final CoverDownloader _downloader;
  final AppDatabase _db;
  final Clock _clock;
  final Future<CoverProcessResult> Function(Uint8List bytes) _process;

  static String referenceFor(String bookId, DateTime at) =>
      'cover:$bookId?v=${at.toUtc().millisecondsSinceEpoch}';

  static final RegExp _reference = RegExp(
    r'^cover:([A-Za-z0-9_-]{1,64})(?:\?v=\d+)?$',
  );

  String? _bookIdOf(String reference) =>
      _reference.firstMatch(reference)?.group(1);

  Future<String> _write(String bookId, Uint8List jpeg) async {
    final now = _clock.now();
    await _db
        .into(_db.coverBlobs)
        .insertOnConflictUpdate(
          CoverBlobsCompanion.insert(
            bookId: bookId,
            bytes: jpeg,
            updatedAt: now,
          ),
        );
    return referenceFor(bookId, now);
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
      return f is NotFoundFailure ? const Ok<String?>(null) : Err<String?>(f);
    }
    final processed = await _process(downloaded.getOrNull()!);
    if (processed.status != CoverProcessStatus.ok) {
      return const Ok<String?>(null);
    }
    try {
      return Ok<String?>(await _write(bookId, processed.jpeg!));
    } on Object catch (e) {
      // Includes the foreign key error when the book does not exist.
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
    } on Object catch (e) {
      return Err<String>(StorageFailure(e));
    }
  }

  @override
  Future<Uint8List?> readBytes(String reference) async {
    final id = _bookIdOf(reference);
    if (id == null) return null;
    final row = await (_db.select(
      _db.coverBlobs,
    )..where((t) => t.bookId.equals(id))).getSingleOrNull();
    return row?.bytes;
  }

  @override
  Future<ImageProvider?> imageFor(String reference) async {
    final bytes = await readBytes(reference);
    return bytes == null ? null : MemoryImage(bytes);
  }

  @override
  Future<void> delete(String bookId) async {
    if (!isSafeBookId(bookId)) return;
    await (_db.delete(
      _db.coverBlobs,
    )..where((t) => t.bookId.equals(bookId))).go();
  }
}

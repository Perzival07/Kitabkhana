import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/platform/cover_store/cover_store.dart';

/// A cover store that records calls and returns canned results.
class FakeCoverStore implements CoverStore {
  final List<String> urlSaves = <String>[];
  final List<String> photoSaves = <String>[];
  final List<String> deletes = <String>[];

  /// Returned by [saveFromUrl]; null means "no cover".
  String? urlResult = 'covers/x.jpg?v=1';
  Failure? urlFailure;
  Object? throwOnUrl;
  ImageProvider? image;

  @override
  Future<Result<String?>> saveFromUrl(String bookId, String url) async {
    urlSaves.add('$bookId $url');
    if (throwOnUrl != null) throw throwOnUrl!;
    final f = urlFailure;
    if (f != null) return Err<String?>(f);
    return Ok<String?>(urlResult);
  }

  /// Image bytes by cover reference, returned by [readBytes].
  final Map<String, Uint8List> files = <String, Uint8List>{};

  /// Bytes given to [saveFromBytes], by book id.
  final Map<String, Uint8List> saved = <String, Uint8List>{};

  /// Book ids whose [saveFromBytes] fails.
  final Set<String> failPhotoFor = <String>{};

  @override
  Future<Result<String>> saveFromBytes(String bookId, Uint8List bytes) async {
    photoSaves.add(bookId);
    if (failPhotoFor.contains(bookId)) {
      return const Err<String>(StorageFailure());
    }
    saved[bookId] = bytes;
    return Ok<String>('covers/$bookId.jpg?v=2');
  }

  @override
  Future<Uint8List?> readBytes(String reference) async => files[reference];

  @override
  Future<ImageProvider?> imageFor(String reference) async => image;

  @override
  Future<void> delete(String bookId) async => deletes.add(bookId);
}

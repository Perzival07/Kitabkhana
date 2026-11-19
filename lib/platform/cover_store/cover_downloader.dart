import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/failure.dart';
import '../../core/image/cover_processor.dart';
import '../../core/result.dart';

/// Downloads cover images with a timeout and a size limit.
class CoverDownloader {
  CoverDownloader(this._client, {this.timeout = const Duration(seconds: 10)});

  final http.Client _client;
  final Duration timeout;

  Future<Result<Uint8List>> download(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
      return const Err<Uint8List>(
        ValidationFailure(field: 'url', messageKey: 'failureValidation'),
      );
    }
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 404) {
        return const Err<Uint8List>(NotFoundFailure('cover'));
      }
      if (response.statusCode != 200) {
        return Err<Uint8List>(NetworkFailure.server(response.statusCode));
      }
      final bytes = response.bodyBytes;
      if (bytes.length > kMaxCoverInputBytes) {
        return Err<Uint8List>(NetworkFailure.server(response.statusCode));
      }
      return Ok<Uint8List>(bytes);
    } on TimeoutException {
      return const Err<Uint8List>(NetworkFailure.timeout());
    } on http.ClientException {
      return const Err<Uint8List>(NetworkFailure.offline());
    }
  }
}

/// Book ids become file names and database keys; only safe characters pass.
final RegExp _safeId = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

bool isSafeBookId(String id) => _safeId.hasMatch(id);

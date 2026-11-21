import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/image/page_image.dart';
import '../features/quotes/application/save_quote.dart';
import '../features/quotes/domain/quote.dart';
import '../platform/ocr/mobile_ocr_service.dart';
import '../platform/ocr/ocr_service.dart';
import '../platform/ocr/web_ocr_service.dart';
import 'providers.dart';
import 'repositories.dart';

part 'quote_providers.g.dart';

/// The on-device text reader; the web has none, so quotes are typed there.
@Riverpod(keepAlive: true)
OcrService ocrService(Ref ref) =>
    kIsWeb ? const WebOcrService() : MobileOcrService();

/// Rotates and crops a photo. Runs off the UI thread; tests swap in a
/// direct call.
typedef PageEditor = Future<Uint8List> Function(PageEdit edit);

@Riverpod(keepAlive: true)
PageEditor pageEditor(Ref ref) =>
    (edit) => compute(rotateAndCrop, edit);

@Riverpod(keepAlive: true)
SaveQuote saveQuote(Ref ref) => SaveQuote(
  quotes: ref.watch(quoteRepositoryProvider),
  books: ref.watch(bookRepositoryProvider),
  clock: ref.watch(clockProvider),
);

/// Live quotes of one book, newest first.
@riverpod
Stream<List<Quote>> bookQuotes(Ref ref, String bookId) =>
    ref.watch(quoteRepositoryProvider).watchAll(bookId: bookId);

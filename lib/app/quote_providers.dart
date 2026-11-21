import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/image/page_image.dart';
import '../features/quotes/application/save_quote.dart';
import '../features/quotes/domain/quote.dart';
import '../features/quotes/domain/quote_of_week.dart';
import '../features/quotes/domain/quote_repository.dart';
import '../platform/ocr/mobile_ocr_service.dart';
import '../platform/ocr/ocr_service.dart';
import '../platform/ocr/web_ocr_service.dart';
import '../platform/share/share_service.dart';
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

@Riverpod(keepAlive: true)
EditQuote editQuote(Ref ref) => EditQuote(
  quotes: ref.watch(quoteRepositoryProvider),
  books: ref.watch(bookRepositoryProvider),
);

@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) => const SharePlusShareService();

/// The Quotes screen's search text, favourites switch and book filter.
@riverpod
class QuotesFilter extends _$QuotesFilter {
  @override
  ({String query, bool favourites, String? bookId}) build() =>
      (query: '', favourites: false, bookId: null);

  void setQuery(String q) =>
      state = (query: q, favourites: state.favourites, bookId: state.bookId);

  void toggleFavourites() => state = (
    query: state.query,
    favourites: !state.favourites,
    bookId: state.bookId,
  );

  void setBook(String? id) =>
      state = (query: state.query, favourites: state.favourites, bookId: id);
}

/// Every quote with its book, newest first (no filters).
@riverpod
Stream<List<QuoteWithBook>> allQuotes(Ref ref) =>
    ref.watch(quoteRepositoryProvider).watchWithBooks();

/// The quotes matching the filter. Search looks in the text, the book title
/// and the authors, ignoring case.
@riverpod
AsyncValue<List<QuoteWithBook>> filteredQuotes(Ref ref) {
  final f = ref.watch(quotesFilterProvider);
  return ref.watch(allQuotesProvider).whenData((all) {
    final q = f.query.trim().toLowerCase();
    return [
      for (final e in all)
        if ((!f.favourites || e.quote.isFavourite) &&
            (f.bookId == null || e.quote.bookId == f.bookId) &&
            (q.isEmpty ||
                e.quote.body.toLowerCase().contains(q) ||
                e.bookTitle.toLowerCase().contains(q) ||
                e.bookAuthors.toLowerCase().contains(q)))
          e,
    ];
  });
}

/// This week's featured quote; null while there are no quotes.
@riverpod
QuoteWithBook? quoteOfWeek(Ref ref) {
  final all = ref.watch(allQuotesProvider).value;
  if (all == null) return null;
  final pick = quoteOfTheWeek(
    all.map((e) => e.quote),
    ref.watch(clockProvider).today(),
  );
  if (pick == null) return null;
  return all.firstWhere((e) => e.quote.id == pick.id);
}

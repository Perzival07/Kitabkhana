import 'dart:async';

import '../../../core/result.dart';
import '../../../core/text/isbn.dart';
import '../../../core/text/similarity.dart';
import '../../../core/text/title_key.dart';
import '../../lending/domain/loan_direction.dart';
import '../../lending/domain/loan_repository.dart';
import '../../library/application/book_lookup_service.dart';
import '../../library/domain/book.dart';
import '../../library/domain/book_enums.dart';
import '../../library/domain/book_info.dart';
import '../../library/domain/book_repository.dart';
import '../../locations/domain/location.dart';
import '../../locations/domain/location_repository.dart';
import '../domain/ownership_result.dart';

/// Decides whether a scanned or typed book is already in the library.
///
/// Pipeline, stopping at the first confident answer:
/// 1. an ISBN that matches a book exactly;
/// 2. the catalogue's work key (other editions), using the lookup cache and
///    waiting at most [lookupTimeout] for the network;
/// 3. an exact title key;
/// 4. trigram similarity of at least [similarityThreshold];
/// 5. not in the library, carrying whatever the lookup found.
///
/// Steps 1, 3, 4 and 5 work fully offline.
class CheckOwnership {
  CheckOwnership({
    required this.books,
    required this.loans,
    required this.locations,
    required this.lookup,
    this.lookupTimeout = const Duration(milliseconds: 1500),
    this.similarityThreshold = 0.8,
  });

  final BookRepository books;
  final LoanRepository loans;
  final LocationRepository locations;
  final BookLookupService lookup;
  final Duration lookupTimeout;
  final double similarityThreshold;

  /// How many candidates the fuzzy step looks at.
  static const int _poolSize = 60;

  Future<OwnershipResult> call(String input) async {
    final text = input.trim();
    final isbn = parseIsbn(text);

    // 1. Exact ISBN.
    if (isbn != null) {
      final exact = _ok(await books.findByIsbn(isbn));
      if (exact.isNotEmpty) return _resolve(exact, otherEdition: false);
    }

    // 2. Same work, another edition (needs catalogue data).
    BookInfo? info;
    if (isbn != null) {
      info = await _info(isbn);
      final workKey = info?.olWorkKey;
      if (workKey != null) {
        final sameWork = _ok(await books.findByWorkKey(workKey));
        if (sameWork.isNotEmpty) return _resolve(sameWork, otherEdition: true);
      }
    }

    // 3. Same title (and first author), however it was spelled.
    final titleKey = info != null
        ? normalizeTitle(info.title, info.authorsText)
        : normalizeTitle(text);
    final byKey = _ok(await books.findByTitleKey(titleKey));
    if (byKey.isNotEmpty) return _resolve(byKey, otherEdition: isbn != null);
    final byTitle = await _sameTitle(
      info?.title ?? text,
      authors: info?.authorsText ?? '',
    );
    if (byTitle.isNotEmpty) {
      return _resolve(byTitle, otherEdition: isbn != null);
    }

    // 4. Close enough to ask the user.
    final close = await _similar(info?.title ?? text, info?.authorsText ?? '');
    if (close.isNotEmpty) return PossibleMatch(close);

    // 5. Not here.
    return NotInLibrary(isbn: isbn, info: info);
  }

  List<Book> _ok(Result<List<Book>> r) => r.getOrNull() ?? const <Book>[];

  /// Cached data first (instant, offline); then the network, but never for
  /// longer than [lookupTimeout].
  Future<BookInfo?> _info(Isbn13 isbn) async {
    final cached = await lookup.cachedIsbn(isbn);
    if (cached != null) return cached;
    try {
      final r = await lookup.lookupIsbn(isbn).timeout(lookupTimeout);
      return r.getOrNull();
    } on TimeoutException {
      return null;
    } on Object {
      return null;
    }
  }

  /// Books whose normalised title equals the typed title, for input without an
  /// author (the stored key also carries the author's surname).
  Future<List<Book>> _sameTitle(String title, {required String authors}) async {
    if (authors.isNotEmpty) return const <Book>[];
    final wanted = normalizeTitle(title).titlePart;
    if (wanted.isEmpty) return const <Book>[];
    final pool = await _pool(title);
    return <Book>[
      for (final b in pool)
        if (b.titleKey.titlePart == wanted) b,
    ];
  }

  Future<List<MatchCandidate>> _similar(String title, String authors) async {
    final query =
        '${normalizeTitle(title).titlePart} '
                '${normalizeTitle('x', authors).authorPart}'
            .trim();
    if (query.isEmpty) return const <MatchCandidate>[];
    final pool = await _pool(title);
    final scored = <MatchCandidate>[];
    for (final b in pool) {
      final theirs = '${b.titleKey.titlePart} ${b.titleKey.authorPart}'.trim();
      // Typed text rarely includes the author: compare titles then too.
      final score = authors.isEmpty
          ? trigramSimilarity(query, b.titleKey.titlePart)
          : trigramSimilarity(query, theirs);
      if (score >= similarityThreshold) scored.add(MatchCandidate(b, score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(3).toList();
  }

  /// A small pool of likely books: the full-text hit list, or, when words are
  /// misspelled, the hits for each longer word on its own.
  Future<List<Book>> _pool(String text) async {
    final full = _ok(await books.search(text, limit: _poolSize));
    if (full.isNotEmpty) return full;
    final byId = <String, Book>{};
    final words = normalizeText(text)
        .split(' ')
        .where((w) => w.length >= 3)
        .toList();
    for (final w in words) {
      // Shorten each word so a typo near the end still matches its prefix.
      final prefix = w.length > 4 ? w.substring(0, w.length - 2) : w;
      for (final b in _ok(await books.search(prefix, limit: _poolSize))) {
        byId[b.id] = b;
      }
    }
    return byId.values.toList();
  }

  Future<OwnershipResult> _resolve(
    List<Book> matches, {
    required bool otherEdition,
  }) async {
    // A copy you own beats a wishlist entry for the same book.
    final ordered = <Book>[
      ...matches.where((b) => b.ownership != Ownership.wishlist),
      ...matches.where((b) => b.ownership == Ownership.wishlist),
    ];
    final book = ordered.first;
    if (book.ownership == Ownership.wishlist) return OnWishlist(book);

    final loan = (await loans.activeFor(book.id)).getOrNull();
    if (loan != null && loan.direction == LoanDirection.lent) {
      return LentOut(book, loan);
    }
    if (book.ownership == Ownership.borrowed ||
        (loan != null && loan.direction == LoanDirection.borrowed)) {
      return BorrowedIn(book, loan);
    }
    final label = await _label(book.locationId);
    return otherEdition ? OtherEdition(book, label) : Owned(book, label);
  }

  Future<String?> _label(String? locationId) async {
    if (locationId == null) return null;
    final all = await locations.watchAll().first;
    Location? place;
    for (final l in all) {
      if (l.id == locationId) place = l;
    }
    if (place == null) return null;
    final parentId = place.parentId;
    if (parentId == null) return place.name;
    for (final p in all) {
      if (p.id == parentId) return '${p.name} › ${place.name}';
    }
    return place.name;
  }
}

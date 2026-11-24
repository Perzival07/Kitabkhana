import 'package:csv/csv.dart';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../core/text/isbn.dart';
import '../../../core/text/series.dart';
import '../../../core/text/title_key.dart';
import '../../../core/uuid.dart';
import '../../library/domain/book.dart';
import '../../library/domain/book_enums.dart';
import '../../library/domain/book_repository.dart';
import '../../tags/domain/tag_repository.dart';

/// The reading apps whose library exports Kitabkhana understands.
enum ReadingApp { goodreads, storygraph }

/// One book from a Goodreads or StoryGraph export.
final class ImportedBook {
  const ImportedBook({
    required this.title,
    this.authors = '',
    this.isbn,
    this.pages,
    this.status = ReadStatus.want,
    this.rating,
    this.finishedOn,
    this.owned = false,
    this.tags = const <String>[],
    this.notes,
    this.series,
    this.seriesNumber,
  });

  final String title;
  final String authors;
  final Isbn13? isbn;
  final int? pages;
  final ReadStatus status;

  /// 1 to 5, or null when not rated.
  final int? rating;
  final DateTime? finishedOn;

  /// The export says the reader owns it.
  final bool owned;
  final List<String> tags;
  final String? notes;
  final String? series;
  final double? seriesNumber;
}

/// A parsed export.
final class ReadingAppExport {
  const ReadingAppExport(this.app, this.books);

  final ReadingApp app;
  final List<ImportedBook> books;
}

/// What an import did.
final class ReadingAppImportSummary {
  const ReadingAppImportSummary({required this.added, required this.skipped});

  final int added;

  /// Already in the library (same ISBN, or same title and author).
  final int skipped;
}

/// Reads a Goodreads ("Export Library") or StoryGraph ("Export StoryGraph
/// Library") CSV. A `ValidationFailure` when it is neither.
Result<ReadingAppExport> parseReadingAppCsv(String text) {
  final List<List<dynamic>> rows;
  try {
    rows = csv.decode(text.replaceFirst('﻿', ''));
  } on Object {
    return const Err(_notAnExport);
  }
  if (rows.isEmpty) return const Err(_notAnExport);
  final header = <String, int>{
    for (final (i, h) in rows.first.indexed) '$h'.trim().toLowerCase(): i,
  };
  final ReadingApp app;
  if (header.containsKey('exclusive shelf') && header.containsKey('title')) {
    app = ReadingApp.goodreads;
  } else if (header.containsKey('read status') && header.containsKey('title')) {
    app = ReadingApp.storygraph;
  } else {
    return const Err(_notAnExport);
  }

  final books = <ImportedBook>[];
  for (final row in rows.skip(1)) {
    String cell(String name) {
      final i = header[name];
      if (i == null || i >= row.length) return '';
      return '${row[i]}'.trim();
    }

    final title = cell('title');
    if (title.isEmpty) continue;
    books.add(
      _withSeries(
        app == ReadingApp.goodreads ? _goodreads(cell) : _storygraph(cell),
      ),
    );
  }
  return Ok(ReadingAppExport(app, books));
}

/// "The Colour of Magic (Discworld, #1)" becomes the title "The Colour of
/// Magic" in the series "Discworld", number 1.
ImportedBook _withSeries(ImportedBook b) {
  final split = splitSeriesFromTitle(b.title);
  if (split == null) return b;
  return ImportedBook(
    title: split.title,
    authors: b.authors,
    isbn: b.isbn,
    pages: b.pages,
    status: b.status,
    rating: b.rating,
    finishedOn: b.finishedOn,
    owned: b.owned,
    tags: b.tags,
    notes: b.notes,
    series: split.series,
    seriesNumber: split.number,
  );
}

const ValidationFailure _notAnExport = ValidationFailure(
  field: 'file',
  messageKey: 'importNotAnExport',
);

/// Goodreads' exclusive shelves; every other shelf becomes a tag.
const Set<String> _goodreadsShelves = <String>{
  'read',
  'to-read',
  'currently-reading',
};

ImportedBook _goodreads(String Function(String) cell) {
  final authors = <String>[
    cell('author'),
    ...cell('additional authors').split(','),
  ].map((a) => a.trim()).where((a) => a.isNotEmpty).toList();
  final shelf = cell('exclusive shelf').toLowerCase();
  final notes = cell('private notes');
  return ImportedBook(
    title: cell('title'),
    authors: authors.join(', '),
    isbn: _isbn(cell('isbn13')) ?? _isbn(cell('isbn')),
    pages: _positive(cell('number of pages')),
    status: switch (shelf) {
      'read' => ReadStatus.finished,
      'currently-reading' => ReadStatus.reading,
      _ => ReadStatus.want,
    },
    rating: _rating(cell('my rating')),
    finishedOn: _date(cell('date read')),
    owned: (_positive(cell('owned copies')) ?? 0) > 0,
    tags: cell('bookshelves')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && !_goodreadsShelves.contains(s))
        .toList(),
    notes: notes.isEmpty ? null : notes,
  );
}

ImportedBook _storygraph(String Function(String) cell) {
  return ImportedBook(
    title: cell('title'),
    authors: cell('authors')
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .join(', '),
    isbn: _isbn(cell('isbn/uid')),
    status: switch (cell('read status').toLowerCase()) {
      'read' => ReadStatus.finished,
      'currently-reading' || 'paused' => ReadStatus.reading,
      'did-not-finish' => ReadStatus.dropped,
      _ => ReadStatus.want,
    },
    rating: _rating(cell('star rating')),
    finishedOn: _date(cell('last date read')),
    owned: cell('owned?').toLowerCase() == 'yes',
    tags: cell('tags')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(),
  );
}

/// Goodreads writes ISBNs as `="9780441013593"`; anything not a valid ISBN
/// (StoryGraph's own ids) is dropped.
Isbn13? _isbn(String raw) {
  final digits = raw.replaceAll(RegExp('[^0-9Xx]'), '');
  return digits.isEmpty ? null : parseIsbn(digits);
}

int? _positive(String raw) {
  final n = int.tryParse(raw);
  return n != null && n > 0 ? n : null;
}

/// Whole stars 1 to 5 (StoryGraph allows quarters; 0 means unrated).
int? _rating(String raw) {
  final n = double.tryParse(raw);
  if (n == null || n <= 0) return null;
  return n.round().clamp(1, 5);
}

/// `2023/05/14` or `2023-05-14`.
DateTime? _date(String raw) {
  final m = RegExp(r'^(\d{4})[/-](\d{1,2})[/-](\d{1,2})').firstMatch(raw);
  if (m == null) return null;
  return DateTime(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
}

/// Adds the books of an export that are not in the library yet.
class ImportReadingApp {
  ImportReadingApp({
    required this.books,
    required this.tags,
    required this.clock,
  });

  final BookRepository books;
  final TagRepository tags;
  final Clock clock;

  /// How many of [export]'s books the library already has.
  Future<int> countExisting(ReadingAppExport export) async {
    var n = 0;
    for (final b in export.books) {
      if (await _exists(b)) n++;
    }
    return n;
  }

  /// [wantToReadAs]: where unowned want-to-read books go (the wishlist, or the
  /// shelves). Books the export marks as owned, and books read or being read,
  /// are always owned.
  Future<Result<ReadingAppImportSummary>> call(
    ReadingAppExport export, {
    required Ownership wantToReadAs,
  }) async {
    var added = 0;
    var skipped = 0;
    try {
      for (final b in export.books) {
        if (await _exists(b)) {
          skipped++;
          continue;
        }
        final now = clock.now();
        var book = Book.create(
          id: uuidV7(),
          title: b.title,
          authors: b.authors,
          isbn13: b.isbn,
          pages: b.pages,
          now: now,
          status: b.status,
          notes: b.notes,
          series: b.series,
          seriesNumber: b.seriesNumber,
          ownership: b.owned || b.status != ReadStatus.want
              ? Ownership.owned
              : wantToReadAs,
          // Shown straight from Open Library when online; a generated cover
          // otherwise. Nothing is downloaded in bulk.
          coverUrl: b.isbn == null
              ? null
              : 'https://covers.openlibrary.org/b/isbn/${b.isbn!.value}-M.jpg'
                    '?default=false',
        );
        if (b.rating != null) book = book.copyWith(rating: b.rating);
        if (b.status == ReadStatus.finished) {
          book = book.copyWith(
            finishedOn: b.finishedOn,
            currentPage: b.pages ?? 0,
          );
        }
        final saved = await books.upsert(book);
        if (saved case Err<Book>(:final failure)) return Err(failure);
        for (final name in b.tags) {
          final tag = (await tags.createIfAbsent(name)).getOrNull();
          if (tag != null) await tags.attach(book.id, tag.id);
        }
        added++;
      }
    } on Object catch (e, s) {
      return Err(UnexpectedFailure(e, s));
    }
    return Ok(ReadingAppImportSummary(added: added, skipped: skipped));
  }

  Future<bool> _exists(ImportedBook b) async {
    final isbn = b.isbn;
    if (isbn != null &&
        ((await books.findByIsbn(isbn)).getOrNull()?.isNotEmpty ?? false)) {
      return true;
    }
    final byTitle = await books.findByTitleKey(
      normalizeTitle(b.title, b.authors),
    );
    return byTitle.getOrNull()?.isNotEmpty ?? false;
  }
}

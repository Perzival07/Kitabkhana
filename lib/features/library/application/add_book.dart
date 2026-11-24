import 'dart:async';
import 'dart:typed_data';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/logger.dart';
import '../../../core/result.dart';
import '../../../core/text/isbn.dart';
import '../../../core/uuid.dart';
import '../../../platform/cover_store/cover_store.dart';
import '../domain/book.dart';
import '../domain/book_enums.dart';
import '../domain/book_info.dart';
import '../domain/book_repository.dart';

/// Everything the Add Book form collects.
final class BookDraft {
  const BookDraft({
    this.title = '',
    this.authors = '',
    this.subtitle,
    this.isbn13,
    this.olWorkKey,
    this.pages,
    this.genre = '',
    this.language = '',
    this.ownership = Ownership.owned,
    this.status = ReadStatus.want,
    this.locationId,
    this.ownerName,
    this.notes,
    this.coverUrl,
    this.coverPhoto,
    this.series,
    this.seriesNumber,
  });

  /// A draft pre-filled from catalogue data.
  factory BookDraft.fromInfo(BookInfo info) => BookDraft(
    title: info.title,
    authors: info.authorsText,
    subtitle: info.subtitle,
    isbn13: info.isbn13,
    olWorkKey: info.olWorkKey,
    pages: info.pages,
    coverUrl: info.coverUrl,
    series: info.series,
    seriesNumber: info.seriesNumber,
  );

  final String title;
  final String authors;
  final String? subtitle;
  final Isbn13? isbn13;
  final String? olWorkKey;
  final int? pages;
  final String genre;
  final String language;
  final Ownership ownership;
  final ReadStatus status;
  final String? locationId;
  final String? ownerName;
  final String? notes;
  final String? coverUrl;

  /// A photo the user took or chose (processed and stored after saving).
  final Uint8List? coverPhoto;

  /// The series and the book's place in it.
  final String? series;
  final double? seriesNumber;
}

sealed class AddBookResult {
  const AddBookResult();
}

/// The book was saved. [coverJob] completes when its cover (if any) has been
/// fetched and attached; the UI does not need to wait for it.
final class BookAdded extends AddBookResult {
  const BookAdded(this.book, this.coverJob);

  final Book book;
  final Future<void> coverJob;
}

/// Nothing was saved: these books look like the same one.
final class DuplicatesFound extends AddBookResult {
  const DuplicatesFound(this.books);

  final List<Book> books;
}

/// Adds a book: validates, checks for duplicates by ISBN, work key and title
/// key, saves, then fetches the cover in the background.
class AddBook {
  AddBook({
    required this.books,
    required this.covers,
    required this.clock,
    this.logger,
    String Function()? newId,
  }) : _newId = newId ?? uuidV7;

  final BookRepository books;
  final CoverStore covers;
  final Clock clock;
  final AppLogger? logger;
  final String Function() _newId;

  /// Finds existing (non-deleted) books that look like [draft].
  Future<Result<List<Book>>> findDuplicates(BookDraft draft) async {
    final found = <String, Book>{};
    final isbn = draft.isbn13;
    if (isbn != null) {
      final r = await books.findByIsbn(isbn);
      if (r case Err<List<Book>>(:final failure)) return Err(failure);
      for (final b in r.getOrNull()!) {
        found[b.id] = b;
      }
    }
    final work = draft.olWorkKey;
    if (work != null && work.isNotEmpty) {
      final r = await books.findByWorkKey(work);
      if (r case Err<List<Book>>(:final failure)) return Err(failure);
      for (final b in r.getOrNull()!) {
        found[b.id] = b;
      }
    }
    final key = Book.create(
      id: '_',
      title: draft.title,
      authors: draft.authors,
      now: clock.now(),
    ).titleKey;
    if (key.titlePart.isNotEmpty) {
      final r = await books.findByTitleKey(key);
      if (r case Err<List<Book>>(:final failure)) return Err(failure);
      for (final b in r.getOrNull()!) {
        found[b.id] = b;
      }
    }
    return Ok(found.values.toList());
  }

  Future<Result<AddBookResult>> call(
    BookDraft draft, {
    bool allowDuplicate = false,
  }) async {
    final title = draft.title.trim();
    if (title.isEmpty) {
      return const Err(
        ValidationFailure(field: 'title', messageKey: 'failureValidation'),
      );
    }
    final pages = draft.pages;
    if (pages != null && pages <= 0) {
      return const Err(
        ValidationFailure(field: 'pages', messageKey: 'failureValidation'),
      );
    }

    if (!allowDuplicate) {
      final dupes = await findDuplicates(draft);
      switch (dupes) {
        case Err<List<Book>>(:final failure):
          return Err(failure);
        case Ok<List<Book>>(:final value) when value.isNotEmpty:
          return Ok(DuplicatesFound(value));
        case Ok<List<Book>>():
          break;
      }
    }

    final now = clock.now();
    var book = Book.create(
      id: _newId(),
      title: title,
      authors: draft.authors.trim(),
      now: now,
      isbn13: draft.isbn13,
      olWorkKey: draft.olWorkKey,
      subtitle: _blankToNull(draft.subtitle),
      coverUrl: draft.coverUrl,
      pages: pages,
      genre: draft.genre.trim(),
      language: draft.language.trim(),
      ownership: draft.ownership,
      status: draft.status,
      locationId: draft.locationId,
      ownerName: _blankToNull(draft.ownerName),
      notes: _blankToNull(draft.notes),
      series: _blankToNull(draft.series),
      seriesNumber: draft.seriesNumber,
    );
    // Reading status implies dates and progress, like the detail page does.
    if (draft.status == ReadStatus.reading) {
      book = book.copyWith(startedOn: clock.today());
    } else if (draft.status == ReadStatus.finished) {
      book = book.copyWith(finishedOn: clock.today(), currentPage: pages ?? 0);
    }

    final saved = await books.upsert(book);
    if (saved case Err<Book>(:final failure)) return Err(failure);
    final stored = saved.getOrNull()!;
    return Ok(BookAdded(stored, _attachCover(stored, draft)));
  }

  /// Photo first (the user chose it), else the catalogue image.
  Future<void> _attachCover(Book book, BookDraft draft) async {
    try {
      await _attachCoverUnsafe(book, draft);
    } on Object catch (error, stack) {
      // The cover is optional: never let a background failure escape.
      logger?.warn('cover job failed');
      logger?.error('cover job error', error: error, stack: stack);
    }
  }

  Future<void> _attachCoverUnsafe(Book book, BookDraft draft) async {
    final String? reference;
    final photo = draft.coverPhoto;
    if (photo != null) {
      reference = (await covers.saveFromBytes(book.id, photo)).getOrNull();
    } else if (book.coverUrl != null) {
      reference = (await covers.saveFromUrl(
        book.id,
        book.coverUrl!,
      )).getOrNull();
    } else {
      return;
    }
    if (reference == null) return;
    // Atomic read-modify-write: edits made while the cover downloaded survive.
    await books.update(book.id, (b) => b.copyWith(coverLocalPath: reference));
  }

  String? _blankToNull(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}

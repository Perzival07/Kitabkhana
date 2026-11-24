import '../../application/add_book.dart';
import '../../domain/book.dart';
import '../../domain/book_info.dart';

/// What the book form screen starts from.
final class BookFormArgs {
  const BookFormArgs({
    this.draft = const BookDraft(),
    this.info,
    this.notice,
    this.editing,
  });

  /// The book being edited; null when adding.
  final Book? editing;

  /// A form that edits [book] in place.
  factory BookFormArgs.edit(Book book) => BookFormArgs(
    editing: book,
    draft: BookDraft(
      title: book.title,
      authors: book.authors,
      subtitle: book.subtitle,
      isbn13: book.isbn13,
      olWorkKey: book.olWorkKey,
      pages: book.pages,
      genre: book.genre,
      language: book.language,
      ownership: book.ownership,
      status: book.status,
      locationId: book.locationId,
      ownerName: book.ownerName,
      notes: book.notes,
      coverUrl: book.coverUrl,
      series: book.series,
      seriesNumber: book.seriesNumber,
    ),
  );

  bool get isEdit => editing != null;

  /// Pre-filled values (from a lookup, or just an ISBN that was not found).
  final BookDraft draft;

  /// Catalogue data when this is a preview of a found book.
  final BookInfo? info;

  /// A friendly message shown above the form (e.g. "not found").
  final String? notice;

  bool get isPreview => info != null;
}

import '../../application/add_book.dart';
import '../../domain/book_info.dart';

/// What the book form screen starts from.
final class BookFormArgs {
  const BookFormArgs({this.draft = const BookDraft(), this.info, this.notice});

  /// Pre-filled values (from a lookup, or just an ISBN that was not found).
  final BookDraft draft;

  /// Catalogue data when this is a preview of a found book.
  final BookInfo? info;

  /// A friendly message shown above the form (e.g. "not found").
  final String? notice;

  bool get isPreview => info != null;
}

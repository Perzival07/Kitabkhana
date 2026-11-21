import '../../../core/result.dart';
import 'tag.dart';

/// A tag with how many live books carry it.
final class TagWithCount {
  const TagWithCount(this.tag, this.books);

  final Tag tag;
  final int books;

  @override
  bool operator ==(Object other) =>
      other is TagWithCount && other.tag == tag && other.books == books;

  @override
  int get hashCode => Object.hash(tag, books);
}

abstract interface class TagRepository {
  /// Live tags ordered by name (ignoring case), each with its book count.
  Stream<List<TagWithCount>> watchWithCounts();

  /// Renames a tag. `ValidationFailure` for a blank name, `ConflictFailure`
  /// when another tag already has that name (ignoring case), `NotFoundFailure`
  /// when the tag is gone.
  Future<Result<Tag>> rename(String tagId, String name);

  /// Live tags ordered by name (ignoring case).
  Stream<List<Tag>> watchAll();

  /// Live tags attached to [bookId], ordered by name.
  Stream<List<Tag>> watchForBook(String bookId);

  /// Returns the existing tag with this name (ignoring case) or creates one.
  /// Fails with a ValidationFailure for a blank name.
  Future<Result<Tag>> createIfAbsent(String name);

  /// Attaches a tag to a book; a no-op if already attached.
  Future<Result<void>> attach(String bookId, String tagId);

  /// Removes a tag from a book; a no-op if not attached.
  Future<Result<void>> detach(String bookId, String tagId);

  /// Soft-deletes the tag and detaches it from every book.
  Future<Result<void>> softDelete(String tagId);
}

import '../../../core/copy_with.dart';
import '../../../core/entity.dart';

/// A passage saved from a book.
final class Quote extends Entity {
  const Quote({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
    required super.rev,
    required this.bookId,
    required this.body,
    this.page,
    this.isFavourite = false,
  });

  factory Quote.create({
    required String id,
    required String bookId,
    required String body,
    required DateTime now,
    int? page,
    bool isFavourite = false,
  }) => Quote(
    id: id,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    rev: 1,
    bookId: bookId,
    body: body,
    page: page,
    isFavourite: isFavourite,
  );

  final String bookId;
  final String body;
  final int? page;
  final bool isFavourite;

  Quote copyWith({
    String? body,
    Object? page = keep,
    bool? isFavourite,
    DateTime? updatedAt,
    Object? deletedAt = keep,
    int? rev,
  }) {
    return Quote(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: pick<DateTime>(deletedAt, this.deletedAt),
      rev: rev ?? this.rev,
      bookId: bookId,
      body: body ?? this.body,
      page: pick<int>(page, this.page),
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Quote &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt &&
      other.rev == rev &&
      other.bookId == bookId &&
      other.body == body &&
      other.page == page &&
      other.isFavourite == isFavourite;

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    bookId,
    body,
    page,
    isFavourite,
  );

  @override
  String toString() => 'Quote($id, $bookId)';
}

import '../../../core/copy_with.dart';
import '../../../core/entity.dart';

/// Pages read in one book on one calendar day.
final class ReadingLog extends Entity {
  const ReadingLog({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
    required super.rev,
    required this.bookId,
    required this.date,
    required this.pagesRead,
    required this.fromPage,
    required this.toPage,
  });

  factory ReadingLog.create({
    required String id,
    required String bookId,
    required DateTime date,
    required int fromPage,
    required int toPage,
    required DateTime now,
  }) => ReadingLog(
    id: id,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    rev: 1,
    bookId: bookId,
    date: date,
    pagesRead: toPage - fromPage,
    fromPage: fromPage,
    toPage: toPage,
  );

  final String bookId;

  /// Local calendar day (midnight).
  final DateTime date;
  final int pagesRead;
  final int fromPage;
  final int toPage;

  ReadingLog copyWith({
    int? pagesRead,
    int? fromPage,
    int? toPage,
    DateTime? updatedAt,
    Object? deletedAt = keep,
    int? rev,
  }) {
    return ReadingLog(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: pick<DateTime>(deletedAt, this.deletedAt),
      rev: rev ?? this.rev,
      bookId: bookId,
      date: date,
      pagesRead: pagesRead ?? this.pagesRead,
      fromPage: fromPage ?? this.fromPage,
      toPage: toPage ?? this.toPage,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReadingLog &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt &&
      other.rev == rev &&
      other.bookId == bookId &&
      other.date == date &&
      other.pagesRead == pagesRead &&
      other.fromPage == fromPage &&
      other.toPage == toPage;

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    bookId,
    date,
    pagesRead,
    fromPage,
    toPage,
  );

  @override
  String toString() => 'ReadingLog($bookId, $date, $pagesRead)';
}

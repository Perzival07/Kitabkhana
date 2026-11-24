import '../../../core/result.dart';

/// An earlier read of a book that has since been read again.
final class ReadThrough {
  const ReadThrough({
    required this.id,
    required this.bookId,
    this.startedOn,
    this.finishedOn,
  });

  final String id;
  final String bookId;
  final DateTime? startedOn;
  final DateTime? finishedOn;
}

abstract interface class ReadThroughRepository {
  /// Earlier reads of [bookId], most recent first.
  Stream<List<ReadThrough>> watchForBook(String bookId);

  Future<Result<void>> add(
    String bookId, {
    DateTime? startedOn,
    DateTime? finishedOn,
  });

  Future<Result<void>> softDelete(String id);
}

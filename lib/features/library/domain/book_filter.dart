import '../../../core/copy_with.dart';
import 'book_enums.dart';

/// How the library list is ordered.
enum BookSort { recentlyAdded, title, author, recentlyRead, rating }

/// Library filters. All set fields combine with AND.
final class BookFilter {
  const BookFilter({
    this.status,
    this.ownership,
    this.lentOut = false,
    this.borrowed = false,
    this.locationId,
    this.tagId,
    this.query = '',
  });

  final ReadStatus? status;
  final Ownership? ownership;

  /// Books with an active "lent" loan.
  final bool lentOut;

  /// Books marked borrowed or with an active "borrowed" loan.
  final bool borrowed;
  final String? locationId;
  final String? tagId;

  /// Full-text query over title, subtitle and authors.
  final String query;

  bool get isEmpty =>
      status == null &&
      ownership == null &&
      !lentOut &&
      !borrowed &&
      locationId == null &&
      tagId == null &&
      query.trim().isEmpty;

  BookFilter copyWith({
    Object? status = keep,
    Object? ownership = keep,
    bool? lentOut,
    bool? borrowed,
    Object? locationId = keep,
    Object? tagId = keep,
    String? query,
  }) {
    return BookFilter(
      status: pick<ReadStatus>(status, this.status),
      ownership: pick<Ownership>(ownership, this.ownership),
      lentOut: lentOut ?? this.lentOut,
      borrowed: borrowed ?? this.borrowed,
      locationId: pick<String>(locationId, this.locationId),
      tagId: pick<String>(tagId, this.tagId),
      query: query ?? this.query,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BookFilter &&
      other.status == status &&
      other.ownership == ownership &&
      other.lentOut == lentOut &&
      other.borrowed == borrowed &&
      other.locationId == locationId &&
      other.tagId == tagId &&
      other.query == query;

  @override
  int get hashCode => Object.hash(
    status,
    ownership,
    lentOut,
    borrowed,
    locationId,
    tagId,
    query,
  );
}

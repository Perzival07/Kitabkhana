import '../../../core/copy_with.dart';
import '../../../core/entity.dart';
import '../../../core/text/isbn.dart';
import '../../../core/text/title_key.dart';
import 'book_enums.dart';

/// A book in the library (owned, wishlisted or borrowed).
final class Book extends Entity {
  const Book({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
    required super.rev,
    required this.title,
    required this.titleKey,
    this.isbn13,
    this.olWorkKey,
    this.subtitle,
    this.authors = '',
    this.coverUrl,
    this.coverLocalPath,
    this.pages,
    this.genre = '',
    this.language = '',
    this.ownership = Ownership.owned,
    this.status = ReadStatus.want,
    this.currentPage = 0,
    this.rating,
    this.locationId,
    this.ownerName,
    this.notes,
    this.startedOn,
    this.finishedOn,
    this.series,
    this.seriesNumber,
  });

  /// A new, not-yet-saved book. [titleKey] is computed from title and authors.
  factory Book.create({
    required String id,
    required String title,
    required DateTime now,
    String authors = '',
    Isbn13? isbn13,
    String? olWorkKey,
    String? subtitle,
    String? coverUrl,
    int? pages,
    String genre = '',
    String language = '',
    Ownership ownership = Ownership.owned,
    ReadStatus status = ReadStatus.want,
    String? locationId,
    String? ownerName,
    String? notes,
    String? series,
    double? seriesNumber,
  }) {
    return Book(
      id: id,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      rev: 1,
      title: title,
      titleKey: normalizeTitle(title, authors),
      authors: authors,
      isbn13: isbn13,
      olWorkKey: olWorkKey,
      subtitle: subtitle,
      coverUrl: coverUrl,
      pages: pages,
      genre: genre,
      language: language,
      ownership: ownership,
      status: status,
      locationId: locationId,
      ownerName: ownerName,
      notes: notes,
      series: series,
      seriesNumber: seriesNumber,
    );
  }

  final Isbn13? isbn13;
  final String? olWorkKey;
  final String title;
  final String? subtitle;
  final String authors;
  final TitleKey titleKey;
  final String? coverUrl;
  final String? coverLocalPath;
  final int? pages;
  final String genre;
  final String language;
  final Ownership ownership;
  final ReadStatus status;
  final int currentPage;
  final int? rating;
  final String? locationId;
  final String? ownerName;
  final String? notes;
  final DateTime? startedOn;
  final DateTime? finishedOn;

  /// The series ("Discworld") and the book's place in it (2, or 2.5).
  final String? series;
  final double? seriesNumber;

  /// Reading progress 0..1, or null when the page count is unknown.
  double? get progress {
    final total = pages;
    if (total == null || total <= 0) return null;
    return (currentPage / total).clamp(0.0, 1.0);
  }

  Book copyWith({
    String? title,
    TitleKey? titleKey,
    String? authors,
    String? genre,
    String? language,
    Ownership? ownership,
    ReadStatus? status,
    int? currentPage,
    Object? isbn13 = keep,
    Object? olWorkKey = keep,
    Object? subtitle = keep,
    Object? coverUrl = keep,
    Object? coverLocalPath = keep,
    Object? pages = keep,
    Object? rating = keep,
    Object? locationId = keep,
    Object? ownerName = keep,
    Object? notes = keep,
    Object? startedOn = keep,
    Object? finishedOn = keep,
    Object? series = keep,
    Object? seriesNumber = keep,
    DateTime? updatedAt,
    Object? deletedAt = keep,
    int? rev,
  }) {
    final newTitle = title ?? this.title;
    final newAuthors = authors ?? this.authors;
    return Book(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: pick<DateTime>(deletedAt, this.deletedAt),
      rev: rev ?? this.rev,
      title: newTitle,
      // Changing the title or authors keeps the key in sync unless the
      // caller supplies one explicitly.
      titleKey:
          titleKey ??
          (title != null || authors != null
              ? normalizeTitle(newTitle, newAuthors)
              : this.titleKey),
      authors: newAuthors,
      genre: genre ?? this.genre,
      language: language ?? this.language,
      ownership: ownership ?? this.ownership,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      isbn13: pick<Isbn13>(isbn13, this.isbn13),
      olWorkKey: pick<String>(olWorkKey, this.olWorkKey),
      subtitle: pick<String>(subtitle, this.subtitle),
      coverUrl: pick<String>(coverUrl, this.coverUrl),
      coverLocalPath: pick<String>(coverLocalPath, this.coverLocalPath),
      pages: pick<int>(pages, this.pages),
      rating: pick<int>(rating, this.rating),
      locationId: pick<String>(locationId, this.locationId),
      ownerName: pick<String>(ownerName, this.ownerName),
      notes: pick<String>(notes, this.notes),
      startedOn: pick<DateTime>(startedOn, this.startedOn),
      finishedOn: pick<DateTime>(finishedOn, this.finishedOn),
      series: pick<String>(series, this.series),
      seriesNumber: pick<double>(seriesNumber, this.seriesNumber),
    );
  }

  List<Object?> get _props => <Object?>[
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    isbn13,
    olWorkKey,
    title,
    subtitle,
    authors,
    titleKey,
    coverUrl,
    coverLocalPath,
    pages,
    genre,
    language,
    ownership,
    status,
    currentPage,
    rating,
    locationId,
    ownerName,
    notes,
    startedOn,
    finishedOn,
    series,
    seriesNumber,
  ];

  @override
  bool operator ==(Object other) {
    if (other is! Book) return false;
    final a = _props;
    final b = other._props;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_props);

  @override
  String toString() => 'Book($id, $title)';
}

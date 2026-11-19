import 'package:drift/drift.dart';

import '../../../core/text/isbn.dart';
import '../../../core/text/title_key.dart';
import '../../../data/db/app_database.dart';
import '../domain/book.dart';

/// Converts between Drift rows and the domain [Book].
extension BookRowMapper on BookRow {
  Book toDomain() {
    final isbn = isbn13;
    return Book(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      rev: rev,
      isbn13: isbn == null ? null : parseIsbn(isbn),
      olWorkKey: olWorkKey,
      title: title,
      subtitle: subtitle,
      authors: authors,
      titleKey: TitleKey(titleKey),
      coverUrl: coverUrl,
      coverLocalPath: coverLocalPath,
      pages: pages,
      genre: genre,
      language: language,
      ownership: ownership,
      status: status,
      currentPage: currentPage,
      rating: rating,
      locationId: locationId,
      ownerName: ownerName,
      notes: notes,
      startedOn: startedOn,
      finishedOn: finishedOn,
    );
  }
}

/// All writable columns of [book]. `createdAt` is left absent on updates.
BooksCompanion bookToCompanion(
  Book book, {
  required DateTime updatedAt,
  required int rev,
  DateTime? createdAt,
}) {
  return BooksCompanion(
    id: Value(book.id),
    createdAt: createdAt == null ? const Value.absent() : Value(createdAt),
    updatedAt: Value(updatedAt),
    deletedAt: Value(book.deletedAt),
    rev: Value(rev),
    isbn13: Value(book.isbn13?.value),
    olWorkKey: Value(book.olWorkKey),
    title: Value(book.title),
    subtitle: Value(book.subtitle),
    authors: Value(book.authors),
    titleKey: Value(book.titleKey.value),
    coverUrl: Value(book.coverUrl),
    coverLocalPath: Value(book.coverLocalPath),
    pages: Value(book.pages),
    genre: Value(book.genre),
    language: Value(book.language),
    ownership: Value(book.ownership),
    status: Value(book.status),
    currentPage: Value(book.currentPage),
    rating: Value(book.rating),
    locationId: Value(book.locationId),
    ownerName: Value(book.ownerName),
    notes: Value(book.notes),
    startedOn: Value(book.startedOn),
    finishedOn: Value(book.finishedOn),
  );
}

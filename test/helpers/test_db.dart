import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:kitabkhana/data/db/app_database.dart';

/// An in-memory database for tests.
AppDatabase createTestDb() => AppDatabase(NativeDatabase.memory());

final DateTime t0 = DateTime.utc(2025, 1, 1, 12);

BooksCompanion bookCompanion({
  String id = 'b1',
  String title = 'Untitled',
  String authors = '',
  String? subtitle,
  String? isbn13,
  int? pages,
  int? rating,
  int currentPage = 0,
  String? locationId,
  DateTime? deletedAt,
}) {
  return BooksCompanion.insert(
    id: Value(id),
    title: title,
    titleKey: title.toLowerCase(),
    createdAt: t0,
    updatedAt: t0,
    authors: Value(authors),
    subtitle: Value(subtitle),
    isbn13: Value(isbn13),
    pages: Value(pages),
    rating: Value(rating),
    currentPage: Value(currentPage),
    locationId: Value(locationId),
    deletedAt: Value(deletedAt),
  );
}

LocationsCompanion locationCompanion({
  String id = 'l1',
  String name = 'Shelf',
  String? parentId,
  DateTime? deletedAt,
}) {
  return LocationsCompanion.insert(
    id: Value(id),
    name: name,
    createdAt: t0,
    updatedAt: t0,
    parentId: Value(parentId),
    deletedAt: Value(deletedAt),
  );
}

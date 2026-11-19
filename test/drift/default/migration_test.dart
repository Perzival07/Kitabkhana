import 'dart:typed_data';

import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/data/db/app_database.dart';

import '../../helpers/test_db.dart';
import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('a fresh database matches the exported current schema', () async {
    final connection = await verifier.startAt(2);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);
  });

  test('v1 migrates to v2 and the result matches the v2 schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);
  });

  test('v1 -> v2 keeps existing data and adds usable cover storage', () async {
    final schema = await verifier.schemaAt(1);
    final old = schema.newConnection();
    // Data written by a v1 app.
    final raw = schema.rawDatabase;
    raw.execute(
      "INSERT INTO books (id, created_at, updated_at, title, title_key, "
      "authors, genre, language, ownership, status, current_page, rev) VALUES "
      "('b1', '2025-01-01T00:00:00Z', '2025-01-01T00:00:00Z', 'Godan', "
      "'godan|premchand', 'Premchand', '', '', 'owned', 'want', 0, 1)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);

    final books = await db.select(db.books).get();
    expect(books.single.title, 'Godan');
    expect(books.single.authors, 'Premchand');

    // The new table works, and cascades when its book is purged.
    await db
        .into(db.coverBlobs)
        .insert(
          CoverBlobsCompanion.insert(
            bookId: 'b1',
            bytes: Uint8List.fromList(<int>[1, 2, 3]),
            updatedAt: DateTime.utc(2025),
          ),
        );
    expect(await db.select(db.coverBlobs).get(), hasLength(1));
    await (db.delete(db.books)..where((t) => t.id.equals('b1'))).go();
    expect(await db.select(db.coverBlobs).get(), isEmpty);
  });

  test('onCreate builds every table, trigger and index', () async {
    final db = createTestDb();
    addTearDown(db.close);
    final names =
        (await db.customSelect('SELECT name FROM sqlite_master').get())
            .map((r) => r.read<String>('name'))
            .toSet();
    for (final n in <String>[
      'books',
      'locations',
      'loans',
      'reading_logs',
      'quotes',
      'goals',
      'tags',
      'book_tags',
      'lookup_cache',
      'app_meta',
      'cover_blobs',
      'books_fts',
      'books_fts_ai',
      'books_fts_ad',
      'books_fts_au',
      'uq_loans_one_active_per_book',
      'idx_loans_due_open',
      'idx_books_isbn13',
    ]) {
      expect(names, contains(n));
    }
  });
}

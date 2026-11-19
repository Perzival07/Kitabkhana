import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kitabkhana/core/clock.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/image/cover_processor.dart';
import 'package:kitabkhana/data/db/app_database.dart';
import 'package:kitabkhana/platform/cover_store/web_cover_store.dart';

import '../helpers/test_db.dart';
import '../helpers/test_images.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late http.Response Function(http.Request) handler;

  WebCoverStore make() => WebCoverStore(
    client: MockClient((req) async => handler(req)),
    db: db,
    clock: clock,
    process: (b) async => processCover(b),
  );

  setUp(() async {
    db = createTestDb();
    clock = FakeClock(DateTime(2025, 3, 10, 9));
    handler = (_) => http.Response.bytes(jpegBytes(900, 1350), 200);
    await db.into(db.books).insert(bookCompanion(id: 'b1', title: 'One'));
  });
  tearDown(() => db.close());

  test('stores the processed JPEG in the database', () async {
    final ref = (await make().saveFromUrl(
      'b1',
      'https://x.test/c.jpg',
    )).getOrNull();
    expect(
      ref,
      'cover:b1?v=${DateTime(2025, 3, 10, 9).toUtc().millisecondsSinceEpoch}',
    );
    final row = await db.select(db.coverBlobs).getSingle();
    expect(row.bookId, 'b1');
    expect(row.bytes.sublist(0, 3), [0xFF, 0xD8, 0xFF]);
    expect(row.bytes.length, lessThan(jpegBytes(900, 1350).length));
  });

  test('saving again replaces the image (one row per book)', () async {
    final store = make();
    await store.saveFromBytes('b1', jpegBytes(500, 750));
    final first = (await db.select(db.coverBlobs).getSingle()).bytes;
    clock.advance(const Duration(hours: 1));
    await store.saveFromBytes('b1', jpegBytes(300, 300));
    final rows = await db.select(db.coverBlobs).get();
    expect(rows, hasLength(1));
    expect(rows.single.bytes, isNot(first));
    expect(rows.single.updatedAt.toUtc(), clock.now().toUtc());
  });

  test('placeholders, 404s and junk mean no cover and store nothing', () async {
    handler = (_) => http.Response.bytes(placeholderGif(), 200);
    expect(
      (await make().saveFromUrl('b1', 'https://x.test/c.jpg')).getOrNull(),
      isNull,
    );
    handler = (_) => http.Response('nope', 404);
    expect(
      (await make().saveFromUrl('b1', 'https://x.test/c.jpg')).getOrNull(),
      isNull,
    );
    expect(await db.select(db.coverBlobs).get(), isEmpty);
  });

  test('network failures are reported', () async {
    handler = (_) => http.Response('boom', 500);
    expect(
      (await make().saveFromUrl('b1', 'https://x.test/c.jpg')).failureOrNull(),
      const NetworkFailure.server(500),
    );
  });

  test('a cover for a book that does not exist is a StorageFailure', () async {
    final r = await make().saveFromBytes('ghost', jpegBytes(400, 600));
    expect(r.failureOrNull(), isA<StorageFailure>());
    expect(await db.select(db.coverBlobs).get(), isEmpty);
  });

  test('readBytes and imageFor resolve references', () async {
    final store = make();
    await store.saveFromBytes('b1', jpegBytes(400, 600));
    final ref = (await store.saveFromBytes(
      'b1',
      jpegBytes(400, 600),
    )).getOrNull()!;
    expect(await store.readBytes(ref), isNotNull);
    expect(await store.imageFor(ref), isA<MemoryImage>());
    expect(await store.readBytes('cover:b1'), isNotNull); // unversioned form
    expect(await store.readBytes('cover:nope'), isNull);
    for (final bad in <String>['covers/b1.jpg', 'cover:../x', '', 'b1']) {
      expect(await store.readBytes(bad), isNull, reason: bad);
      expect(await store.imageFor(bad), isNull, reason: bad);
    }
  });

  test('delete removes the blob; purging the book cascades', () async {
    final store = make();
    await store.saveFromBytes('b1', jpegBytes(400, 600));
    await store.delete('b1');
    expect(await db.select(db.coverBlobs).get(), isEmpty);
    await store.delete('b1'); // no-op

    await store.saveFromBytes('b1', jpegBytes(400, 600));
    await (db.delete(db.books)..where((t) => t.id.equals('b1'))).go();
    expect(await db.select(db.coverBlobs).get(), isEmpty);
  });

  test('rejects unsafe ids and bad photos', () async {
    final store = make();
    expect(
      (await store.saveFromBytes('../x', jpegBytes(400, 600))).failureOrNull(),
      isA<ValidationFailure>(),
    );
    expect(
      (await store.saveFromBytes(
        'b1',
        Uint8List.fromList([1, 2]),
      )).failureOrNull(),
      isA<ValidationFailure>(),
    );
    expect(
      (await store.saveFromUrl('a b', 'https://x.test/c.jpg')).failureOrNull(),
      isA<ValidationFailure>(),
    );
  });
}

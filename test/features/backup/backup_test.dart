import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/features/backup/application/backup_codec.dart';
import 'package:kitabkhana/features/backup/application/export_backup.dart';
import 'package:kitabkhana/features/backup/application/import_backup.dart';
import 'package:kitabkhana/features/backup/data/backup_store.dart';
import 'package:kitabkhana/features/backup/domain/backup_format.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/quotes/domain/quote.dart';

import '../../helpers/fake_cover_store.dart';
import '../../helpers/repo_harness.dart';

class _Safety implements SafetyBackup {
  _Safety({this.fail = false});
  final bool fail;
  int calls = 0;

  @override
  Future<Result<void>> create() async {
    calls++;
    return fail ? const Err<void>(StorageFailure()) : const Ok<void>(null);
  }
}

/// A library with a bit of everything, including tombstones.
Future<void> seed(RepoHarness h, FakeCoverStore covers) async {
  final shelf = await h.addLocation(name: 'Living room');
  final top = await h.addLocation(name: 'Top shelf', parentId: shelf.id);
  final dune = await h.addBook(
    id: 'dune',
    title: 'Dune',
    authors: 'Frank Herbert, Brian Herbert',
    pages: 612,
    status: ReadStatus.finished,
    locationId: top.id,
    rating: 5,
    tweak: (b) => b.copyWith(
      genre: 'Sci-fi',
      startedOn: DateTime(2025, 1, 2),
      finishedOn: DateTime(2025, 2, 1),
      coverLocalPath: 'covers/dune.jpg?v=9',
      notes: 'Spice — नमस्ते — নমস্কার',
    ),
  );
  covers.files['covers/dune.jpg?v=9'] = Uint8List.fromList(<int>[1, 2, 3, 4]);
  final emma = await h.addBook(id: 'emma', title: 'Emma', pages: 474);
  final gone = await h.addBook(id: 'gone', title: 'Deleted book');
  await h.books.softDelete(gone.id);

  await h.addLoan(bookId: emma.id, dueOn: DateTime(2025, 4, 1));
  await h.addLoan(bookId: dune.id, direction: LoanDirection.borrowed);
  await h.loans.finishLoan('ln2', DateTime(2025, 3, 5));
  await h.addLog(bookId: dune.id, date: DateTime(2025, 1, 5), to: 40);
  await h.addLog(bookId: dune.id, date: DateTime(2025, 1, 6), from: 40, to: 90);
  await h.quotes.upsert(
    Quote.create(
      id: 'q1',
      bookId: dune.id,
      body: 'Fear is the mind-killer.',
      page: 7,
      isFavourite: true,
      now: h.clock.now(),
    ),
  );
  final q2 = (await h.quotes.upsert(
    Quote.create(
      id: 'q2',
      bookId: dune.id,
      body: 'Deleted quote',
      now: h.clock.now(),
    ),
  )).getOrNull()!;
  await h.quotes.softDelete(q2.id);
  await h.goals.setTarget(2025, 24);
  final tag = (await h.tags.createIfAbsent('Favourites')).getOrNull()!;
  await h.tags.attach(dune.id, tag.id);
}

void main() {
  late RepoHarness a;
  late RepoHarness b;
  late FakeCoverStore coversA;
  late FakeCoverStore coversB;
  late BackupStore storeA;
  late BackupStore storeB;
  late _Safety safety;

  ExportBackup exporter() => ExportBackup(
    store: storeA,
    covers: coversA,
    clock: a.clock,
    appVersion: '1.0.0',
  );

  ImportBackup importer({SafetyBackup? safe, Future<void> Function()? after}) =>
      ImportBackup(
        store: storeB,
        covers: coversB,
        safety: safe ?? safety,
        afterImport: after,
      );

  setUp(() {
    a = RepoHarness();
    b = RepoHarness();
    coversA = FakeCoverStore();
    coversB = FakeCoverStore();
    storeA = BackupStore(a.db);
    storeB = BackupStore(b.db);
    safety = _Safety();
  });

  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  /// Everything but cover references, which are re-made on import.
  Map<String, List<Row>> withoutCovers(Map<String, List<Row>> t) => {
    for (final e in t.entries)
      e.key: [
        for (final r in e.value)
          e.key == 'books'
              ? <String, dynamic>{...r, 'coverLocalPath': null}
              : r,
      ],
  };

  Future<BackupContents> exported() async {
    final file = (await exporter()()).getOrNull()!;
    return (await importer().open(file.bytes)).getOrNull()!;
  }

  group('export', () {
    test('writes every row, tombstones included, with checksums', () async {
      await seed(a, coversA);
      final file = (await exporter()()).getOrNull()!;
      expect(file.name, 'kitabkhana-2025-03-10.kitab');
      final c = (await importer().open(file.bytes)).getOrNull()!;
      final m = c.manifest;
      expect(m.formatVersion, backupFormatVersion);
      expect(m.schemaVersion, a.db.schemaVersion);
      expect(m.deviceId, isNotEmpty);
      expect(m.counts['books'], 3);
      expect(m.counts['quotes'], 2);
      expect(m.counts['loans'], 2);
      expect(m.counts['reading_logs'], 2);
      expect(m.counts['locations'], 2);
      expect(m.counts['book_tags'], 1);
      expect(m.files.keys, contains('covers/dune.jpg'));
      expect(c.covers['dune'], [1, 2, 3, 4]);
      expect(
        c.tables['books']!.where((r) => r['deletedAt'] != null),
        hasLength(1),
      );
    });

    test('the device id is stable', () async {
      final one = await storeA.deviceId();
      expect(await storeA.deviceId(), one);
      expect(await storeB.deviceId(), isNot(one));
    });

    test('a cover that cannot be read is left out, not fatal', () async {
      await seed(a, coversA);
      coversA.files.clear();
      final c = await exported();
      expect(c.covers, isEmpty);
    });
  });

  group('round trip', () {
    test('export, import (replace) into an empty library: identical', () async {
      await seed(a, coversA);
      final original = await storeA.readAll();
      final contents = await exported();
      final r = await importer()(contents, ImportMode.replace);
      expect(r.isOk, isTrue);
      expect(withoutCovers(await storeB.readAll()), withoutCovers(original));
      expect(safety.calls, 1, reason: 'a safety backup is always made first');
    });

    test('summary counts live rows', () async {
      await seed(a, coversA);
      final r = (await importer()(
        await exported(),
        ImportMode.replace,
      )).getOrNull()!;
      expect(r.books, 2);
      expect(r.loans, 2);
      expect(r.quotes, 1);
      expect(r.readingLogs, 2);
    });

    test('replace wipes what was there', () async {
      await seed(a, coversA);
      await b.addBook(id: 'old', title: 'Old book');
      await b.addLocation(id: 'old-loc', name: 'Old shelf');
      await importer()(await exported(), ImportMode.replace);
      final books = (await storeB.readAll())['books']!;
      expect(books.map((r) => r['id']), isNot(contains('old')));
      expect(
        (await storeB.readAll())['locations']!.map((r) => r['id']),
        isNot(contains('old-loc')),
      );
      expect(coversB.deletes, contains('old'));
    });

    test('foreign-key order inside the file does not matter', () async {
      await seed(a, coversA);
      final contents = await exported();
      final shuffled = <String, List<Row>>{
        for (final e in contents.tables.entries)
          e.key: e.value.reversed.toList(),
      };
      final r = await importer()(
        BackupContents(
          manifest: contents.manifest,
          tables: shuffled,
          covers: contents.covers,
        ),
        ImportMode.replace,
      );
      expect(r.isOk, isTrue);
      expect(
        withoutCovers(await storeB.readAll()),
        withoutCovers(await storeA.readAll()),
      );
    });

    test('covers are stored again and the books pointed at them', () async {
      await seed(a, coversA);
      await importer()(await exported(), ImportMode.replace);
      expect(coversB.saved['dune'], [1, 2, 3, 4]);
      final dune = (await b.books.getById('dune')).getOrNull()!;
      expect(dune.coverLocalPath, 'covers/dune.jpg?v=2');
    });

    test(
      'a book whose cover file is missing loses the stale reference',
      () async {
        await seed(a, coversA);
        coversA.files.clear();
        await importer()(await exported(), ImportMode.replace);
        expect(
          (await b.books.getById('dune')).getOrNull()!.coverLocalPath,
          isNull,
        );
      },
    );

    test('a cover that fails to copy is counted, the rest stands', () async {
      await seed(a, coversA);
      coversB.failPhotoFor.add('dune');
      final r = (await importer()(
        await exported(),
        ImportMode.replace,
      )).getOrNull()!;
      expect(r.coversSkipped, 1);
      expect(r.books, 2);
    });

    test('the after-import step runs (reminder reconciliation)', () async {
      await seed(a, coversA);
      var ran = 0;
      await importer(after: () async => ran++)(
        await exported(),
        ImportMode.replace,
      );
      expect(ran, 1);
    });

    test('a failing after-import step does not fail the import', () async {
      await seed(a, coversA);
      final r = await importer(after: () async => throw StateError('x'))(
        await exported(),
        ImportMode.replace,
      );
      expect(r.isOk, isTrue);
    });
  });

  group('safety and rollback', () {
    test('no safety backup, no import', () async {
      await seed(a, coversA);
      await b.addBook(id: 'keep', title: 'Keep me');
      final r = await importer(safe: _Safety(fail: true))(
        await exported(),
        ImportMode.replace,
      );
      expect(r, isA<Err<ImportSummary>>());
      expect((await storeB.readAll())['books']!.map((x) => x['id']), ['keep']);
    });

    test('a broken row rolls everything back', () async {
      await seed(a, coversA);
      await b.addBook(id: 'keep', title: 'Keep me');
      final before = await storeB.readAll();
      final c = await exported();
      // A quote for a book that is not in the file: fails at commit.
      final bad = <String, List<Row>>{
        for (final e in c.tables.entries) e.key: List<Row>.of(e.value),
      };
      bad['quotes']!.add(<String, dynamic>{
        ...bad['quotes']!.first,
        'id': 'orphan',
        'bookId': 'nope',
      });
      final r = await importer()(
        BackupContents(manifest: c.manifest, tables: bad, covers: c.covers),
        ImportMode.replace,
      );
      expect(r, isA<Err<ImportSummary>>());
      expect((r as Err).failure, isA<BackupFailure>());
      expect(await storeB.readAll(), before);
    });

    test('a broken row rolls a merge back too', () async {
      await seed(a, coversA);
      await b.addBook(id: 'keep', title: 'Keep me');
      final before = await storeB.readAll();
      final c = await exported();
      final bad = <String, List<Row>>{
        for (final e in c.tables.entries) e.key: List<Row>.of(e.value),
      };
      bad['quotes']!.add(<String, dynamic>{
        ...bad['quotes']!.first,
        'id': 'orphan',
        'bookId': 'nope',
      });
      final r = await importer()(
        BackupContents(manifest: c.manifest, tables: bad, covers: c.covers),
        ImportMode.merge,
      );
      expect(r.isOk, isFalse);
      expect(await storeB.readAll(), before);
    });
  });

  group('merge', () {
    Future<BackupContents> withRows(
      Map<String, List<Row>> tables, {
      int schema = 2,
    }) async {
      final bytes = encodeBackupArchive(
        BackupArchiveInput(
          appVersion: '1.0.0',
          schemaVersion: schema,
          deviceId: 'dev',
          exportedAt: DateTime.utc(2025, 3, 10),
          tables: tables,
          covers: const <String, Uint8List>{},
        ),
      );
      return decodeBackupArchive(BackupDecodeInput(bytes, 99));
    }

    Future<Row> rowOf(RepoHarness h, String table, String id) async =>
        (await BackupStore(
          h.db,
        ).readAll())[table]!.firstWhere((r) => r['id'] == id);

    test('rows only in the backup are added, local-only rows stay', () async {
      await seed(a, coversA);
      await b.addBook(id: 'local', title: 'Local only');
      final r = await importer()(await exported(), ImportMode.merge);
      expect(r.isOk, isTrue);
      final ids = (await storeB.readAll())['books']!.map((x) => x['id']);
      expect(ids, containsAll(<String>['dune', 'emma', 'gone', 'local']));
    });

    test('newer updatedAt wins, in both directions', () async {
      await a.addBook(id: 'x', title: 'From A');
      await b.addBook(id: 'x', title: 'From B');
      final rowA = await rowOf(a, 'books', 'x');
      final rowB = await rowOf(b, 'books', 'x');

      // Backup older: local stays.
      final older = <String, dynamic>{
        ...rowA,
        'updatedAt': (rowB['updatedAt'] as int) - 1000,
      };
      await importer()(
        await withRows(<String, List<Row>>{
          'books': [older],
        }),
        ImportMode.merge,
      );
      expect((await rowOf(b, 'books', 'x'))['title'], 'From B');

      // Backup newer: backup wins.
      final newer = <String, dynamic>{
        ...rowA,
        'updatedAt': (rowB['updatedAt'] as int) + 1000,
      };
      final r = await importer()(
        await withRows(<String, List<Row>>{
          'books': [newer],
        }),
        ImportMode.merge,
      );
      expect((await rowOf(b, 'books', 'x'))['title'], 'From A');
      expect(r.getOrNull()!.books, 1);
    });

    test('equal time: higher rev wins; full tie keeps local', () async {
      await a.addBook(id: 'x', title: 'From A');
      await b.addBook(id: 'x', title: 'From B');
      final rowB = await rowOf(b, 'books', 'x');
      final tie = <String, dynamic>{
        ...await rowOf(a, 'books', 'x'),
        'updatedAt': rowB['updatedAt'],
        'rev': rowB['rev'],
      };
      await importer()(
        await withRows(<String, List<Row>>{
          'books': [tie],
        }),
        ImportMode.merge,
      );
      expect((await rowOf(b, 'books', 'x'))['title'], 'From B');
      await importer()(
        await withRows(<String, List<Row>>{
          'books': [
            <String, dynamic>{...tie, 'rev': (rowB['rev'] as int) + 1},
          ],
        }),
        ImportMode.merge,
      );
      expect((await rowOf(b, 'books', 'x'))['title'], 'From A');
    });

    test('tombstones are respected', () async {
      await a.addBook(id: 'x', title: 'Same');
      await b.addBook(id: 'x', title: 'Same');
      final live = await rowOf(b, 'books', 'x');
      final t = live['updatedAt'] as int;

      // A newer tombstone deletes the local copy.
      await importer()(
        await withRows(<String, List<Row>>{
          'books': [
            <String, dynamic>{...live, 'updatedAt': t + 5, 'deletedAt': t + 5},
          ],
        }),
        ImportMode.merge,
      );
      expect((await rowOf(b, 'books', 'x'))['deletedAt'], t + 5);

      // An older live row does not bring it back.
      await importer()(
        await withRows(<String, List<Row>>{
          'books': [
            <String, dynamic>{...live, 'updatedAt': t + 1},
          ],
        }),
        ImportMode.merge,
      );
      expect((await rowOf(b, 'books', 'x'))['deletedAt'], t + 5);
    });

    test(
      'merging the same backup twice changes nothing the second time',
      () async {
        await seed(a, coversA);
        await importer()(await exported(), ImportMode.merge);
        final once = await storeB.readAll();
        final r = await importer()(await exported(), ImportMode.merge);
        expect(await storeB.readAll(), once);
        expect(r.getOrNull()!.books, 0, reason: 'nothing was newer');
      },
    );

    test(
      'same tag name under a different id is folded, books redirected',
      () async {
        final bookA = await a.addBook(id: 'ba', title: 'A');
        final tagA = (await a.tags.createIfAbsent('Favourites')).getOrNull()!;
        await a.tags.attach(bookA.id, tagA.id);
        final tagB = (await b.tags.createIfAbsent('favourites')).getOrNull()!;
        expect(tagA.id, isNot(tagB.id));

        final r = await importer()(await exported2(a), ImportMode.merge);
        expect(r.isOk, isTrue);
        final tags = (await storeB.readAll())['tags']!;
        expect(tags.where((t) => t['deletedAt'] == null), hasLength(1));
        final links = (await storeB.readAll())['book_tags']!;
        expect(links.single['tagId'], tagB.id);
      },
    );

    test('same location name and parent is folded; children follow', () async {
      final parentA = await a.addLocation(id: 'pa', name: 'Study');
      await a.addLocation(id: 'ca', name: 'Desk', parentId: parentA.id);
      await a.addBook(id: 'ba', title: 'A', locationId: 'ca');
      final parentB = await b.addLocation(id: 'pb', name: 'study');

      await importer()(await exported2(a), ImportMode.merge);
      final locs = (await storeB.readAll())['locations']!;
      final live = locs.where((l) => l['deletedAt'] == null).toList();
      expect(
        live.map((l) => l['name']),
        unorderedEquals(<String>['study', 'Desk']),
      );
      expect(
        live.firstWhere((l) => l['name'] == 'Desk')['parentId'],
        parentB.id,
      );
      expect((await rowOf(b, 'books', 'ba'))['locationId'], 'ca');
    });

    test('one goal per year: the newer target wins, no duplicate', () async {
      await a.goals.setTarget(2025, 30);
      b.tick(const Duration(days: -5)); // B's goal is older
      await b.goals.setTarget(2025, 12);
      b.tick(const Duration(days: 5));
      await importer()(await exported2(a), ImportMode.merge);
      final goals = (await storeB.readAll())['goals']!
          .where((g) => g['deletedAt'] == null)
          .toList();
      expect(goals, hasLength(1));
      expect(goals.single['targetBooks'], 30);
    });

    test('a second active loan for one book is not imported', () async {
      await a.addBook(id: 'bk', title: 'Shared');
      await b.addBook(id: 'bk', title: 'Shared');
      await a.addLoan(bookId: 'bk', id: 'loan-a');
      await b.addLoan(bookId: 'bk', id: 'loan-b');
      final r = await importer()(await exported2(a), ImportMode.merge);
      expect(r.isOk, isTrue);
      final active = (await storeB.readAll())['loans']!.where(
        (l) => l['returnedOn'] == null && l['deletedAt'] == null,
      );
      expect(active.map((l) => l['id']), ['loan-b']);
    });

    test('a repeated tag on a book is not duplicated', () async {
      await a.addBook(id: 'bk', title: 'Shared');
      await b.addBook(id: 'bk', title: 'Shared');
      final tagA = (await a.tags.createIfAbsent('Sci-fi')).getOrNull()!;
      await a.tags.attach('bk', tagA.id);
      final tagB = (await b.tags.createIfAbsent('Sci-fi')).getOrNull()!;
      await b.tags.attach('bk', tagB.id);
      await importer()(await exported2(a), ImportMode.merge);
      final live = (await storeB.readAll())['book_tags']!.where(
        (l) => l['deletedAt'] == null,
      );
      expect(live, hasLength(1));
    });
  });

  group('refusing bad files', () {
    Future<BackupFailure> failure(Uint8List bytes) async {
      final r = await importer().open(bytes);
      return (r as Err<BackupContents>).failure as BackupFailure;
    }

    Uint8List zipWith(
      void Function(Archive archive, BackupManifest manifest) edit, {
      BackupManifest Function(BackupManifest m)? manifestEdit,
    }) {
      final good = decodeBackupArchive(
        BackupDecodeInput(
          encodeBackupArchive(
            BackupArchiveInput(
              appVersion: '1.0.0',
              schemaVersion: 2,
              deviceId: 'd',
              exportedAt: DateTime.utc(2025, 3, 10),
              tables: <String, List<Row>>{
                'books': [
                  <String, dynamic>{'id': 'x'},
                ],
              },
              covers: const <String, Uint8List>{},
            ),
          ),
          99,
        ),
      );
      final archive = Archive();
      edit(archive, good.manifest);
      return ZipEncoder().encodeBytes(archive);
    }

    Uint8List rebuild(
      Map<String, List<int>> files, {
      Map<String, Object?> Function(Map<String, Object?>)? tweak,
    }) {
      final hashes = <String, String>{
        for (final e in files.entries)
          e.key: sha256.convert(e.value).toString(),
      };
      final manifest = <String, Object?>{
        'formatVersion': 1,
        'appVersion': '1.0.0',
        'schemaVersion': 2,
        'deviceId': 'd',
        'exportedAt': '2025-03-10T00:00:00.000Z',
        'counts': <String, int>{
          for (final n in backupTableNames) n: n == 'books' ? 1 : 0,
        },
        'files': hashes,
      };
      final m = tweak == null ? manifest : tweak(manifest);
      final archive = Archive()
        ..addFile(
          ArchiveFile.bytes('manifest.json', utf8.encode(jsonEncode(m))),
        );
      for (final e in files.entries) {
        archive.addFile(ArchiveFile.bytes(e.key, e.value));
      }
      return ZipEncoder().encodeBytes(archive);
    }

    Map<String, List<int>> goodFiles() => <String, List<int>>{
      for (final n in backupTableNames)
        dataFilePath(n): utf8.encode(n == 'books' ? '[{"id":"x"}]' : '[]'),
    };

    test('not a zip at all', () async {
      expect(
        (await failure(Uint8List.fromList(utf8.encode('hello world')))).problem,
        BackupProblem.notABackup,
      );
      expect((await failure(Uint8List(0))).problem, BackupProblem.notABackup);
    });

    test('a zip without a manifest', () async {
      final bytes = zipWith(
        (a, m) => a.addFile(ArchiveFile.string('x.txt', 'hi')),
      );
      expect((await failure(bytes)).problem, BackupProblem.notABackup);
    });

    test('a manifest that is not valid', () async {
      final archive = Archive()
        ..addFile(
          ArchiveFile.string('manifest.json', '{"formatVersion": "one"}'),
        );
      expect(
        (await failure(ZipEncoder().encodeBytes(archive))).problem,
        BackupProblem.notABackup,
      );
    });

    test('a good file opens', () async {
      expect((await importer().open(rebuild(goodFiles()))).isOk, isTrue);
    });

    test('a newer format asks for an app update', () async {
      final bytes = rebuild(
        goodFiles(),
        tweak: (m) => {...m, 'formatVersion': 2},
      );
      expect((await failure(bytes)).problem, BackupProblem.newerVersion);
    });

    test('a newer schema asks for an app update', () async {
      final bytes = rebuild(
        goodFiles(),
        tweak: (m) => {...m, 'schemaVersion': 99},
      );
      expect((await failure(bytes)).problem, BackupProblem.newerVersion);
    });

    test('a wrong checksum is damage', () async {
      final bytes = rebuild(
        goodFiles(),
        tweak: (m) => {
          ...m,
          'files': <String, String>{
            ...(m['files'] as Map<String, String>),
            dataFilePath('books'): 'deadbeef',
          },
        },
      );
      final f = await failure(bytes);
      expect(f.problem, BackupProblem.damaged);
      expect(f.detail, contains('checksum'));
    });

    test('a file changed after export is caught', () async {
      final files = goodFiles();
      final good = rebuild(files);
      // Rewrite books.json inside the zip but keep the old manifest.
      final archive = ZipDecoder().decodeBytes(good);
      final out = Archive();
      for (final f in archive.files) {
        out.addFile(
          f.name == dataFilePath('books')
              ? ArchiveFile.string(f.name, '[{"id":"hacked"}]')
              : ArchiveFile.bytes(f.name, f.content),
        );
      }
      expect(
        (await failure(ZipEncoder().encodeBytes(out))).problem,
        BackupProblem.damaged,
      );
    });

    test('a listed file that is missing is damage', () async {
      final files = goodFiles();
      final bytes = rebuild(files);
      final archive = ZipDecoder().decodeBytes(bytes);
      final out = Archive();
      for (final f in archive.files) {
        if (f.name == dataFilePath('quotes')) continue;
        out.addFile(ArchiveFile.bytes(f.name, f.content));
      }
      expect(
        (await failure(ZipEncoder().encodeBytes(out))).problem,
        BackupProblem.damaged,
      );
    });

    test('an unlisted extra file is damage', () async {
      final bytes = rebuild(goodFiles());
      final archive = ZipDecoder().decodeBytes(bytes)
        ..addFile(ArchiveFile.string('evil.txt', 'x'));
      expect(
        (await failure(ZipEncoder().encodeBytes(archive))).problem,
        BackupProblem.damaged,
      );
    });

    test(
      'a data file that is not JSON, or whose count lies, is damage',
      () async {
        final files = goodFiles()
          ..[dataFilePath('books')] = utf8.encode('{nope');
        expect((await failure(rebuild(files))).problem, BackupProblem.damaged);

        final lying = goodFiles()
          ..[dataFilePath('books')] = utf8.encode('[{"id":"x"},{"id":"y"}]');
        expect((await failure(rebuild(lying))).problem, BackupProblem.damaged);
      },
    );

    test('a failed open changes nothing', () async {
      await b.addBook(id: 'keep', title: 'Keep');
      await importer().open(Uint8List.fromList(<int>[1, 2, 3]));
      expect((await storeB.readAll())['books'], hasLength(1));
    });
  });
}

/// Exports [h]'s library (with default settings) and opens it.
Future<BackupContents> exported2(RepoHarness h) async {
  final file = (await ExportBackup(
    store: BackupStore(h.db),
    covers: FakeCoverStore(),
    clock: h.clock,
    appVersion: '1.0.0',
  )()).getOrNull()!;
  return decodeBackupArchive(BackupDecodeInput(file.bytes, 99));
}

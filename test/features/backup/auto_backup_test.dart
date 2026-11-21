import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/features/backup/application/auto_backup.dart';
import 'package:kitabkhana/features/backup/application/erase_all_data.dart';
import 'package:kitabkhana/features/backup/application/export_backup.dart';
import 'package:kitabkhana/features/backup/data/backup_prefs_store.dart';
import 'package:kitabkhana/features/backup/data/backup_store.dart';
import 'package:kitabkhana/features/settings/data/drift_settings_repository.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';

import '../../helpers/fake_backup_folder.dart';
import '../../helpers/fake_cover_store.dart';
import '../../helpers/fake_notification_scheduler.dart';
import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;
  late BackupStore store;
  late FakeBackupFolder folder;
  late DbBackupPrefs prefs;
  late FakeCoverStore covers;
  late AutoBackup auto;

  AutoBackup make({BackupFolder? f}) => AutoBackup(
    export: ExportBackup(
      store: store,
      covers: covers,
      clock: h.clock,
      appVersion: '1.0.0',
    ),
    store: store,
    folder: f ?? folder,
    prefs: prefs,
    clock: h.clock,
  );

  setUp(() async {
    h = RepoHarness();
    store = BackupStore(h.db);
    folder = FakeBackupFolder();
    prefs = DbBackupPrefs(h.db);
    covers = FakeCoverStore();
    auto = make();
    await h.addBook(title: 'Dune');
  });

  tearDown(() => h.db.close());

  test('names sort by time', () {
    final a = autoBackupName(DateTime(2025, 3, 9, 23, 59, 59));
    final b = autoBackupName(DateTime(2025, 3, 10, 0, 0, 1));
    expect(a, 'auto-20250309-235959.kitab');
    expect(a.compareTo(b), lessThan(0));
  });

  group('schedule', () {
    test('the first run backs up and remembers when', () async {
      expect(await prefs.lastBackupAt(), isNull);
      expect(await auto.runIfDue(), isTrue);
      expect(folder.files, hasLength(1));
      expect(await prefs.lastBackupAt(), h.clock.now());
    });

    test('not again before 7 days, again from 7 days', () async {
      await auto.runIfDue();
      h.clock.advance(const Duration(days: 6, hours: 23));
      expect(await auto.runIfDue(), isFalse);
      expect(folder.files, hasLength(1));
      h.clock.advance(const Duration(hours: 1));
      expect(await auto.runIfDue(), isTrue);
      expect(folder.files, hasLength(2));
    });

    test('off means off', () async {
      await prefs.setAutoEnabled(enabled: false);
      expect(await prefs.autoEnabled(), isFalse);
      expect(await auto.runIfDue(), isFalse);
      expect(folder.files, isEmpty);
      await prefs.setAutoEnabled(enabled: true);
      expect(await auto.runIfDue(), isTrue);
    });

    test('on by default', () async {
      expect(await prefs.autoEnabled(), isTrue);
    });

    test('an empty library is not worth a file', () async {
      final fresh = RepoHarness();
      addTearDown(fresh.db.close);
      final a = AutoBackup(
        export: ExportBackup(
          store: BackupStore(fresh.db),
          covers: covers,
          clock: fresh.clock,
          appVersion: '1.0.0',
        ),
        store: BackupStore(fresh.db),
        folder: folder,
        prefs: DbBackupPrefs(fresh.db),
        clock: fresh.clock,
      );
      expect(await a.runIfDue(), isFalse);
      expect(folder.files, isEmpty);
    });

    test('platforms without a folder do nothing, and say so', () async {
      final none = make(f: const NoBackupFolder());
      expect(await none.runIfDue(), isFalse);
      final r = await none.backUpNow();
      expect((r as Err).failure, isA<UnsupportedOnPlatformFailure>());
    });

    test('a failed write is reported and the schedule is untouched', () async {
      folder.failWrites = true;
      expect(await auto.runIfDue(), isFalse);
      expect(await prefs.lastBackupAt(), isNull);
      expect((await auto.backUpNow()).isOk, isFalse);
    });

    test('a corrupt time setting is treated as never', () async {
      await h.db.customStatement(
        "INSERT INTO app_meta (key, value) VALUES ('backup.last_at', 'junk')",
      );
      expect(await prefs.lastBackupAt(), isNull);
      expect(await auto.runIfDue(), isTrue);
    });
  });

  group('rotation', () {
    test('keeps the newest three automatic backups', () async {
      final made = <String>[];
      for (var i = 0; i < 5; i++) {
        h.clock.advance(const Duration(days: 8));
        final r = await auto.backUpNow();
        made.add(r.getOrNull()!);
      }
      expect(folder.files.keys.toList()..sort(), made.skip(2).toList());
      expect(folder.files, hasLength(autoBackupKeep));
    });

    test('other files in the folder are left alone', () async {
      folder.files['before-restore-kitabkhana-2025-01-01.kitab'] =
          folder.files['x'] ?? Uint8List(0);
      folder.files['notes.txt'] = Uint8List(0);
      for (var i = 0; i < 5; i++) {
        h.clock.advance(const Duration(days: 8));
        await auto.backUpNow();
      }
      expect(folder.files.keys, contains('notes.txt'));
      expect(
        folder.files.keys,
        contains('before-restore-kitabkhana-2025-01-01.kitab'),
      );
      expect(
        folder.files.keys.where((n) => n.startsWith('auto-')),
        hasLength(3),
      );
    });

    test('a backup is a valid .kitab', () async {
      await auto.backUpNow();
      final bytes = folder.files.values.single;
      expect(bytes.sublist(0, 2), [0x50, 0x4B], reason: 'zip header');
    });
  });

  group('erase all data', () {
    late FakeNotificationScheduler scheduler;
    late EraseAllData erase;

    setUp(() {
      scheduler = FakeNotificationScheduler();
      erase = EraseAllData(
        db: h.db,
        store: store,
        covers: covers,
        folder: folder,
        notifications: scheduler,
      );
    });

    Future<int> count(String table) async =>
        (await h.db
                .customSelect('SELECT COUNT(*) AS c FROM $table')
                .getSingle())
            .read<int>('c');

    test('the confirmation word is exact', () {
      expect(isEraseConfirmed('DELETE'), isTrue);
      expect(isEraseConfirmed('  DELETE '), isTrue);
      for (final t in [
        'delete',
        'Delete',
        'DELET',
        'DELETE!',
        '',
        'DELETE ALL',
      ]) {
        expect(isEraseConfirmed(t), isFalse, reason: t);
      }
    });

    test('wipes every table, covers, backups and notifications', () async {
      final shelf = await h.addLocation(name: 'Shelf');
      final dune = await h.addBook(
        id: 'dune',
        title: 'Dune',
        locationId: shelf.id,
        status: ReadStatus.reading,
      );
      await h.addLoan(bookId: dune.id);
      await h.addLog(bookId: dune.id, date: DateTime(2025, 3, 1));
      await h.goals.setTarget(2025, 12);
      final tag = (await h.tags.createIfAbsent('x')).getOrNull()!;
      await h.tags.attach(dune.id, tag.id);
      await prefs.setLastBackupAt(h.clock.now());
      await auto.backUpNow();
      scheduler.pending[1] = (
        at: DateTime(2025, 4),
        title: 't',
        body: 'b',
        payload: 'p',
      );
      scheduler.pending[2] = (
        at: DateTime(2025, 5),
        title: 't',
        body: 'b',
        payload: 'p',
      );
      expect(folder.files, isNotEmpty);

      final r = await erase();
      expect(r.isOk, isTrue);

      for (final t in [
        'books',
        'locations',
        'loans',
        'reading_logs',
        'quotes',
        'goals',
        'tags',
        'book_tags',
        'cover_blobs',
        'lookup_cache',
        'app_meta',
      ]) {
        expect(await count(t), 0, reason: t);
      }
      expect(covers.deletes, containsAll(<String>['dune', 'b1']));
      expect(folder.files, isEmpty);
      expect(scheduler.pending, isEmpty);
      expect((await h.books.search('Dune')).getOrNull(), isEmpty);
    });

    test('erasing brings the introduction back', () async {
      final settings = DriftSettingsRepository(h.db);
      await settings.markOnboardingDone();
      expect(await settings.onboardingDone(), isTrue);
      await erase();
      expect(await settings.onboardingDone(), isFalse);
    });

    test('the app works again afterwards', () async {
      await erase();
      final b = await h.addBook(title: 'Fresh start');
      expect((await h.books.getById(b.id)).getOrNull()!.title, 'Fresh start');
      expect(await prefs.autoEnabled(), isTrue);
    });

    test('an unsupported scheduler is left alone', () async {
      final quiet = FakeNotificationScheduler(supported: false);
      quiet.pending[1] = (at: DateTime(2025), title: '', body: '', payload: '');
      final e = EraseAllData(
        db: h.db,
        store: store,
        covers: covers,
        folder: folder,
        notifications: quiet,
      );
      expect((await e()).isOk, isTrue);
      expect(quiet.pending, hasLength(1));
    });
  });
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/backup_providers.dart';
import 'package:kitabkhana/features/backup/application/backup_codec.dart';
import 'package:kitabkhana/features/backup/application/csv_export.dart';
import 'package:kitabkhana/features/backup/application/erase_all_data.dart';
import 'package:kitabkhana/features/backup/data/csv_store.dart';
import 'package:kitabkhana/features/backup/data/backup_prefs_store.dart';
import 'package:kitabkhana/features/backup/application/export_backup.dart';
import 'package:kitabkhana/features/backup/application/import_backup.dart';
import 'package:kitabkhana/features/backup/data/backup_store.dart';
import 'package:kitabkhana/features/library/domain/book.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/fake_backup_file_picker.dart';
import '../../helpers/fake_backup_folder.dart';
import '../../helpers/pump_router_app.dart';
import '../../helpers/repo_harness.dart';

void main() {
  late AddFlowHarness h;
  late FakeBackupFilePicker picker;
  final FakeBackupFolder folder = FakeBackupFolder();

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  /// Overrides that avoid isolates, which do not run under fake async.
  List<Override> overrides() {
    final store = BackupStore(h.db);
    return <Override>[
      ...h.overrides,
      backupFilePickerProvider.overrideWithValue(picker),
      exportBackupProvider.overrideWithValue(
        ExportBackup(
          store: store,
          covers: h.covers,
          clock: h.clock,
          appVersion: '1.0.0',
        ),
      ),
      exportCsvProvider.overrideWithValue(ExportCsv(CsvStore(h.db))),
      backupFolderProvider.overrideWithValue(folder),
      eraseAllDataProvider.overrideWithValue(
        EraseAllData(
          db: h.db,
          store: store,
          covers: h.covers,
          folder: folder,
          notifications: h.scheduler,
        ),
      ),
      importBackupProvider.overrideWithValue(
        ImportBackup(
          store: store,
          covers: h.covers,
          safety: const NoSafetyBackup(),
        ),
      ),
    ];
  }

  Future<void> open(WidgetTester t) async {
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 900),
      overrides: overrides(),
    );
    routerOf(c).go('/more');
    await t.pumpAndSettle();
  }

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  /// A backup of a small library made elsewhere.
  Future<Uint8List> makeBackup({String title = 'Dune'}) async {
    final other = RepoHarness();
    await other.addBook(id: 'from-backup', title: title, pages: 300);
    final file = (await ExportBackup(
      store: BackupStore(other.db),
      covers: h.covers,
      clock: other.clock,
      appVersion: '1.0.0',
    )()).getOrNull()!;
    await other.db.close();
    return file.bytes;
  }

  Future<List<String>> titles() async =>
      (await h.db.liveBooks().get()).map((b) => b.title).toList();

  setUp(() => picker = FakeBackupFilePicker());

  testWidgets('export warns about borrower details, then shares a .kitab', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(id: 'b', title: 'Emma', now: DateTime(2025, 3, 10)),
      ),
    );
    await open(t);
    await t.tap(find.text('Back up library'));
    await t.pumpAndSettle();
    expect(find.textContaining('phone numbers'), findsOneWidget);
    await t.tap(find.text('Create backup'));
    await t.pumpAndSettle();

    expect(h.share.files, hasLength(1));
    final shared = h.share.files.single;
    expect(shared.name, 'kitabkhana-2025-03-10.kitab');
    final contents = decodeBackupArchive(BackupDecodeInput(shared.bytes, 99));
    expect(contents.manifest.counts['books'], 1);
    await end(t);
  });

  testWidgets('cancelling the warning shares nothing', (t) async {
    h = AddFlowHarness();
    await open(t);
    await t.tap(find.text('Back up library'));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(h.share.files, isEmpty);
    await end(t);
  });

  testWidgets('restore (merge) shows what was found and what was imported', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(id: 'mine', title: 'Mine', now: DateTime(2025, 3, 10)),
      ),
    );
    picker.next = (await t.runAsync(makeBackup))!;
    await open(t);
    await t.tap(find.text('Restore from backup'));
    await t.pumpAndSettle();

    expect(find.textContaining('1 book, 0 loans, 0 quotes'), findsOneWidget);
    await t.tap(find.text('Merge with my library'));
    await t.pumpAndSettle();
    expect(find.text('Backup restored'), findsOneWidget);
    expect(find.text('Imported 1 book, 0 loans, 0 quotes.'), findsOneWidget);
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();

    expect(await t.runAsync(titles), unorderedEquals(<String>['Mine', 'Dune']));
    await end(t);
  });

  testWidgets('restore (replace) asks twice and swaps the library', (t) async {
    h = AddFlowHarness();
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(id: 'mine', title: 'Mine', now: DateTime(2025, 3, 10)),
      ),
    );
    picker.next = (await t.runAsync(makeBackup))!;
    await open(t);
    await t.tap(find.text('Restore from backup'));
    await t.pumpAndSettle();
    await t.tap(find.text('Replace my library'));
    await t.pumpAndSettle();
    expect(find.text('Replace your library?'), findsOneWidget);

    // Backing out changes nothing.
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(await t.runAsync(titles), ['Mine']);

    await t.tap(find.text('Restore from backup'));
    await t.pumpAndSettle();
    await t.tap(find.text('Replace my library'));
    await t.pumpAndSettle();
    await t.tap(find.text('Replace'));
    await t.pumpAndSettle();
    expect(find.text('Backup restored'), findsOneWidget);
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();
    expect(await t.runAsync(titles), ['Dune']);
    await end(t);
  });

  testWidgets('cancelling the file picker does nothing', (t) async {
    h = AddFlowHarness();
    await open(t);
    await t.tap(find.text('Restore from backup'));
    await t.pumpAndSettle();
    expect(picker.asked, 1);
    expect(find.text('Restore from a backup'), findsNothing);
    await end(t);
  });

  testWidgets('a file that is not a backup is refused kindly', (t) async {
    h = AddFlowHarness();
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(id: 'mine', title: 'Mine', now: DateTime(2025, 3, 10)),
      ),
    );
    picker.next = Uint8List.fromList(utf8.encode('just some text'));
    await open(t);
    await t.tap(find.text('Restore from backup'));
    await t.pumpAndSettle();
    expect(find.text("This isn't a Kitabkhana backup."), findsOneWidget);
    expect(await t.runAsync(titles), ['Mine']);
    await end(t);
  });

  testWidgets('a backup from a newer app says to update first', (t) async {
    h = AddFlowHarness();
    final good = (await t.runAsync(makeBackup))!;
    // Re-label the manifest as a future format.
    final archive = ZipDecoder().decodeBytes(good);
    final out = Archive();
    for (final f in archive.files) {
      if (f.name == 'manifest.json') {
        final m = jsonDecode(utf8.decode(f.content)) as Map<String, dynamic>;
        m['formatVersion'] = 99;
        out.addFile(ArchiveFile.string(f.name, jsonEncode(m)));
      } else {
        out.addFile(ArchiveFile.bytes(f.name, f.content));
      }
    }
    picker.next = ZipEncoder().encodeBytes(out);
    await open(t);
    await t.tap(find.text('Restore from backup'));
    await t.pumpAndSettle();
    expect(
      find.text(
        'This backup was made by a newer version. Update the app first.',
      ),
      findsOneWidget,
    );
    await end(t);
  });

  testWidgets('a damaged backup changes nothing', (t) async {
    h = AddFlowHarness();
    final good = (await t.runAsync(makeBackup))!;
    final archive = ZipDecoder().decodeBytes(good);
    final out = Archive();
    for (final f in archive.files) {
      out.addFile(
        f.name == 'data/books.json'
            ? ArchiveFile.string(f.name, '[]')
            : ArchiveFile.bytes(f.name, f.content),
      );
    }
    picker.next = ZipEncoder().encodeBytes(out);
    await open(t);
    await t.tap(find.text('Restore from backup'));
    await t.pumpAndSettle();
    expect(
      find.text('This backup looks damaged, so nothing was changed.'),
      findsOneWidget,
    );
    expect(await t.runAsync(titles), isEmpty);
    await end(t);
  });

  testWidgets('sharing a backup records the time as the last backup', (
    t,
  ) async {
    h = AddFlowHarness();
    await open(t);
    await t.tap(find.text('Back up library'));
    await t.pumpAndSettle();
    await t.tap(find.text('Create backup'));
    await t.pumpAndSettle();
    final last = await t.runAsync(() => DbBackupPrefs(h.db).lastBackupAt());
    expect(last, h.clock.now());
    await end(t);
  });

  testWidgets('CSV export shares books.csv and loans.csv', (t) async {
    h = AddFlowHarness();
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(id: 'b', title: 'Emma', now: DateTime(2025, 3, 10)),
      ),
    );
    await open(t);
    await t.tap(find.text('Export as spreadsheet (CSV)'));
    await t.pumpAndSettle();
    expect(find.textContaining('phone numbers'), findsOneWidget);
    await t.tap(find.text('Export'));
    await t.pumpAndSettle();
    expect(h.share.batches, hasLength(1));
    final files = h.share.batches.single;
    expect(files.map((f) => f.name), ['books.csv', 'loans.csv']);
    expect(files.first.bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
    expect(utf8.decode(files.first.bytes), contains('Emma'));
    await end(t);
  });

  testWidgets('erase needs two confirmations and the exact word', (t) async {
    h = AddFlowHarness();
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(id: 'b', title: 'Emma', now: DateTime(2025, 3, 10)),
      ),
    );
    await open(t);
    await t.drag(find.byType(ListView).first, const Offset(0, -400));
    await t.pumpAndSettle();
    await t.tap(find.text('Erase all data'));
    await t.pumpAndSettle();
    expect(find.text('Erase all data?'), findsOneWidget);

    // Backing out at the first step changes nothing.
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(await t.runAsync(titles), ['Emma']);

    await t.tap(find.text('Erase all data'));
    await t.pumpAndSettle();
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.text('Type DELETE to confirm'), findsOneWidget);
    FilledButton erase() => t.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Erase everything'),
    );
    expect(erase().onPressed, isNull);

    await t.enterText(find.byType(TextField), 'delete');
    await t.pump();
    expect(erase().onPressed, isNull, reason: 'case matters');
    await t.enterText(find.byType(TextField), 'DELETE');
    await t.pump();
    expect(erase().onPressed, isNotNull);
    await t.tap(find.text('Erase everything'));
    await t.pumpAndSettle();

    expect(await t.runAsync(titles), isEmpty);
    expect(find.text('All data erased. Starting fresh.'), findsOneWidget);
    await end(t);
  });

  testWidgets('backing out of the typed confirmation erases nothing', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(id: 'b', title: 'Emma', now: DateTime(2025, 3, 10)),
      ),
    );
    await open(t);
    await t.drag(find.byType(ListView).first, const Offset(0, -400));
    await t.pumpAndSettle();
    await t.tap(find.text('Erase all data'));
    await t.pumpAndSettle();
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(await t.runAsync(titles), ['Emma']);
    await end(t);
  });
}

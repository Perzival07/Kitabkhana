import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/backup_providers.dart';
import 'package:kitabkhana/features/backup/application/auto_backup.dart';
import 'package:kitabkhana/features/backup/application/export_backup.dart';
import 'package:kitabkhana/features/backup/data/backup_prefs_store.dart';
import 'package:kitabkhana/features/backup/data/backup_store.dart';
import 'package:kitabkhana/features/library/application/store_demo_seeder.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/fake_backup_file_picker.dart';
import '../../helpers/pump_router_app.dart';
import '../../helpers/test_db.dart';

void main() {
  group('offDeviceCopyDue', () {
    final now = DateTime(2026, 11, 24);
    bool due({int books = 10, DateTime? last, DateTime? snoozed}) =>
        offDeviceCopyDue(
          bookCount: books,
          lastOffDevice: last,
          snoozedUntil: snoozed,
          now: now,
        );

    test('a library that never left the phone is due', () {
      expect(due(), isTrue);
    });

    test('a tiny library is not nagged about', () {
      expect(due(books: offDeviceMinBooks - 1), isFalse);
    });

    test('a recent copy quiets it, an old one does not', () {
      expect(due(last: now.subtract(const Duration(days: 29))), isFalse);
      expect(due(last: now.subtract(offDeviceRemindAfter)), isTrue);
    });

    test('"Later" quiets it until the snooze ends', () {
      expect(due(snoozed: now.add(const Duration(days: 1))), isFalse);
      expect(due(snoozed: now.subtract(const Duration(days: 1))), isTrue);
    });
  });

  test('the prefs keep both dates', () async {
    final db = createTestDb();
    addTearDown(db.close);
    final prefs = DbBackupPrefs(db);
    expect(await prefs.lastOffDeviceAt(), isNull);
    final at = DateTime(2026, 11, 24, 10);
    await prefs.setLastOffDeviceAt(at);
    await prefs.setOffDeviceSnoozedUntil(at.add(offDeviceSnooze));
    expect(await prefs.lastOffDeviceAt(), at);
    expect(await prefs.offDeviceSnoozedUntil(), at.add(offDeviceSnooze));
  });

  group('the reminder and "Save a copy"', () {
    late AddFlowHarness h;
    late FakeBackupFilePicker picker;

    Future<void> open(WidgetTester t, String path) async {
      h = AddFlowHarness();
      addTearDown(h.dispose);
      picker = FakeBackupFilePicker();
      await t.runAsync(
        () => StoreDemoSeeder(
          books: h.repos.books,
          locations: h.repos.locations,
          loans: h.repos.loans,
          readings: h.repos.readings,
          quotes: h.repos.quotes,
          goals: h.repos.goals,
          tags: h.repos.tags,
          clock: h.clock,
        ).seed(),
      );
      final c = await pumpRouterApp(
        t,
        size: const Size(420, 900),
        overrides: <Override>[
          ...h.overrides,
          backupFilePickerProvider.overrideWithValue(picker),
          // No isolates under fake async.
          exportBackupProvider.overrideWithValue(
            ExportBackup(
              store: BackupStore(h.db),
              covers: h.covers,
              clock: h.clock,
              appVersion: '1.0.0',
            ),
          ),
        ],
      );
      routerOf(c).go(path);
      await settle(t);
    }

    testWidgets('the Library reminds, and saving a copy quiets it', (t) async {
      await open(t, '/library');
      expect(find.text('Your library is only on this phone'), findsOneWidget);
      await t.tap(find.text('Save a copy'));
      await settle(t);
      expect(picker.saved.single.name, endsWith('.kitab'));
      expect(find.text('Copy saved'), findsOneWidget);
      expect(find.text('Your library is only on this phone'), findsNothing);
      expect(
        await t.runAsync(() => DbBackupPrefs(h.db).lastOffDeviceAt()),
        isNotNull,
      );
    });

    testWidgets('"Later" puts it off', (t) async {
      await open(t, '/library');
      await t.tap(find.text('Later'));
      await settle(t);
      expect(find.text('Your library is only on this phone'), findsNothing);
      expect(
        await t.runAsync(() => DbBackupPrefs(h.db).offDeviceSnoozedUntil()),
        isNotNull,
      );
    });

    testWidgets('a cancelled save changes nothing', (t) async {
      await open(t, '/library');
      picker.saveOk = false;
      await t.tap(find.text('Save a copy'));
      await settle(t);
      expect(find.text('Your library is only on this phone'), findsOneWidget);
    });

    testWidgets('Settings saves a copy too, and says when', (t) async {
      await open(t, '/settings');
      await t.scrollUntilVisible(
        find.text('Save a copy to…'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Save a copy to…'));
      await settle(t);
      expect(picker.saved, hasLength(1));
      expect(
        find.textContaining('Last copy saved off this phone'),
        findsOneWidget,
      );
    });
  });
}

/// Lets database work finish between frames.
Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 3; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await t.pumpAndSettle();
  }
}

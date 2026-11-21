import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/backup_providers.dart';
import 'package:kitabkhana/features/backup/application/export_backup.dart';
import 'package:kitabkhana/features/backup/application/import_backup.dart';
import 'package:kitabkhana/features/backup/application/erase_all_data.dart';
import 'package:kitabkhana/features/backup/data/backup_store.dart';

import '../test/helpers/add_flow_harness.dart';
import '../test/helpers/fake_backup_file_picker.dart';
import '../test/helpers/fake_backup_folder.dart';
import '../test/helpers/pump_router_app.dart';

/// The whole app over an in-memory database with fake platform services
/// (camera, text reading, notifications, Open Library, sharing, file picking)
/// and a clock the journey can move. The same journeys run under
/// `flutter test` (see `test/e2e/`) and on a device or browser
/// (`integration_test/app_test.dart`).
class E2e {
  E2e(this.t, {List<String> scanCodes = const <String>[]})
    : h = AddFlowHarness(scanCodes: scanCodes) {
    // Zipping and unzipping use isolates in the real app; the journeys use
    // direct calls, and fakes for the file picker and the app's own folder.
    final store = BackupStore(h.db);
    final folder = FakeBackupFolder();
    h.extra.addAll(<Override>[
      backupFilePickerProvider.overrideWithValue(filePicker),
      backupFolderProvider.overrideWithValue(folder),
      exportBackupProvider.overrideWithValue(
        ExportBackup(
          store: store,
          covers: h.covers,
          clock: h.clock,
          appVersion: '1.0.0',
        ),
      ),
      importBackupProvider.overrideWithValue(
        ImportBackup(
          store: store,
          covers: h.covers,
          safety: const NoSafetyBackup(),
        ),
      ),
      eraseAllDataProvider.overrideWithValue(
        EraseAllData(
          db: h.db,
          store: store,
          covers: h.covers,
          folder: folder,
          notifications: h.scheduler,
        ),
      ),
    ]);
  }

  final WidgetTester t;
  final AddFlowHarness h;
  final FakeBackupFilePicker filePicker = FakeBackupFilePicker();
  late ProviderContainer container;

  /// Opens the app at [path].
  Future<void> start(String path, {Size size = const Size(412, 915)}) async {
    // Animations off: the scanner's pulse never stops, so waiting for the
    // screen to settle would never end.
    container = await h.pump(
      t,
      start: path,
      size: size,
      disableAnimations: true,
    );
  }

  /// Closes the app and opens it again on the same data, as a new day's
  /// launch would.
  Future<void> restart(String path, {Size size = const Size(412, 915)}) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
    await start(path, size: size);
  }

  GoRouterLike get router => GoRouterLike(this);

  String get location => locationOf(container);

  /// Moves time without waiting for endless animations: a spinner that never
  /// stops would make `pumpAndSettle` run forever.
  Future<void> advance() async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 1));
  }

  /// Real time for database and fake-service futures to answer.
  Future<void> settleReal([int ms = 80]) async {
    await t.runAsync(() => Future<void>.delayed(Duration(milliseconds: ms)));
    await advance();
  }

  /// Scrolls until [target] exists and is visible.
  Future<void> reveal(Finder target) async {
    if (target.evaluate().isEmpty) {
      final list = find.byType(Scrollable).first;
      await t.drag(list, const Offset(0, 6000));
      await t.pump();
      await t.scrollUntilVisible(target, 250, scrollable: list);
    } else {
      await t.ensureVisible(target.first);
    }
    await advance();
    // ensureVisible can leave the target hard against the top edge, under a
    // transparent app bar; a person would scroll it into the open.
    final top = t.getTopLeft(target.first).dy;
    if (top < 110 && find.byType(Scrollable).evaluate().isNotEmpty) {
      await t.drag(find.byType(Scrollable).first, Offset(0, 160 - top));
      await advance();
    }
  }

  Future<void> tapText(String text, {bool last = false}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pump();
    final f = find.text(text);
    await reveal(f);
    await t.tap(last ? f.last : f.first);
    await advance();
  }

  Future<void> tap(Finder f) async {
    await reveal(f);
    await t.tap(f.first);
    await advance();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> enter(String label, String text) async {
    await reveal(field(label));
    await t.enterText(field(label), text);
    await t.pump();
  }

  /// Taps [text] and gives real time for what it starts to finish.
  Future<void> tapAndWait(String text, {bool last = false}) async {
    await tapText(text, last: last);
    await settleReal();
  }

  Future<void> end() async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  Future<void> dispose() => h.dispose();
}

/// Navigation helpers for a journey.
class GoRouterLike {
  GoRouterLike(this._e);
  final E2e _e;

  Future<void> go(String path) async {
    routerOf(_e.container).go(path);
    await _e.advance();
  }
}

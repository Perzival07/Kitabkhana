import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/backup_providers.dart';
import 'package:kitabkhana/app/location_providers.dart';
import 'package:kitabkhana/app/router/routes.dart';
import 'package:kitabkhana/app/settings_providers.dart';
import 'package:kitabkhana/features/backup/application/export_backup.dart';
import 'package:kitabkhana/features/backup/application/import_backup.dart';
import 'package:kitabkhana/features/backup/data/backup_store.dart';
import 'package:kitabkhana/features/settings/data/drift_settings_repository.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/fake_backup_file_picker.dart';
import '../../helpers/pump_router_app.dart';
import '../../helpers/repo_harness.dart';

void main() {
  late AddFlowHarness h;
  late FakeBackupFilePicker picker;

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  List<Override> overrides() {
    final store = BackupStore(h.db);
    return <Override>[
      ...h.overrides,
      backupFilePickerProvider.overrideWithValue(picker),
      importBackupProvider.overrideWithValue(
        ImportBackup(
          store: store,
          covers: h.covers,
          safety: const NoSafetyBackup(),
        ),
      ),
    ];
  }

  Future<ProviderContainer> open(
    WidgetTester t, {
    Size size = const Size(420, 900),
    double textScale = 1,
    bool reduceMotion = false,
  }) async {
    final c = await pumpRouterApp(
      t,
      size: size,
      textScale: textScale,
      disableAnimations: reduceMotion,
      overrides: overrides(),
    );
    routerOf(c).go(Routes.onboarding);
    await t.pumpAndSettle();
    return c;
  }

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  Future<bool> done(WidgetTester t) async =>
      (await t.runAsync(() => DriftSettingsRepository(h.db).onboardingDone()))!;

  Future<List<String>> placeNames() async =>
      (await h.db.liveLocations().get()).map((l) => l.name).toList()..sort();

  Future<void> next(WidgetTester t, [int times = 1]) async {
    for (var i = 0; i < times; i++) {
      await t.tap(find.text('Next'));
      await t.pumpAndSettle();
    }
  }

  setUp(() => picker = FakeBackupFilePicker());

  testWidgets('three intro pages, in order, with a step indicator', (t) async {
    h = AddFlowHarness();
    await open(t);
    expect(find.text('Know what you own'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 1 of 5'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await next(t);
    expect(find.text('Never buy it twice'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 2 of 5'), findsOneWidget);

    await next(t);
    expect(find.text('Your books stay with you'), findsOneWidget);
    expect(find.textContaining('No account'), findsOneWidget);
    await end(t);
  });

  testWidgets('swiping moves between pages too', (t) async {
    h = AddFlowHarness();
    await open(t);
    await t.drag(find.byType(PageView), const Offset(-400, 0));
    await t.pumpAndSettle();
    expect(find.text('Never buy it twice'), findsOneWidget);
    await t.drag(find.byType(PageView), const Offset(400, 0));
    await t.pumpAndSettle();
    expect(find.text('Know what you own'), findsOneWidget);
    await end(t);
  });

  testWidgets('Skip leaves at once and is remembered', (t) async {
    h = AddFlowHarness();
    final c = await open(t);
    expect(await done(t), isFalse);
    await t.tap(find.text('Skip'));
    await t.pumpAndSettle();
    expect(locationOf(c), Routes.library);
    expect(await done(t), isTrue);
    expect(await t.runAsync(placeNames), isEmpty);
    await end(t);
  });

  testWidgets('starter places: all are ticked, and choosing saves them', (
    t,
  ) async {
    h = AddFlowHarness();
    await open(t);
    await next(t, 3);
    expect(find.text('Where do your books live?'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    for (final n in ['Living room shelf', 'Bedroom shelf', 'Storage box']) {
      expect(
        t.widget<FilterChip>(find.widgetWithText(FilterChip, n)).selected,
        isTrue,
        reason: n,
      );
    }
    await t.tap(find.widgetWithText(FilterChip, 'Bedroom shelf'));
    await t.pump();
    await t.tap(find.text('Use these places'));
    await t.pumpAndSettle();

    expect(await t.runAsync(placeNames), ['Living room shelf', 'Storage box']);
    expect(find.text('You are all set'), findsOneWidget);
    expect(find.text('Skip'), findsNothing, reason: 'the last page has none');
    final c = ProviderScope.containerOf(t.element(find.byType(PageView)));
    expect(c.read(starterLocationsDoneProvider), isTrue);
    await end(t);
  });

  testWidgets('"Not now" saves no places but moves on', (t) async {
    h = AddFlowHarness();
    await open(t);
    await next(t, 3);
    await t.tap(find.text('Not now'));
    await t.pumpAndSettle();
    expect(await t.runAsync(placeNames), isEmpty);
    expect(find.text('You are all set'), findsOneWidget);
    await end(t);
  });

  testWidgets('unticking everything saves nothing', (t) async {
    h = AddFlowHarness();
    await open(t);
    await next(t, 3);
    for (final n in ['Living room shelf', 'Bedroom shelf', 'Storage box']) {
      await t.tap(find.widgetWithText(FilterChip, n));
      await t.pump();
    }
    await t.tap(find.text('Use these places'));
    await t.pumpAndSettle();
    expect(await t.runAsync(placeNames), isEmpty);
    await end(t);
  });

  Future<void> toLastPage(WidgetTester t) async {
    await next(t, 3);
    await t.tap(find.text('Not now'));
    await t.pumpAndSettle();
  }

  testWidgets('Add your first book opens the add flow over the library', (
    t,
  ) async {
    h = AddFlowHarness();
    final c = await open(t);
    await toLastPage(t);
    await t.tap(find.text('Add your first book'));
    await t.pumpAndSettle();
    expect(locationOf(c), Routes.libraryAdd);
    expect(await done(t), isTrue);
    await end(t);
  });

  testWidgets('Explore goes to the library', (t) async {
    h = AddFlowHarness();
    final c = await open(t);
    await toLastPage(t);
    await t.tap(find.text('Explore the app'));
    await t.pumpAndSettle();
    expect(locationOf(c), Routes.library);
    expect(await done(t), isTrue);
    await end(t);
  });

  testWidgets('Restore from backup brings the library back and finishes', (
    t,
  ) async {
    h = AddFlowHarness();
    final other = RepoHarness();
    await t.runAsync(() async {
      await other.addBook(id: 'x', title: 'Dune');
      picker.next = (await ExportBackup(
        store: BackupStore(other.db),
        covers: h.covers,
        clock: other.clock,
        appVersion: '1.0.0',
      )()).getOrNull()!.bytes;
      await other.db.close();
    });
    final c = await open(t);
    await toLastPage(t);
    await t.tap(find.text('Restore from backup'));
    await t.pumpAndSettle();
    await t.tap(find.text('Merge with my library'));
    await t.pumpAndSettle();
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();
    expect(locationOf(c), Routes.library);
    expect(await done(t), isTrue);
    final titles = await t.runAsync(
      () async => (await h.db.liveBooks().get()).map((b) => b.title).toList(),
    );
    expect(titles, ['Dune']);
    await end(t);
  });

  testWidgets('cancelling the restore keeps you on the last page', (t) async {
    h = AddFlowHarness();
    final c = await open(t);
    await toLastPage(t);
    await t.tap(find.text('Restore from backup'));
    await t.pumpAndSettle();
    expect(picker.asked, 1);
    expect(locationOf(c), Routes.onboarding);
    expect(await done(t), isFalse);
    expect(find.text('You are all set'), findsOneWidget);
    await end(t);
  });

  testWidgets('a file that is not a backup does not finish onboarding', (
    t,
  ) async {
    h = AddFlowHarness();
    picker.next = Uint8List.fromList(<int>[1, 2, 3]);
    final c = await open(t);
    await toLastPage(t);
    await t.tap(find.text('Restore from backup'));
    await t.pumpAndSettle();
    expect(find.text("This isn't a Kitabkhana backup."), findsOneWidget);
    expect(locationOf(c), Routes.onboarding);
    expect(await done(t), isFalse);
    await end(t);
  });

  testWidgets('reduced motion: pages change at once', (t) async {
    h = AddFlowHarness();
    await open(t, reduceMotion: true);
    await t.tap(find.text('Next'));
    await t.pump();
    expect(find.text('Never buy it twice'), findsOneWidget);
    await end(t);
  });

  group('layouts', () {
    Future<void> walk(WidgetTester t) async {
      for (var i = 0; i < 3; i++) {
        expect(t.takeException(), isNull, reason: 'intro page $i');
        await next(t);
      }
      expect(t.takeException(), isNull, reason: 'places page');
      await t.tap(find.text('Not now'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull, reason: 'last page');
    }

    testWidgets('320dp wide at 200% text', (t) async {
      h = AddFlowHarness();
      await open(t, size: const Size(320, 568), textScale: 2);
      await walk(t);
      await end(t);
    });

    testWidgets('a phone on its side', (t) async {
      h = AddFlowHarness();
      await open(t, size: const Size(800, 360));
      await walk(t);
      await end(t);
    });

    testWidgets('a tablet keeps the content narrow and centred', (t) async {
      h = AddFlowHarness();
      await open(t, size: const Size(1280, 800));
      final box = t.getRect(find.text('Know what you own'));
      expect(box.width, lessThanOrEqualTo(520));
      expect(box.center.dx, closeTo(640, 2));
      await walk(t);
      await end(t);
    });
  });

  group('first-run routing', () {
    test('the app opens on the library unless told otherwise', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(initialRouteProvider), Routes.library);
      c.read(initialRouteProvider.notifier).set(Routes.onboarding);
      expect(c.read(initialRouteProvider), Routes.onboarding);
    });
  });
}

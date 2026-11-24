import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/app_config.dart';
import 'package:kitabkhana/app/app_config_provider.dart';
import 'package:kitabkhana/app/app_root.dart';
import 'package:kitabkhana/app/crash_providers.dart';
import 'package:kitabkhana/features/backup/data/backup_prefs_store.dart';
import 'package:kitabkhana/features/crash/domain/crash_report.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/platform/crash/crash_store.dart';
import 'package:kitabkhana/app/library_providers.dart';
import 'package:kitabkhana/app/router/app_router.dart';
import 'package:kitabkhana/app/scan_providers.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/library/application/store_demo_seeder.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';
import 'package:kitabkhana/features/scan_check/presentation/verdict_sheet.dart';
import 'package:kitabkhana/features/settings/domain/app_settings.dart'
    show LibraryView;

import '../helpers/add_flow_harness.dart';

/// Writes the README screenshots: every screen of the app, unframed, filled
/// with the public-domain classics from `StoreDemoSeeder`.
///
///   GENERATE_ASSETS=1 flutter test test/tool/generate_readme_screenshots_test.dart
///
/// Output: `docs/screenshots/<name>.png`. Skipped in ordinary runs so tests
/// never rewrite the repository.
void main() {
  final generate = Platform.environment['GENERATE_ASSETS'] == '1';

  const tablet = Size(1280, 800);

  final shots = <_Shot>[
    // Onboarding.
    const _Shot('onboarding-1', '/onboarding'),
    _Shot('onboarding-2', '/onboarding', after: _next(1)),
    _Shot('onboarding-3', '/onboarding', after: _next(2)),
    _Shot('onboarding-places', '/onboarding', after: _next(3)),
    // Library.
    const _Shot('library-grid', '/library'),
    const _Shot('library-backup-reminder', '/library', backupReminder: true),
    const _Shot('library-list', '/library', after: _listView),
    _Shot('library-sort', '/library', after: _tapTooltip('Sort')),
    _Shot('library-search', '/library', after: _search('the')),
    // Adding books.
    const _Shot('add-entry', '/library/add'),
    const _Shot('add-scan', '/library/add/scan'),
    const _Shot('add-batch', '/library/add/batch'),
    const _Shot('add-isbn', '/library/add/isbn'),
    const _Shot('add-search', '/library/add/search', after: _titleSearch),
    const _Shot('add-manual', '/library/add/manual'),
    // A book.
    const _Shot('book-detail', '/book/${StoreDemoSeeder.middlemarchId}'),
    _Shot(
      'book-detail-more',
      '/book/${StoreDemoSeeder.middlemarchId}',
      after: _scroll(500),
    ),
    const _Shot('book-detail-lent', '/book/demo-frankenstein'),
    const _Shot('book-detail-finished', '/book/${StoreDemoSeeder.prideId}'),
    const _Shot('book-detail-wishlist', '/book/demo-little-women'),
    _Shot('book-detail-series', '/book/demo-jos-boys', after: _scroll(420)),
    _Shot('lend-sheet', '/book/demo-dorian', after: _tapText('Lend')),
    const _Shot('book-edit', '/book/${StoreDemoSeeder.middlemarchId}/edit'),
    const _Shot(
      'quote-capture',
      '/book/${StoreDemoSeeder.middlemarchId}/quote',
    ),
    // Scan tab.
    const _Shot('scan', '/scan'),
    const _Shot('scan-verdict', '/library', verdict: true),
    // Reading and stats.
    const _Shot('reading', '/reading'),
    const _Shot('stats', '/stats'),
    _Shot('stats-more', '/stats', after: _scroll(700)),
    _Shot('goal-sheet', '/stats', after: _tapText('Edit goal')),
    const _Shot('crash-prompt', '/library', crash: true),
    // More.
    const _Shot('more', '/more'),
    const _Shot('loans-lent', '/loans'),
    _Shot('loans-borrowed', '/loans', after: _tapTextContaining('Borrowed')),
    _Shot('loans-overdue', '/loans', after: _tapTextContaining('Overdue')),
    _Shot('loans-history', '/loans', after: _tapTextContaining('History')),
    const _Shot('quotes', '/quotes'),
    const _Shot('locations', '/locations'),
    _Shot('location-editor', '/locations', after: _tapTooltip('Add location')),
    const _Shot('tags', '/tags'),
    const _Shot('settings', '/settings'),
    _Shot('settings-more', '/settings', after: _scroll(700)),
    const _Shot('about', '/about'),
    // Dark theme.
    const _Shot('dark-library', '/library', dark: true),
    const _Shot(
      'dark-book-detail',
      '/book/${StoreDemoSeeder.middlemarchId}',
      dark: true,
    ),
    const _Shot('dark-stats', '/stats', dark: true),
    const _Shot('dark-reading', '/reading', dark: true),
    // Wide screens: tablet and web.
    const _Shot('wide-library', '/library', size: tablet),
    _Shot(
      'wide-library-selected',
      '/library',
      size: tablet,
      after: _tapText('Middlemarch'),
    ),
    const _Shot(
      'wide-book-detail',
      '/book/${StoreDemoSeeder.middlemarchId}',
      size: tablet,
    ),
    const _Shot('wide-stats', '/stats', size: tablet),
  ];

  for (final shot in shots) {
    testWidgets('readme: ${shot.name}', (t) async {
      // A dim stand-in for the camera feed.
      final h = AddFlowHarness(
        cameraFeed: (_) => const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF3A332D), Color(0xFF1E1A17)],
            ),
          ),
          child: SizedBox.expand(),
        ),
      );
      addTearDown(h.dispose);
      h.clock.set(DateTime(2026, 11, 24, 9));
      h.source.onSearch = () => Ok<List<BookInfo>>(<BookInfo>[
        BookInfo(
          title: 'The Brothers Karamazov',
          authors: const <String>['Fyodor Dostoevsky'],
          pages: 796,
          year: 1880,
          isbn13: parseIsbn('9780374528379'),
        ),
        const BookInfo(
          title: 'The Count of Monte Cristo',
          authors: <String>['Alexandre Dumas'],
          pages: 1276,
          year: 1844,
        ),
        const BookInfo(
          title: 'The Picture of Dorian Gray',
          authors: <String>['Oscar Wilde'],
          pages: 254,
          year: 1890,
        ),
        const BookInfo(
          title: 'The Hound of the Baskervilles',
          authors: <String>['Arthur Conan Doyle'],
          pages: 256,
          year: 1902,
        ),
      ]);
      final crashes = MemoryCrashStore();
      await t.runAsync(() async {
        await StoreDemoSeeder(
          books: h.repos.books,
          locations: h.repos.locations,
          loans: h.repos.loans,
          readings: h.repos.readings,
          quotes: h.repos.quotes,
          goals: h.repos.goals,
          tags: h.repos.tags,
          clock: h.clock,
        ).seed();
        // A goal the demo year is on pace for.
        await h.repos.goals.setTarget(2026, 7);
        // A series with a gap: Little Women (1) and Jo's Boys (3).
        await h.repos.books.update(
          'demo-little-women',
          (b) => b.copyWith(series: 'Little Women', seriesNumber: 1),
        );
        await h.repos.books.upsert(
          Book.create(
            id: 'demo-jos-boys',
            title: "Jo's Boys",
            authors: 'Louisa May Alcott',
            pages: 368,
            genre: 'Classics',
            now: DateTime(2026, 1, 5),
            series: 'Little Women',
            seriesNumber: 3,
          ),
        );
        if (!shot.backupReminder) {
          await DbBackupPrefs(h.db).setLastOffDeviceAt(h.clock.now());
        }
        if (shot.crash) {
          await crashes.save(
            CrashReport(
              at: h.clock.now(),
              kind: 'flutter',
              errorType: 'StateError',
              message: 'Bad state: example',
              stack: '',
              logLines: const <String>[],
              appVersion: '1.1.0',
              platform: 'android',
              osVersion: 'Android 15',
            ),
            screenshot: Uint8List.fromList(const <int>[1]),
          );
        }
      });

      const ratio = 2.0;
      t.view
        ..physicalSize = shot.size * ratio
        ..devicePixelRatio = ratio;
      addTearDown(t.view.reset);
      final key = GlobalKey();
      final container = ProviderContainer(
        overrides: <Override>[
          appConfigProvider.overrideWithValue(const AppConfig.prod()),
          ...h.overrides,
          crashStoreProvider.overrideWithValue(crashes),
        ],
      );
      addTearDown(container.dispose);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: key,
            child: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: const AppRoot(),
              ),
            ),
          ),
        ),
      );
      if (shot.dark) {
        container
            .read(themeModeControllerProvider.notifier)
            .set(ThemeMode.dark);
      }
      container.read(appRouterProvider).go(shot.path);
      await _settle(t);
      await shot.after?.call(t, container);
      if (shot.verdict) {
        final check = container.read(checkOwnershipProvider);
        final result = await t.runAsync(() => check(StoreDemoSeeder.prideIsbn));
        final context = t.element(find.byType(Scaffold).first);
        unawaited(showVerdictSheet(context, result: result!, check: check));
      }
      await _settle(t);

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = (await t.runAsync(
        () => boundary.toImage(pixelRatio: ratio),
      ))!;
      final png = (await t.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.png),
      ))!;
      final file = File('docs/screenshots/${shot.name}.png');
      file.parent.createSync(recursive: true);
      await t.runAsync(() => file.writeAsBytes(png.buffer.asUint8List()));
      image.dispose();
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
    }, skip: !generate);
  }
}

typedef _After = Future<void> Function(WidgetTester t, ProviderContainer c);

/// Lets database reads finish, then settles the frame.
Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 3; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await t.pumpAndSettle();
  }
}

_After _next(int times) => (t, c) async {
  for (var i = 0; i < times; i++) {
    await t.tap(find.text('Next').last);
    await _settle(t);
  }
};

Future<void> _listView(WidgetTester t, ProviderContainer c) async {
  await c.read(libraryViewControllerProvider.notifier).set(LibraryView.list);
  await _settle(t);
}

_After _tapTooltip(String tooltip) => (t, c) async {
  await t.tap(find.byTooltip(tooltip).first);
  await _settle(t);
};

_After _tapText(String text) => (t, c) async {
  final f = find.text(text).first;
  await t.ensureVisible(f);
  await _settle(t);
  await t.tap(f);
  await _settle(t);
};

_After _tapTextContaining(String text) => (t, c) async {
  await t.tap(find.textContaining(text).first);
  await _settle(t);
};

_After _search(String query) => (t, c) async {
  await t.enterText(find.byType(TextField).first, query);
  await _settle(t);
  FocusManager.instance.primaryFocus?.unfocus();
  await _settle(t);
};

Future<void> _titleSearch(WidgetTester t, ProviderContainer c) async {
  await t.enterText(find.byType(TextField).first, 'the');
  await t.testTextInput.receiveAction(TextInputAction.search);
  await _settle(t);
  FocusManager.instance.primaryFocus?.unfocus();
  await _settle(t);
}

_After _scroll(double by) => (t, c) async {
  await t.drag(find.byType(Scrollable).first, Offset(0, -by));
  await _settle(t);
};

class _Shot {
  const _Shot(
    this.name,
    this.path, {
    this.after,
    this.dark = false,
    this.verdict = false,
    this.size = const Size(390, 844),
    this.backupReminder = false,
    this.crash = false,
  });

  final String name;
  final String path;
  final _After? after;
  final bool dark;
  final bool verdict;
  final Size size;

  /// Leave the "only on this phone" reminder showing in the Library.
  final bool backupReminder;

  /// Start with a kept problem report, so the crash prompt shows.
  final bool crash;
}

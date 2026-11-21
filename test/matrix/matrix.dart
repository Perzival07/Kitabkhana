import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/library_providers.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/features/settings/domain/app_settings.dart'
    show LibraryView;

import '../helpers/add_flow_harness.dart';
import '../helpers/seed_library.dart';

/// The device sizes the app is checked at (logical pixels).
const List<(String, Size)> matrixSizes = <(String, Size)>[
  ('320x568', Size(320, 568)), // small phone
  ('360x800', Size(360, 800)), // common Android
  ('412x915', Size(412, 915)), // large Android
  ('430x932', Size(430, 932)), // large iPhone
  ('844x390', Size(844, 390)), // phone on its side
  ('600x960', Size(600, 960)), // small tablet / foldable inner screen
  ('800x1280', Size(800, 1280)), // tablet, portrait
  ('1280x800', Size(1280, 800)), // tablet, landscape
  ('1440x900', Size(1440, 900)), // web
];

/// One screen of the matrix: where to open it and what to do after.
class MatrixScreen {
  const MatrixScreen(this.name, this.path, {this.after, this.scanCodes});

  final String name;
  final String path;

  /// Extra setup once the screen is open (switch the view, tap a scan code).
  final Future<void> Function(WidgetTester t, ProviderContainer c)? after;

  /// Barcodes the fake scanner offers on this screen.
  final List<String>? scanCodes;
}

Future<void> _list(WidgetTester t, ProviderContainer c) async {
  await c.read(libraryViewControllerProvider.notifier).set(LibraryView.list);
  await t.pumpAndSettle();
}

Future<void> _scanOwned(WidgetTester t, ProviderContainer c) async {
  // The scanner wants to see a code twice before it trusts it.
  await t.tap(find.text('scan 9780441013593'));
  await t.pump();
  await t.tap(find.text('scan 9780441013593'));
  // The ownership check reads the database; give it real time to answer.
  await t.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await t.pump();
  await t.pump(const Duration(milliseconds: 400));
}

const List<MatrixScreen> matrixScreens = <MatrixScreen>[
  MatrixScreen('library-grid', '/library'),
  MatrixScreen('library-list', '/library', after: _list),
  MatrixScreen('add-book', '/library/add'),
  MatrixScreen('add-manual', '/library/add/manual'),
  MatrixScreen('book-detail', '/book/b1'),
  MatrixScreen('book-detail-lent', '/book/b2'),
  MatrixScreen(
    'scan-result',
    '/scan',
    after: _scanOwned,
    scanCodes: <String>['9780441013593'],
  ),
  MatrixScreen('loans', '/loans'),
  MatrixScreen('reading', '/reading'),
  MatrixScreen('stats', '/stats'),
  MatrixScreen('quotes', '/quotes'),
  MatrixScreen('settings', '/settings'),
  MatrixScreen('onboarding', '/onboarding'),
];

/// Opens [screen] at [size] with demo data. Returns the harness (dispose it).
Future<AddFlowHarness> openMatrixScreen(
  WidgetTester t,
  MatrixScreen screen, {
  required Size size,
  bool dark = false,
  double textScale = 1,
  bool seed = true,
}) async {
  final h = AddFlowHarness(scanCodes: screen.scanCodes ?? const <String>[]);
  addTearDown(h.dispose);
  if (seed) await t.runAsync(() => seedDemoLibrary(h));
  final c = await h.pump(
    t,
    start: screen.path,
    size: size,
    textScale: textScale,
    disableAnimations: true,
  );
  if (dark) {
    c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
    await t.pumpAndSettle();
  }
  await screen.after?.call(t, c);
  await t.pumpAndSettle();
  return h;
}

/// Unmounts the screen so no timers are left behind.
Future<void> closeMatrixScreen(WidgetTester t, AddFlowHarness h) async {
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(milliseconds: 400));
}

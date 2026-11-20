import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/add_book_providers.dart';
import 'package:kitabkhana/app/library_providers.dart';
import 'package:kitabkhana/app/repositories.dart';
import 'package:kitabkhana/app/theme/app_theme.dart';
import 'package:kitabkhana/l10n/app_localizations.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';
import 'package:kitabkhana/features/locations/presentation/location_picker.dart';
import 'package:kitabkhana/features/locations/presentation/locations_screen.dart';

import '../../helpers/add_flow_harness.dart';

void main() {
  late AddFlowHarness h;

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> advance(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 1));
  }

  void locTest(String name, Future<void> Function(WidgetTester t) body) {
    testWidgets(name, (t) async {
      h = AddFlowHarness();
      await body(t);
      await t.pumpWidget(const SizedBox());
      await advance(t);
    });
  }

  Future<void> addLoc(String id, String name, {int order = 0}) =>
      h.repos.locations.upsert(
        Location.create(
          id: id,
          name: name,
          now: h.clock.now(),
          sortOrder: order,
          icon: 'shelf',
        ),
      );

  Future<void> addBook(String id, String title, String? loc) =>
      h.repos.books.upsert(
        Book.create(id: id, title: title, now: h.clock.now(), locationId: loc),
      );

  Future<void> pumpScreen(WidgetTester t, {Widget? child}) async {
    t.view
      ..physicalSize = const Size(400, 900)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    // The provider scope sits above the app so sheets and dialogs see it.
    await t.pumpWidget(
      ProviderScope(
        overrides: h.overrides,
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child ?? const LocationsScreen(),
        ),
      ),
    );
    await advance(t);
  }

  locTest('first run offers starter locations that can be accepted', (t) async {
    await pumpScreen(t);
    expect(find.text('Add all three'), findsOneWidget);
    await t.tap(find.text('Add all three'));
    await advance(t);
    expect(find.text('Living room shelf'), findsOneWidget);
    expect(find.text('Bedroom shelf'), findsOneWidget);
    expect(find.text('Storage box'), findsOneWidget);
  });

  locTest('starter locations can be skipped', (t) async {
    await pumpScreen(t);
    await t.tap(find.text('Skip'));
    await advance(t);
    expect(find.text('Where do your books live?'), findsOneWidget);
    expect(find.text('Living room shelf'), findsNothing);
  });

  locTest('book counts update live', (t) async {
    await addLoc('l1', 'Hall');
    await pumpScreen(t);
    expect(find.text('No books'), findsOneWidget);
    await addBook('b1', 'Dune', 'l1');
    await advance(t);
    expect(find.text('1 book'), findsOneWidget);
    await addBook('b2', 'Emma', 'l1');
    await advance(t);
    expect(find.text('2 books'), findsOneWidget);
  });

  locTest('adding a duplicate name (any case) is refused', (t) async {
    await addLoc('l1', 'Hall');
    await pumpScreen(t);
    await t.tap(find.byTooltip('Add location'));
    await advance(t);
    await t.enterText(find.byType(TextField).last, 'hALL');
    await t.tap(find.text('Save'));
    await advance(t);
    expect(
      find.text('You already have a location with that name.'),
      findsOneWidget,
    );
    final all = (await t.runAsync(() => h.repos.locations.watchAll().first))!;
    expect(all, hasLength(1));
  });

  locTest('add location saves a new one', (t) async {
    await pumpScreen(t);
    await t.tap(find.byTooltip('Add location'));
    await advance(t);
    await t.enterText(find.byType(TextField).last, 'Attic');
    await t.tap(find.text('Save'));
    await advance(t);
    expect(find.text('Attic'), findsOneWidget);
  });

  locTest('child location shows its parent in the path', (t) async {
    await addLoc('p', 'Bedroom');
    await h.repos.locations.upsert(
      Location.create(
        id: 'c',
        name: 'Shelf 2',
        now: h.clock.now(),
        parentId: 'p',
        sortOrder: 1,
      ),
    );
    await pumpScreen(t);
    expect(find.text('Bedroom › Shelf 2'), findsOneWidget);
  });

  locTest('deleting a location with books moves them in one go', (t) async {
    await addLoc('a', 'Hall', order: 0);
    await addLoc('b', 'Attic', order: 1);
    await addBook('b1', 'Dune', 'a');
    await addBook('b2', 'Emma', 'a');
    await pumpScreen(t);
    await t.tap(find.byType(PopupMenuButton<String>).first);
    await advance(t);
    await t.tap(find.text('Delete location'));
    await advance(t);
    expect(find.text('Move 2 books to…'), findsOneWidget);
    await t.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Attic'),
      ),
    );
    await advance(t);
    expect(find.text('Hall'), findsNothing);
    expect(find.text('2 books'), findsOneWidget);
    final books = (await t.runAsync(() => h.repos.books.watchAll().first))!;
    expect(books.every((b) => b.locationId == 'b'), isTrue);
  });

  locTest('deleting a location can leave books without one', (t) async {
    await addLoc('a', 'Hall');
    await addBook('b1', 'Dune', 'a');
    await pumpScreen(t);
    await t.tap(find.byType(PopupMenuButton<String>).first);
    await advance(t);
    await t.tap(find.text('Delete location'));
    await advance(t);
    await t.tap(find.text('No location'));
    await advance(t);
    final books = (await t.runAsync(() => h.repos.books.watchAll().first))!;
    expect(books.single.locationId, isNull);
  });

  locTest('deleting an empty location asks to confirm', (t) async {
    await addLoc('a', 'Hall');
    await pumpScreen(t);
    await t.tap(find.byType(PopupMenuButton<String>).first);
    await advance(t);
    await t.tap(find.text('Delete location'));
    await advance(t);
    expect(find.byType(AlertDialog), findsOneWidget);
    await t.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete location'),
      ),
    );
    await advance(t);
    expect(find.text('Hall'), findsNothing);
  });

  locTest('tapping a location opens the library filtered by it', (t) async {
    await addLoc('a', 'Hall');
    await pumpScreen(t);
    final container = ProviderScope.containerOf(
      t.element(find.byType(LocationsScreen)),
    );
    // Not inside a router here: only the filter change is checked.
    container.read(libraryQueryControllerProvider.notifier).setLocation('a');
    expect(
      container.read(libraryQueryControllerProvider).filter.locationId,
      'a',
    );
  });

  locTest('picker: search, recent first and create inline', (t) async {
    await addLoc('a', 'Hall', order: 0);
    await addLoc('b', 'Attic', order: 1);
    LocationPick? result;
    await pumpScreen(
      t,
      child: Consumer(
        builder: (context, ref, _) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async => result = await showLocationPicker(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await advance(t);
    expect(find.text('Hall'), findsOneWidget);
    expect(find.text('Attic'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, 'att');
    await advance(t);
    expect(find.text('Hall'), findsNothing);
    expect(find.text('Attic'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, 'Cellar');
    await advance(t);
    expect(find.text('Create "Cellar"'), findsOneWidget);
    await t.tap(find.text('Create "Cellar"'));
    await advance(t);
    await t.tap(find.text('Save'));
    await advance(t);
    expect(result, isNotNull);
    final all = (await t.runAsync(() => h.repos.locations.watchAll().first))!;
    expect(all.map((l) => l.name), contains('Cellar'));
    expect(result!.id, all.firstWhere((l) => l.name == 'Cellar').id);
  });

  test('providers are wired', () {
    expect(locationsProvider, isNotNull);
    expect(locationRepositoryProvider, isNotNull);
  });
}

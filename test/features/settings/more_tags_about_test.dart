import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/library_providers.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';
import 'package:kitabkhana/features/quotes/domain/quote.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';
import '../../helpers/repo_harness.dart';

void main() {
  late AddFlowHarness h;
  final now = DateTime(2025, 3, 10);

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<ProviderContainer> open(WidgetTester t, String at) async {
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 900),
      overrides: h.overrides,
    );
    routerOf(c).go(at);
    await t.pumpAndSettle();
    return c;
  }

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  Loan makeLoan(String bookId) => Loan.create(
    id: 'ln-$bookId',
    bookId: bookId,
    direction: LoanDirection.lent,
    personName: 'Priya',
    startedOn: now,
    now: now,
  );

  Location makeLoc() => Location.create(id: 'loc', name: 'Shelf', now: now);

  Future<void> book(String id, String title) =>
      h.repos.books.upsert(Book.create(id: id, title: title, now: now));

  group('More', () {
    testWidgets('groups its entries and shows live counts', (t) async {
      h = AddFlowHarness();
      await t.runAsync(() async {
        await book('a', 'Emma');
        await book('b', 'Dune');
        await h.repos.loans.startLoan(makeLoan('a'));
        await h.repos.quotes.upsert(
          Quote.create(id: 'q1', bookId: 'a', body: 'x', now: now),
        );
        await h.repos.quotes.upsert(
          Quote.create(id: 'q2', bookId: 'a', body: 'y', now: now),
        );
        await h.repos.locations.upsert(makeLoc());
        await h.repos.tags.createIfAbsent('one');
        await h.repos.tags.createIfAbsent('two');
        await h.repos.tags.createIfAbsent('three');
      });
      await open(t, '/more');
      expect(find.text('Your library'), findsOneWidget);
      expect(find.text('App'), findsOneWidget);
      for (final s in [
        'Loans',
        'Quotes',
        'Locations',
        'Tags',
        'Settings',
        'About',
      ]) {
        expect(find.text(s), findsWidgets, reason: s);
      }
      expect(find.text('1 out'), findsOneWidget);
      expect(find.text('2'), findsOneWidget, reason: 'two quotes');
      expect(find.text('3'), findsOneWidget, reason: 'three tags');
      await end(t);
    });

    testWidgets('no counts while there is nothing to count', (t) async {
      h = AddFlowHarness();
      await open(t, '/more');
      expect(find.textContaining(' out'), findsNothing);
      await end(t);
    });

    testWidgets('Settings and About open', (t) async {
      h = AddFlowHarness();
      final c = await open(t, '/more');
      await t.tap(find.text('Settings'));
      await t.pumpAndSettle();
      expect(locationOf(c), '/settings');
      routerOf(c).go('/more');
      await t.pumpAndSettle();
      await t.tap(find.text('About'));
      await t.pumpAndSettle();
      expect(locationOf(c), '/about');
      await end(t);
    });

    testWidgets('no overflow at 320dp and 200% text', (t) async {
      h = AddFlowHarness();
      final c = await pumpRouterApp(
        t,
        size: const Size(320, 640),
        textScale: 2,
        overrides: h.overrides,
      );
      routerOf(c).go('/more');
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await end(t);
    });
  });

  group('Tags', () {
    Future<void> seedTags() async {
      await book('a', 'Emma');
      await book('b', 'Dune');
      final sci = (await h.repos.tags.createIfAbsent('Sci-fi')).getOrNull()!;
      final classic = (await h.repos.tags.createIfAbsent('Classic'))
          .getOrNull()!;
      await h.repos.tags.createIfAbsent('Unused');
      await h.repos.tags.attach('a', classic.id);
      await h.repos.tags.attach('b', sci.id);
      await h.repos.tags.attach('a', sci.id);
    }

    testWidgets('lists tags with how many books carry each', (t) async {
      h = AddFlowHarness();
      await t.runAsync(seedTags);
      await open(t, '/tags');
      expect(find.text('Classic'), findsOneWidget);
      expect(find.text('Sci-fi'), findsOneWidget);
      expect(find.text('Unused'), findsOneWidget);
      expect(find.text('1 book'), findsOneWidget);
      expect(find.text('2 books'), findsOneWidget);
      expect(find.text('No books'), findsOneWidget);
      await end(t);
    });

    testWidgets('empty state', (t) async {
      h = AddFlowHarness();
      await open(t, '/tags');
      expect(find.text('No tags yet'), findsOneWidget);
      await end(t);
    });

    testWidgets('tapping a tag shows its books in the library', (t) async {
      h = AddFlowHarness();
      await t.runAsync(seedTags);
      final c = await open(t, '/tags');
      await t.tap(find.text('Sci-fi'));
      await t.pumpAndSettle();
      expect(locationOf(c), '/library');
      final tagId = c.read(libraryQueryControllerProvider).filter.tagId;
      expect(tagId, isNotNull);
      await end(t);
    });

    testWidgets('rename changes the name; a taken name is refused', (t) async {
      h = AddFlowHarness();
      await t.runAsync(seedTags);
      await open(t, '/tags');
      Future<void> renameTo(String from, String to) async {
        await t.tap(
          find.descendant(
            of: find.widgetWithText(ListTile, from),
            matching: find.byTooltip('More'),
          ),
        );
        await t.pumpAndSettle();
        await t.tap(find.text('Rename'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField), to);
        await t.tap(find.text('Save'));
        await t.pumpAndSettle();
      }

      await renameTo('Unused', 'Spare');
      expect(find.text('Spare'), findsOneWidget);
      expect(find.text('Unused'), findsNothing);

      await renameTo('Spare', 'classic');
      expect(
        find.text('You already have a tag with that name.'),
        findsOneWidget,
      );
      expect(find.text('Spare'), findsOneWidget);
      await end(t);
    });

    testWidgets('delete asks first and removes the tag from its books', (
      t,
    ) async {
      h = AddFlowHarness();
      await t.runAsync(seedTags);
      await open(t, '/tags');
      await t.tap(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Sci-fi'),
          matching: find.byTooltip('More'),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Delete'));
      await t.pumpAndSettle();
      expect(find.text('Delete this tag?'), findsOneWidget);
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(find.text('Sci-fi'), findsOneWidget);

      await t.tap(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Sci-fi'),
          matching: find.byTooltip('More'),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Delete'));
      await t.pumpAndSettle();
      await t.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete'),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Tag deleted'), findsOneWidget);
      expect(find.text('Sci-fi'), findsNothing);
      expect(
        find.text('1 book'),
        findsOneWidget,
        reason: 'Classic keeps its book',
      );
      await end(t);
    });
  });

  group('About', () {
    testWidgets('shows the version and licences, no privacy link by default', (
      t,
    ) async {
      h = AddFlowHarness();
      await open(t, '/about');
      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.text('Open-source licenses'), findsOneWidget);
      expect(find.text('Privacy policy'), findsNothing);
      expect(find.text('Made with care'), findsOneWidget);
      await t.tap(find.text('Open-source licenses'));
      await t.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
      await end(t);
    });
  });

  group('tag repository', () {
    late RepoHarness r;
    setUp(() => r = RepoHarness());
    tearDown(() => r.db.close());

    test('counts only live books and live links', () async {
      final a = await r.addBook(title: 'A');
      final b = await r.addBook(title: 'B');
      final tag = (await r.tags.createIfAbsent('x')).getOrNull()!;
      await r.tags.attach(a.id, tag.id);
      await r.tags.attach(b.id, tag.id);
      expect((await r.tags.watchWithCounts().first).single.books, 2);
      await r.books.softDelete(b.id);
      expect((await r.tags.watchWithCounts().first).single.books, 1);
      await r.tags.detach(a.id, tag.id);
      expect((await r.tags.watchWithCounts().first).single.books, 0);
    });

    test(
      'rename trims, bumps rev, and refuses blank, taken and missing',
      () async {
        final tag = (await r.tags.createIfAbsent('Old')).getOrNull()!;
        await r.tags.createIfAbsent('Other');
        final renamed = (await r.tags.rename(tag.id, '  New  ')).getOrNull()!;
        expect(renamed.name, 'New');
        expect(renamed.rev, tag.rev + 1);
        expect(
          ((await r.tags.rename(tag.id, '  ')) as Err).failure,
          isA<ValidationFailure>(),
        );
        expect(
          ((await r.tags.rename(tag.id, 'OTHER')) as Err).failure,
          isA<ConflictFailure>(),
        );
        expect(
          ((await r.tags.rename('nope', 'x')) as Err).failure,
          isA<NotFoundFailure>(),
        );
        // Same name (even different case of itself) is allowed.
        expect((await r.tags.rename(tag.id, 'new')).isOk, isTrue);
      },
    );
  });
}

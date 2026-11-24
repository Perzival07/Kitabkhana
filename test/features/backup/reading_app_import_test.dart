import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/backup_providers.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/features/backup/application/reading_app_import.dart';
import 'package:kitabkhana/features/library/data/book_mapper.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/fake_backup_file_picker.dart';
import '../../helpers/pump_router_app.dart';
import '../../helpers/repo_harness.dart';

/// The header and a few rows as Goodreads writes them.
const String goodreadsCsv =
    'Book Id,Title,Author,Author l-f,Additional Authors,ISBN,ISBN13,My Rating,'
    'Average Rating,Publisher,Binding,Number of Pages,Year Published,'
    'Original Publication Year,Date Read,Date Added,Bookshelves,'
    'Bookshelves with positions,Exclusive Shelf,My Review,Spoiler,'
    'Private Notes,Read Count,Owned Copies\n'
    '1,Dune,Frank Herbert,"Herbert, Frank",,"=""0441013597""",'
    '"=""9780441013593""",5,4.27,Ace,Paperback,604,2005,1965,2024/03/02,'
    '2024/01/10,"classics, sci-fi","classics (#1), sci-fi (#3)",read,,,'
    '"Gift from Priya",1,1\n'
    '2,"Godaan",Premchand,"Premchand, ",,"=""""","=""""",0,4.1,,,344,,1936,,'
    '2024/02/01,,,currently-reading,,,,0,0\n'
    '3,Piranesi,Susanna Clarke,"Clarke, Susanna",,"=""""",'
    '"=""9781635575637""",0,4.2,,,272,,2020,,2024/02/01,to-read,'
    'to-read (#4),to-read,,,,0,0\n'
    '4,,No title,,,,,0,,,,,,,,,,,to-read,,,,0,0\n';

/// The header and rows as StoryGraph writes them.
const String storygraphCsv =
    'Title,Authors,Contributors,ISBN/UID,Format,Read Status,Date Added,'
    'Last Date Read,Dates Read,Read Count,Moods,Pace,'
    'Character- or Plot-Driven?,Strong Character Development?,'
    'Loveable Characters?,Diverse Characters?,Flawed Characters?,'
    'Star Rating,Review,Content Warnings,Content Warning Description,Tags,'
    'Owned?\n'
    'Middlemarch,George Eliot,,9780141439549,paperback,did-not-finish,'
    '2024/01/02,,,0,,,,,,,,,,,,,No\n'
    '"Good Omens","Terry Pratchett, Neil Gaiman",,9780060853983,paperback,'
    'read,2024/01/02,2024/04/20,2024/04/01-2024/04/20,1,funny,fast,,,,,,'
    '4.75,,,,"comfort, favourites",Yes\n'
    'Emma,Jane Austen,,sg-uid-123,ebook,to-read,2024/01/02,,,0,,,,,,,,,,,,,'
    'No\n';

void main() {
  group('parsing', () {
    test('Goodreads: shelves, ISBNs, ratings, dates, owned', () {
      final r = parseReadingAppCsv(goodreadsCsv);
      final export = (r as Ok<ReadingAppExport>).value;
      expect(export.app, ReadingApp.goodreads);
      expect(export.books, hasLength(3), reason: 'the untitled row is skipped');
      final dune = export.books[0];
      expect(dune.title, 'Dune');
      expect(dune.authors, 'Frank Herbert');
      expect(dune.isbn!.value, '9780441013593');
      expect(dune.pages, 604);
      expect(dune.status, ReadStatus.finished);
      expect(dune.rating, 5);
      expect(dune.finishedOn, DateTime(2024, 3, 2));
      expect(dune.owned, isTrue);
      expect(dune.tags, <String>['classics', 'sci-fi']);
      expect(dune.notes, 'Gift from Priya');
      final godaan = export.books[1];
      expect(godaan.isbn, isNull);
      expect(godaan.rating, isNull);
      expect(godaan.status, ReadStatus.reading);
      final piranesi = export.books[2];
      expect(piranesi.status, ReadStatus.want);
      expect(piranesi.tags, isEmpty, reason: 'exclusive shelves are not tags');
    });

    test('StoryGraph: statuses, quarter stars, tags, owned', () {
      final r = parseReadingAppCsv(storygraphCsv);
      final export = (r as Ok<ReadingAppExport>).value;
      expect(export.app, ReadingApp.storygraph);
      expect(export.books.map((b) => b.status), <ReadStatus>[
        ReadStatus.dropped,
        ReadStatus.finished,
        ReadStatus.want,
      ]);
      final omens = export.books[1];
      expect(omens.authors, 'Terry Pratchett, Neil Gaiman');
      expect(omens.rating, 5);
      expect(omens.finishedOn, DateTime(2024, 4, 20));
      expect(omens.tags, <String>['comfort', 'favourites']);
      expect(omens.owned, isTrue);
      expect(export.books[2].isbn, isNull, reason: 'a StoryGraph id');
    });

    test('a byte-order mark is fine', () {
      expect(
        parseReadingAppCsv('﻿$storygraphCsv'),
        isA<Ok<ReadingAppExport>>(),
      );
    });

    test('anything else is refused', () {
      expect(parseReadingAppCsv(''), isA<Err<ReadingAppExport>>());
      expect(
        parseReadingAppCsv('title,authors,isbn13\nDune,Frank Herbert,1\n'),
        isA<Err<ReadingAppExport>>(),
      );
    });
  });

  group('importing', () {
    late RepoHarness h;
    late ImportReadingApp use;

    setUp(() {
      h = RepoHarness();
      use = ImportReadingApp(books: h.books, tags: h.tags, clock: h.clock);
    });
    tearDown(() => h.db.close());

    ReadingAppExport goodreads() =>
        (parseReadingAppCsv(goodreadsCsv) as Ok<ReadingAppExport>).value;

    test('adds every new book with its details and tags', () async {
      final r = await use(goodreads(), wantToReadAs: Ownership.wishlist);
      expect((r as Ok<ReadingAppImportSummary>).value.added, 3);
      final books = {for (final b in await all(h)) b.title: b};
      final dune = books['Dune']!;
      expect(dune.status, ReadStatus.finished);
      expect(dune.currentPage, 604);
      expect(dune.rating, 5);
      expect(dune.finishedOn, DateTime(2024, 3, 2));
      expect(
        dune.coverUrl,
        contains('covers.openlibrary.org/b/isbn/9780441013593'),
      );
      expect(dune.ownership, Ownership.owned);
      expect(books['Godaan']!.ownership, Ownership.owned, reason: 'being read');
      expect(books['Piranesi']!.ownership, Ownership.wishlist);
      final tags = await h.tags.watchForBook(dune.id).first;
      expect(
        tags.map((t) => t.name),
        containsAll(<String>['classics', 'sci-fi']),
      );
    });

    test('want-to-read can go on the shelves instead', () async {
      await use(goodreads(), wantToReadAs: Ownership.owned);
      final piranesi = (await all(h)).firstWhere((b) => b.title == 'Piranesi');
      expect(piranesi.ownership, Ownership.owned);
    });

    test(
      'books already in the library are skipped, by ISBN or title',
      () async {
        await h.addBook(id: 'mine', title: 'Godaan', authors: 'Premchand');
        expect(await use.countExisting(goodreads()), 1);
        final first = await use(goodreads(), wantToReadAs: Ownership.wishlist);
        expect((first as Ok<ReadingAppImportSummary>).value.added, 2);
        expect(first.value.skipped, 1);
        final again = await use(goodreads(), wantToReadAs: Ownership.wishlist);
        expect((again as Ok<ReadingAppImportSummary>).value.added, 0);
        expect(again.value.skipped, 3);
        expect(await all(h), hasLength(3));
      },
    );
  });

  group('the flow in Settings', () {
    Future<(AddFlowHarness, FakeBackupFilePicker)> open(
      WidgetTester t,
      String file,
    ) async {
      final h = AddFlowHarness();
      addTearDown(h.dispose);
      final picker = FakeBackupFilePicker()
        ..next = Uint8List.fromList(utf8.encode(file));
      final c = await pumpRouterApp(
        t,
        size: const Size(420, 900),
        overrides: <Override>[
          ...h.overrides,
          backupFilePickerProvider.overrideWithValue(picker),
        ],
      );
      routerOf(c).go('/settings');
      await t.pumpAndSettle();
      await t.scrollUntilVisible(
        find.text('Import from Goodreads or StoryGraph'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Import from Goodreads or StoryGraph'));
      await settle(t);
      return (h, picker);
    }

    testWidgets('shows what is in the file and adds it', (t) async {
      final (h, _) = await open(t, storygraphCsv);
      expect(find.text('Import from StoryGraph'), findsOneWidget);
      expect(find.textContaining('3 books in the file'), findsOneWidget);
      expect(
        find.textContaining('1 book is on your want-to-read'),
        findsOneWidget,
      );
      await t.tap(find.text("On my wishlist (I don't own them)"));
      await settle(t);
      expect(find.text('Added 3 books'), findsOneWidget);
      final books = await t.runAsync(h.repos.allBooks);
      expect(
        books!.map((Book b) => b.title),
        containsAll(<String>['Emma', 'Good Omens']),
      );
    });

    testWidgets('a wrong file says so', (t) async {
      await open(t, 'just,some\ncsv,text\n');
      expect(
        find.text("This doesn't look like a Goodreads or StoryGraph export."),
        findsOneWidget,
      );
    });
  });
}

Future<List<Book>> all(RepoHarness h) async =>
    (await h.db.liveBooks().get()).map((r) => r.toDomain()).toList();

Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 4; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await t.pumpAndSettle();
  }
}

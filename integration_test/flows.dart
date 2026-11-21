import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/library_providers.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/backup/data/backup_store.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';
import 'package:kitabkhana/features/quotes/domain/quote.dart';
import 'package:kitabkhana/features/settings/domain/app_settings.dart'
    show LibraryView;

import '../test/helpers/fake_ocr_service.dart';
import '../test/helpers/test_images.dart';
import 'support.dart';

const String duneIsbn = '9780441013593';

/// A core journey: a name, the barcodes the fake scanner offers, and the
/// steps. Both runners (the ordinary tests and the device run) use this list.
class Journey {
  const Journey(this.name, this.run, {this.scanCodes = const <String>[]});

  final String name;
  final Future<void> Function(E2e e) run;
  final List<String> scanCodes;
}

final List<Journey> journeys = <Journey>[
  const Journey(
    '1. onboarding, then three books added three ways',
    onboardingAndAddThreeBooks,
  ),
  const Journey(
    '2. scan an owned book; find a book without a barcode by title',
    scanOwnedAndSearchByTitle,
    scanCodes: <String>[duneIsbn],
  ),
  const Journey(
    '3. lend, scan it as lent out, return it',
    lendScanReturn,
    scanCodes: <String>[duneIsbn],
  ),
  const Journey(
    '4. three days of reading, a streak, finish, stats',
    readThreeDaysAndFinish,
  ),
  const Journey('5. capture a quote from a photo', captureQuote),
  const Journey('6. back up, erase everything, restore', backupEraseRestore),
];

BookInfo _info(String title, String author, String isbn, {int pages = 300}) =>
    BookInfo(
      title: title,
      authors: <String>[author],
      pages: pages,
      isbn13: parseIsbn(isbn),
    );

/// Journey 1. First run: the introduction, starter places, then three books
/// added three ways (ISBN, title search, no ISBN at all), each put on a shelf.
Future<void> onboardingAndAddThreeBooks(E2e e) async {
  final t = e.t;
  e.h.source.onIsbn = () =>
      Ok(_info('Everything I Never Told You', 'Celeste Ng', '9780143127550'));
  e.h.source.onSearch = () => Ok(<BookInfo>[
    _info('The Remains of the Day', 'Kazuo Ishiguro', '9780679731726'),
  ]);

  await e.start('/onboarding');
  expect(find.text('Know what you own'), findsOneWidget);
  for (var i = 0; i < 3; i++) {
    await e.tapText('Next');
  }
  expect(find.text('Where do your books live?'), findsOneWidget);
  await e.tapAndWait('Use these places');
  expect(find.text('You are all set'), findsOneWidget);
  await e.tapText('Add your first book');
  expect(e.location, '/library/add');

  // Saves the open form onto the shelf called [place].
  Future<void> saveOn(String place) async {
    await e.tapText('No location');
    await e.tapText(place, last: true);
    await e.tapAndWait('Save');
  }

  // 1. By ISBN.
  await e.tapText('Type ISBN');
  await t.enterText(find.byType(TextField), '9780143127550');
  await t.pump();
  await e.tapAndWait('Look up');
  expect(e.location, '/library/add/preview');
  await saveOn('Living room shelf');
  expect(e.location, '/library');

  // The confirmation toast must not sit on top of the Add button.
  await e.advance();
  expect(find.byType(SnackBar), findsOneWidget);
  expect(
    t
        .getRect(find.byType(FloatingActionButton))
        .overlaps(t.getRect(find.byType(SnackBar))),
    isFalse,
    reason: 'the toast covers the Add button',
  );
  // 2. By title.
  await e.tapText('Add book');
  await e.tapText('Search by title');
  await t.enterText(find.byType(TextField), 'remains');
  await t.pump(const Duration(milliseconds: 400));
  await e.settleReal();
  await e.tapText('The Remains of the Day', last: true);
  expect(e.location, '/library/add/preview');
  await saveOn('Bedroom shelf');

  // 3. With no ISBN.
  await e.tapText('Add book');
  await e.tapText('Enter manually');
  await e.enter('Title', 'Pocket Atlas of Tides');
  await saveOn('Storage box');

  // The library shows all three, and each is on its shelf.
  final books = await t.runAsync(() => e.h.repos.allBooks());
  expect(books!.map((b) => b.title), hasLength(3));
  final places = {
    for (final l in (await t.runAsync(
      () => e.h.repos.locations.watchAll().first,
    ))!)
      l.id: l.name,
  };
  expect(
    {for (final b in books) b.title: places[b.locationId]},
    {
      'Everything I Never Told You': 'Living room shelf',
      'The Remains of the Day': 'Bedroom shelf',
      'Pocket Atlas of Tides': 'Storage box',
    },
  );

  await e.container
      .read(libraryViewControllerProvider.notifier)
      .set(LibraryView.list);
  await e.settleReal();
  for (final title in <String>[
    'Everything I Never Told You',
    'The Remains of the Day',
    'Pocket Atlas of Tides',
  ]) {
    expect(find.text(title), findsWidgets, reason: title);
  }
  for (final place in <String>[
    'Living room shelf',
    'Bedroom shelf',
    'Storage box',
  ]) {
    expect(find.text(place), findsWidgets, reason: place);
  }
}

Future<void> _scanTwice(E2e e, String code) async {
  // The scanner trusts a code only when it sees it twice.
  await e.t.tap(find.text('scan $code'));
  await e.settleReal();
  await e.t.tap(find.text('scan $code'));
  await e.settleReal();
}

Future<void> _seedDuneOnHall(E2e e) async {
  final now = e.h.clock.now();
  await e.t.runAsync(() async {
    await e.h.repos.locations.upsert(
      Location.create(id: 'hall', name: 'Hall', now: now),
    );
    await e.h.repos.books.upsert(
      Book.create(
        id: 'dune',
        title: 'Dune',
        authors: 'Frank Herbert',
        isbn13: parseIsbn(duneIsbn),
        locationId: 'hall',
        now: now,
      ),
    );
  });
}

/// Journey 2. Scanning a barcode of a book you own says so and where it is;
/// a book without a barcode is found by typing its title.
Future<void> scanOwnedAndSearchByTitle(E2e e) async {
  final t = e.t;
  await _seedDuneOnHall(e);
  await t.runAsync(
    () => e.h.repos.books.upsert(
      Book.create(
        id: 'atlas',
        title: 'Pocket Atlas of Tides',
        authors: 'M. Tidewell',
        locationId: 'hall',
        now: e.h.clock.now(),
      ),
    ),
  );

  await e.start('/scan');
  await _scanTwice(e, duneIsbn);
  expect(find.text('You own this'), findsOneWidget);
  expect(find.text('On Hall'), findsOneWidget);
  expect(find.text('Dune'), findsWidgets);
  await e.tapText('Scan another');
  expect(find.text('You own this'), findsNothing);

  // No barcode: type a title.
  await t.enterText(find.byType(TextField), 'Pocket Atlas of Tides');
  await t.testTextInput.receiveAction(TextInputAction.done);
  await e.settleReal();
  expect(find.text('You own this'), findsOneWidget);
  expect(find.text('Pocket Atlas of Tides'), findsWidgets);
  expect(find.text('On Hall'), findsOneWidget);
}

/// Journey 3. Lending a book shows who has it, a scan then says it is lent
/// out, and returning it puts it back where it was.
Future<void> lendScanReturn(E2e e) async {
  final t = e.t;
  await _seedDuneOnHall(e);
  await e.start('/book/dune');
  expect(find.text('Hall'), findsWidgets);

  await e.tapText('Lend');
  await t.enterText(find.widgetWithText(TextField, 'Lent to'), 'Priya');
  await t.pump();
  await e.tapAndWait('Save');
  expect(find.textContaining('Lent to Priya since'), findsOneWidget);
  expect(find.text('Lend'), findsNothing, reason: 'already lent');
  var book = (await t.runAsync(() => e.h.repos.books.getById('dune')))!
      .getOrNull()!;
  expect(book.locationId, isNull, reason: 'a lent book is not on its shelf');

  await e.router.go('/scan');
  await _scanTwice(e, duneIsbn);
  expect(find.text('Lent to Priya'), findsWidgets);
  await e.tapText('Scan another');

  await e.router.go('/book/dune');
  await e.tapAndWait('Return');
  book = (await t.runAsync(() => e.h.repos.books.getById('dune')))!
      .getOrNull()!;
  expect(book.locationId, 'hall');
  expect(find.text('Hall'), findsWidgets);
  expect(find.text('Lend'), findsOneWidget, reason: 'available again');
}

/// Journey 4. Update the page on three successive days: the streak reaches 3;
/// finish the book and the stats count it.
Future<void> readThreeDaysAndFinish(E2e e) async {
  final t = e.t;
  final clock = e.h.clock;
  clock.set(DateTime(2025, 3, 10, 9));
  await t.runAsync(() async {
    await e.h.repos.books.upsert(
      Book.create(
        id: 'mm',
        title: 'Middlemarch',
        authors: 'George Eliot',
        pages: 300,
        status: ReadStatus.reading,
        now: clock.now(),
      ).copyWith(startedOn: DateTime(2025, 3, 10)),
    );
    await e.h.repos.goals.setTarget(2025, 12);
  });

  for (var day = 0; day < 3; day++) {
    clock.set(DateTime(2025, 3, 10 + day, 9));
    await e.restart('/reading'); // a new day's launch
    await e.tapText('Update page');
    await t.enterText(find.byType(TextField), '${40 * (day + 1)}');
    await t.pump();
    await e.tapAndWait('Save');
    expect(find.text('Page ${40 * (day + 1)} of 300'), findsOneWidget);
    expect(find.text('${day + 1}-day streak'), findsOneWidget);
  }

  // Finish it.
  await e.router.go('/book/mm');
  await e.tap(find.widgetWithText(ChoiceChip, 'Finished'));
  await e.settleReal();
  final done = (await t.runAsync(() => e.h.repos.books.getById('mm')))!
      .getOrNull()!;
  expect(done.status, ReadStatus.finished);
  expect(done.finishedOn, DateTime(2025, 3, 12));

  await e.restart('/stats');
  expect(find.text('1 of 12 books'), findsOneWidget);
  await e.reveal(find.text('Longest read'));
  expect(find.text('300 pages'), findsOneWidget);
  expect(find.text('Middlemarch'), findsWidgets, reason: 'the longest read');
  await e.restart('/reading');
  expect(find.text('3-day streak'), findsOneWidget);
}

/// Journey 5. Photograph a page, pick the lines, save: the quote shows in
/// Quotes and on the book.
Future<void> captureQuote(E2e e) async {
  final t = e.t;
  await t.runAsync(
    () => e.h.repos.books.upsert(
      Book.create(
        id: 'jp',
        title: 'Pride and Prejudice',
        authors: 'Jane Austen',
        pages: 400,
        status: ReadStatus.reading,
        now: e.h.clock.now(),
      ).copyWith(currentPage: 1),
    ),
  );
  e.h.ocr = FakeOcrService(
    lines: <String>[
      'It is a truth universally ac-',
      'knowledged, that a single man',
      'Chapter 1',
    ],
  );
  e.h.picker.next = jpegBytes(60, 80);

  await e.start('/book/jp');
  await e.tapText('Snap a quote');
  await e.tapText('Choose a photo');
  // The crop step measures the photo for real.
  await e.settleReal(300);
  await e.tapAndWait('Read the text');
  await e.tapText('It is a truth universally ac-');
  await e.tapText('knowledged, that a single man');
  await e.tapText('Use selected lines');
  expect(
    find.text('It is a truth universally acknowledged, that a single man'),
    findsOneWidget,
  );
  await t.enterText(find.widgetWithText(TextField, 'Page (optional)'), '1');
  await t.pump();
  await e.tapAndWait('Save quote');

  await e.router.go('/quotes');
  await e.settleReal();
  expect(
    find.text('It is a truth universally acknowledged, that a single man'),
    findsOneWidget,
  );
  expect(find.text('— Pride and Prejudice, p. 1'), findsOneWidget);

  await e.router.go('/book/jp');
  await e.settleReal();
  expect(
    find.text('It is a truth universally acknowledged, that a single man'),
    findsOneWidget,
  );
  final saved = await t.runAsync(() => e.h.db.liveQuotes().get());
  expect(saved, hasLength(1));
}

/// Journey 6. Share a backup, erase everything, restore: everything is back.
Future<void> backupEraseRestore(E2e e) async {
  final t = e.t;
  final now = e.h.clock.now();
  await t.runAsync(() async {
    await e.h.repos.locations.upsert(
      Location.create(id: 'hall', name: 'Hall', now: now),
    );
    for (var i = 0; i < 4; i++) {
      await e.h.repos.books.upsert(
        Book.create(
          id: 'b$i',
          title: 'Book $i',
          authors: 'Author $i',
          pages: 100 + i,
          locationId: i.isEven ? 'hall' : null,
          now: now.add(Duration(minutes: i)),
        ),
      );
    }
    await e.h.repos.quotes.upsert(
      Quote.create(id: 'q', bookId: 'b0', body: 'Keep this line.', now: now),
    );
    await e.h.repos.goals.setTarget(2025, 12);
  });
  final before = await t.runAsync(() => BackupStore(e.h.db).readAll());

  // Back up (shared as a file).
  await e.start('/settings');
  await e.tapText('Share a backup');
  await e.tapAndWait('Create backup');
  expect(e.h.share.files, hasLength(1));
  expect(e.h.share.files.single.name, endsWith('.kitab'));
  final file = e.h.share.files.single.bytes;

  // Erase everything.
  await e.tapText('Erase all data');
  await e.tapText('Continue');
  await t.enterText(find.byType(TextField), 'DELETE');
  await t.pump();
  await e.tapAndWait('Erase everything');
  final empty = await t.runAsync(() => BackupStore(e.h.db).readAll());
  expect(empty!['books'], isEmpty);
  expect(empty['quotes'], isEmpty);
  expect(e.location, '/onboarding', reason: 'back to the start');

  // Restore.
  e.filePicker.next = file;
  await e.restart('/settings');
  await e.tapText('Restore from backup');
  await e.settleReal();
  await e.tapAndWait('Replace my library');
  await e.tapAndWait('Replace');
  expect(find.text('Imported 4 books, 0 loans, 1 quote.'), findsOneWidget);
  await e.tapText('OK');

  final after = await t.runAsync(() => BackupStore(e.h.db).readAll());
  for (final table in <String>['books', 'locations', 'quotes', 'goals']) {
    expect(after![table], before![table], reason: table);
  }
  await e.restart('/library');
  for (var i = 0; i < 4; i++) {
    expect(find.text('Book $i'), findsWidgets);
  }
}

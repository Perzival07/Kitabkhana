import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/backup/application/csv_export.dart';
import 'package:kitabkhana/features/backup/data/csv_store.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';

import '../../helpers/repo_harness.dart';

/// Reads CSV bytes back the way a spreadsheet would.
List<List<dynamic>> parse(Uint8List bytes) {
  var text = utf8.decode(bytes);
  if (text.startsWith('﻿')) text = text.substring(1);
  return Csv(autoDetect: false).decode(text);
}

void main() {
  group('encodeCsv', () {
    test('starts with a UTF-8 byte-order mark and uses CRLF', () {
      final bytes = encodeCsv([
        ['a', 'b'],
        ['1', '2'],
      ]);
      expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
      expect(utf8.decode(bytes.sublist(3)), 'a,b\r\n1,2');
    });

    test('quotes commas, doubles quotes, keeps newlines inside quotes', () {
      final rows = [
        ['plain', 'a, b', 'say "hi"', 'two\nlines', 'cr\r\nlf', ''],
      ];
      final bytes = encodeCsv(rows);
      final text = utf8.decode(bytes.sublist(3));
      expect(text, 'plain,"a, b","say ""hi""","two\nlines","cr\r\nlf",');
      expect(parse(bytes), [
        ['plain', 'a, b', 'say "hi"', 'two\nlines', 'cr\r\nlf', ''],
      ]);
    });

    test('Hindi, Bengali, accents and emoji survive a round trip', () {
      final rows = [
        ['किताबें', 'বই', 'Café — naïve', '📚'],
        ['तीसरी कसम, फणीश्वरनाथ', 'পথের পাঁচালী', 'ß', '"चाँद"'],
      ];
      expect(parse(encodeCsv(rows)), rows);
    });

    test('numbers are not quoted', () {
      final text = utf8.decode(
        encodeCsv([
          ['t', 5, null],
        ]).sublist(3),
      );
      expect(text, 't,5,');
    });
  });

  group('spreadsheetSafe', () {
    test('formula-like text gets an apostrophe', () {
      for (final t in ['=1+1', '+5', '@SUM(A1)', '-cmd', '\tx', '\rx']) {
        expect(spreadsheetSafe(t), "'$t");
      }
    });

    test('ordinary text, numbers and negatives are left alone', () {
      for (final t in ['Dune', '', '-5', '-0.5', '1984', 'a=b', 'Mr. -X']) {
        expect(spreadsheetSafe(t), t);
      }
    });
  });

  group('library export', () {
    late RepoHarness h;
    late ExportCsv export;

    setUp(() {
      h = RepoHarness();
      export = ExportCsv(CsvStore(h.db));
    });
    tearDown(() => h.db.close());

    Future<(List<List<dynamic>>, List<List<dynamic>>)> run() async {
      final files = (await export()).getOrNull()!;
      expect(files.map((f) => f.name), ['books.csv', 'loans.csv']);
      return (parse(files[0].bytes), parse(files[1].bytes));
    }

    test('an empty library is just the headers', () async {
      final (books, loans) = await run();
      expect(books, [booksCsvHeader]);
      expect(loans, [loansCsvHeader]);
    });

    test(
      'books: columns, location path, tags, dates, no deleted ones',
      () async {
        final room = await h.addLocation(name: 'Living room');
        final shelf = await h.addLocation(name: 'Top shelf', parentId: room.id);
        final dune = await h.addBook(
          title: 'Dune, Part "One"',
          authors: 'Frank Herbert, Brian Herbert',
          pages: 612,
          rating: 5,
          status: ReadStatus.finished,
          locationId: shelf.id,
          tweak: (b) => b.copyWith(
            startedOn: DateTime(2025, 1, 2),
            finishedOn: DateTime(2025, 2, 1),
          ),
        );
        final t1 = (await h.tags.createIfAbsent('sci-fi')).getOrNull()!;
        final t2 = (await h.tags.createIfAbsent('Classic')).getOrNull()!;
        await h.tags.attach(dune.id, t1.id);
        await h.tags.attach(dune.id, t2.id);
        await h.addBook(title: 'Alpha', ownership: Ownership.wishlist);
        final gone = await h.addBook(title: 'Gone');
        await h.books.softDelete(gone.id);

        final (books, _) = await run();
        expect(books.first, booksCsvHeader);
        expect(books, hasLength(3));
        expect(books[1][0], 'Alpha', reason: 'sorted by title');
        expect(books[1][4], 'wishlist');
        expect(books[1][5], '');
        final row = books[2];
        expect(row[0], 'Dune, Part "One"');
        expect(row[1], 'Frank Herbert, Brian Herbert');
        expect(row[3], 'finished');
        expect(row[4], 'owned');
        expect(row[5], 'Living room / Top shelf');
        expect(row[6], '5');
        expect(row[7], '612');
        expect(row[8], '2025-01-02');
        expect(row[9], '2025-02-01');
        expect(row[10], 'Classic; sci-fi');
      },
    );

    test('a title that looks like a formula is defused', () async {
      await h.addBook(title: '=HYPERLINK("http://x")');
      final (books, _) = await run();
      expect(books[1][0], '\'=HYPERLINK("http://x")');
    });

    test('loans: newest first with book and person', () async {
      final a = await h.addBook(title: 'Emma', authors: 'Jane Austen');
      final b = await h.addBook(title: 'Dune');
      h.tick();
      await h.loans.create(
        h.newLoan(
          id: 'l1',
          bookId: a.id,
          person: 'Priya, S.',
          startedOn: DateTime(2025, 2, 1),
          dueOn: DateTime(2025, 3, 1),
        ),
      );
      await h.loans.create(
        h.newLoan(
          id: 'l2',
          bookId: b.id,
          direction: LoanDirection.borrowed,
          person: 'रवि',
          startedOn: DateTime(2025, 3, 5),
        ),
      );
      await h.loans.finishLoan('l1', DateTime(2025, 3, 9));
      final (_, loans) = await run();
      expect(loans, hasLength(3));
      expect(loans[1][0], 'Dune');
      expect(loans[1][2], 'borrowed');
      expect(loans[1][3], 'रवि');
      expect(loans[1][7], '');
      expect(loans[2][0], 'Emma');
      expect(loans[2][1], 'Jane Austen');
      expect(loans[2][2], 'lent');
      expect(loans[2][3], 'Priya, S.');
      expect(loans[2][5], '2025-02-01');
      expect(loans[2][6], '2025-03-01');
      expect(loans[2][7], '2025-03-09');
    });

    test('a deleted book takes its loans out of the file', () async {
      final a = await h.addBook(title: 'Emma');
      await h.addLoan(bookId: a.id);
      await h.books.softDelete(a.id);
      final (_, loans) = await run();
      expect(loans, [loansCsvHeader]);
    });
  });
}

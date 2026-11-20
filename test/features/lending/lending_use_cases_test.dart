import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/features/lending/application/lending_use_cases.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/lending/domain/loan_repository.dart';
import 'package:kitabkhana/features/lending/domain/reminder_service.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';

import '../../helpers/repo_harness.dart';

class _Reminders implements ReminderService {
  final List<String> scheduled = <String>[];
  final List<String> cancelled = <String>[];
  bool fail = false;

  @override
  Future<void> schedule(Loan loan, String bookTitle) async {
    if (fail) throw StateError('no');
    scheduled.add('${loan.id}:$bookTitle');
  }

  @override
  Future<void> cancel(String loanId) async => cancelled.add(loanId);
}

void main() {
  late RepoHarness h;
  late _Reminders reminders;
  late LendBook lend;
  late RecordBorrowedBook borrow;
  late ReturnLoan ret;
  late ExtendDueDate extend;
  var n = 0;

  setUp(() {
    h = RepoHarness();
    reminders = _Reminders();
    lend = LendBook(
      loans: h.loans,
      books: h.books,
      clock: h.clock,
      reminders: reminders,
      newId: () => 'loan${n++}',
    );
    borrow = RecordBorrowedBook(
      loans: h.loans,
      books: h.books,
      clock: h.clock,
      reminders: reminders,
      newId: () => 'loan${n++}',
    );
    ret = ReturnLoan(
      loans: h.loans,
      locations: h.locations,
      clock: h.clock,
      reminders: reminders,
    );
    extend = ExtendDueDate(
      loans: h.loans,
      books: h.books,
      clock: h.clock,
      reminders: reminders,
    );
  });
  tearDown(() => h.db.close());

  Future<Book> book({
    String id = 'b1',
    String? locationId,
    Ownership ownership = Ownership.owned,
  }) async => (await h.books.upsert(
    Book.create(
      id: id,
      title: 'Dune',
      now: h.clock.now(),
      locationId: locationId,
      ownership: ownership,
    ),
  )).getOrNull()!;

  Future<void> place(String id) async {
    await h.locations.upsert(
      Location.create(id: id, name: 'Place $id', now: h.clock.now()),
    );
  }

  Future<Book> reload(String id) async =>
      (await h.books.getById(id)).getOrNull()!;

  group('LendBook', () {
    test('creates the loan, clears the location, remembers it', () async {
      await place('shelf');
      await book(locationId: 'shelf');
      final r = await lend(
        bookId: 'b1',
        personName: '  Priya ',
        personPhone: '98765 43210',
        dueOn: DateTime(2025, 3, 24),
      );
      final loan = r.getOrNull()!;
      expect(loan.personName, 'Priya');
      expect(loan.direction, LoanDirection.lent);
      expect(loan.previousLocationId, 'shelf');
      expect(loan.startedOn, DateTime(2025, 3, 10));
      expect((await reload('b1')).locationId, isNull);
      expect(reminders.scheduled, <String>['${loan.id}:Dune']);
    });

    test('a second lend is a conflict and changes nothing', () async {
      await place('shelf');
      await book(locationId: 'shelf');
      await lend(bookId: 'b1', personName: 'Priya');
      final r = await lend(bookId: 'b1', personName: 'Rahul');
      expect(r, isA<Err<Loan>>());
      expect((r as Err<Loan>).failure, isA<ConflictFailure>());
      final active = (await h.loans.activeFor('b1')).getOrNull()!;
      expect(active.personName, 'Priya');
      expect(active.previousLocationId, 'shelf');
    });

    test(
      'a name is required and the due date cannot precede the start',
      () async {
        await book();
        expect(await lend(bookId: 'b1', personName: '  '), isA<Err<Loan>>());
        expect(
          await lend(
            bookId: 'b1',
            personName: 'A',
            dueOn: DateTime(2025, 3, 1),
          ),
          isA<Err<Loan>>(),
        );
        expect((await h.loans.activeFor('b1')).getOrNull(), isNull);
      },
    );

    test('a missing book is not found', () async {
      final r = await lend(bookId: 'nope', personName: 'A');
      expect((r as Err<Loan>).failure, isA<NotFoundFailure>());
    });

    test('a failing reminder never fails the loan', () async {
      await book();
      reminders.fail = true;
      expect(await lend(bookId: 'b1', personName: 'A'), isA<Ok<Loan>>());
    });
  });

  group('ReturnLoan', () {
    test('restores the previous location', () async {
      await place('shelf');
      await book(locationId: 'shelf');
      final loan = (await lend(bookId: 'b1', personName: 'A')).getOrNull()!;
      final r = await ret(loan);
      expect(r.getOrNull(), isA<Returned>());
      expect((await reload('b1')).locationId, 'shelf');
      expect((await h.loans.activeFor('b1')).getOrNull(), isNull);
      expect(reminders.cancelled, <String>[loan.id]);
    });

    test('a book that had no location comes back with none', () async {
      await book();
      final loan = (await lend(bookId: 'b1', personName: 'A')).getOrNull()!;
      expect((await ret(loan)).getOrNull(), isA<Returned>());
      expect((await reload('b1')).locationId, isNull);
    });

    test(
      'previous location deleted: asks, saves nothing until answered',
      () async {
        await place('shelf');
        await place('other');
        await book(locationId: 'shelf');
        final loan = (await lend(bookId: 'b1', personName: 'A')).getOrNull()!;
        await h.locations.softDelete('shelf');

        final first = (await ret(loan)).getOrNull();
        expect(first, isA<NeedsLocation>());
        expect((await h.loans.activeFor('b1')).getOrNull(), isNotNull);
        expect(reminders.cancelled, isEmpty);

        final second = await ret(
          loan,
          chosenLocationId: 'other',
          askedForLocation: true,
        );
        expect(second.getOrNull(), isA<Returned>());
        expect((await reload('b1')).locationId, 'other');
      },
    );

    test('previous location deleted and "no location" chosen', () async {
      await place('shelf');
      await book(locationId: 'shelf');
      final loan = (await lend(bookId: 'b1', personName: 'A')).getOrNull()!;
      await h.locations.softDelete('shelf');
      final r = await ret(loan, askedForLocation: true);
      expect(r.getOrNull(), isA<Returned>());
      expect((await reload('b1')).locationId, isNull);
    });

    test('returning twice is a conflict', () async {
      await book();
      final loan = (await lend(bookId: 'b1', personName: 'A')).getOrNull()!;
      await ret(loan);
      expect((await ret(loan)) is Err<ReturnOutcome>, isTrue);
    });
  });

  group('borrowed books', () {
    test('recording marks the book borrowed', () async {
      await book(ownership: Ownership.wishlist);
      final r = await borrow(bookId: 'b1', personName: 'Rahul');
      expect(r.getOrNull()!.direction, LoanDirection.borrowed);
      expect((await reload('b1')).ownership, Ownership.borrowed);
    });

    test('a borrowed book cannot also be lent', () async {
      await book();
      await borrow(bookId: 'b1', personName: 'Rahul');
      expect(await lend(bookId: 'b1', personName: 'A'), isA<Err<Loan>>());
    });

    test('return and remove from library', () async {
      await book();
      final loan = (await borrow(
        bookId: 'b1',
        personName: 'Rahul',
      )).getOrNull()!;
      expect((await ret(loan)).getOrNull(), isA<Returned>());
      expect((await h.books.getById('b1')).getOrNull(), isNull);
    });

    test('return and keep as wishlist', () async {
      await book();
      final loan = (await borrow(
        bookId: 'b1',
        personName: 'Rahul',
      )).getOrNull()!;
      await ret(loan, borrowedAction: BorrowedReturnAction.keepAsWishlist);
      final b = await reload('b1');
      expect(b.ownership, Ownership.wishlist);
    });
  });

  group('ExtendDueDate', () {
    test('moves the date and reschedules', () async {
      await book();
      final loan = (await lend(
        bookId: 'b1',
        personName: 'A',
        dueOn: DateTime(2025, 3, 20),
      )).getOrNull()!;
      final r = await extend(loan, DateTime(2025, 4, 3));
      expect(r.getOrNull()!.dueOn, DateTime(2025, 4, 3));
      expect(reminders.scheduled.length, 2);
    });

    test('cannot end before it started', () async {
      await book();
      final loan = (await lend(bookId: 'b1', personName: 'A')).getOrNull()!;
      expect(await extend(loan, DateTime(2025, 3, 1)), isA<Err<Loan>>());
    });
  });

  test('recentPeople lists names, newest first, once each', () async {
    await book(id: 'b1');
    await book(id: 'b2');
    await lend(bookId: 'b1', personName: 'Priya');
    h.clock.advance(const Duration(days: 1));
    await lend(bookId: 'b2', personName: 'Rahul');
    final people = await h.loans.recentPeople();
    expect(people, <String>['Rahul', 'Priya']);
  });
}

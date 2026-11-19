import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;

  setUp(() async {
    h = RepoHarness();
    await h.addBook(id: 'b1', title: 'One');
    await h.addBook(id: 'b2', title: 'Two');
    await h.addBook(id: 'b3', title: 'Three');
  });
  tearDown(() => h.dispose());

  final today = DateTime(2025, 3, 10);

  test('create stores the loan with rev 1', () async {
    final loan = await h.addLoan(bookId: 'b1', dueOn: DateTime(2025, 3, 20));
    expect(loan.rev, 1);
    expect(loan.isActive, isTrue);
    expect(loan.dueOn, DateTime(2025, 3, 20));
    expect(loan.startedOn, today);
    expect((await h.loans.activeFor('b1')).getOrNull()!.id, loan.id);
    expect((await h.loans.activeFor('b2')).getOrNull(), isNull);
  });

  test('a book cannot be lent twice (ConflictFailure)', () async {
    await h.addLoan(bookId: 'b1');
    final r = await h.loans.create(h.newLoan(bookId: 'b1'));
    final f = r.failureOrNull();
    expect(f, isA<ConflictFailure>());
    expect(f!.messageKey, 'failureBookAlreadyLent');
    expect((await h.loans.watchActive().first), hasLength(1));
  });

  test('borrowing a book that is already out also conflicts', () async {
    await h.addLoan(bookId: 'b1');
    final r = await h.loans.create(
      h.newLoan(bookId: 'b1', direction: LoanDirection.borrowed),
    );
    expect(r.failureOrNull(), isA<ConflictFailure>());
  });

  test('after a return the book can be lent again', () async {
    final first = await h.addLoan(bookId: 'b1');
    await h.loans.markReturned(first.id, today);
    expect((await h.loans.create(h.newLoan(bookId: 'b1'))).isOk, isTrue);
  });

  test('create for a missing or deleted book is NotFound', () async {
    expect(
      (await h.loans.create(h.newLoan(bookId: 'nope'))).failureOrNull(),
      isA<NotFoundFailure>(),
    );
    await h.books.softDelete('b2');
    expect(
      (await h.loans.create(h.newLoan(bookId: 'b2'))).failureOrNull(),
      isA<NotFoundFailure>(),
    );
  });

  group('markReturned', () {
    test('sets returnedOn and bumps rev', () async {
      final loan = await h.addLoan(bookId: 'b1');
      final done = (await h.loans.markReturned(
        loan.id,
        DateTime(2025, 3, 12),
      )).getOrNull()!;
      expect(done.returnedOn, DateTime(2025, 3, 12));
      expect(done.isActive, isFalse);
      expect(done.rev, 2);
      expect((await h.loans.activeFor('b1')).getOrNull(), isNull);
    });

    test('missing is NotFound, double return is a Conflict', () async {
      expect(
        (await h.loans.markReturned('nope', today)).failureOrNull(),
        isA<NotFoundFailure>(),
      );
      final loan = await h.addLoan(bookId: 'b1');
      await h.loans.markReturned(loan.id, today);
      expect(
        (await h.loans.markReturned(loan.id, today)).failureOrNull(),
        isA<ConflictFailure>(),
      );
    });
  });

  group('update', () {
    test('extends the due date', () async {
      final loan = await h.addLoan(bookId: 'b1', dueOn: DateTime(2025, 3, 15));
      final r = await h.loans.update(
        loan.copyWith(dueOn: DateTime(2025, 4, 1)),
      );
      expect(r.getOrNull()!.dueOn, DateTime(2025, 4, 1));
      expect(r.getOrNull()!.rev, 2);
    });

    test('clearing the due date works', () async {
      final loan = await h.addLoan(bookId: 'b1', dueOn: DateTime(2025, 3, 15));
      final r = await h.loans.update(loan.copyWith(dueOn: null));
      expect(r.getOrNull()!.dueOn, isNull);
    });

    test('missing loan is NotFound', () async {
      final ghost = h.newLoan(bookId: 'b1', id: 'ghost');
      expect(
        (await h.loans.update(ghost)).failureOrNull(),
        isA<NotFoundFailure>(),
      );
    });

    test('un-returning a loan on a book that is out again conflicts', () async {
      final first = await h.addLoan(bookId: 'b1');
      await h.loans.markReturned(first.id, today);
      await h.addLoan(bookId: 'b1');
      final r = await h.loans.update(first.copyWith(returnedOn: null));
      expect(r.failureOrNull(), isA<ConflictFailure>());
    });
  });

  group('lists', () {
    test(
      'watchActive: soonest due first, undated last, no returned loans',
      () async {
        final late = await h.addLoan(bookId: 'b1', dueOn: DateTime(2025, 4, 1));
        final soon = await h.addLoan(
          bookId: 'b2',
          dueOn: DateTime(2025, 3, 12),
        );
        final undated = await h.addLoan(bookId: 'b3');
        final list = await h.loans.watchActive().first;
        expect(list.map((l) => l.id), [soon.id, late.id, undated.id]);
        await h.loans.markReturned(soon.id, today);
        expect((await h.loans.watchActive().first).map((l) => l.id), [
          late.id,
          undated.id,
        ]);
      },
    );

    test('loans of deleted books are hidden', () async {
      await h.addLoan(bookId: 'b1');
      await h.books.softDelete('b1');
      expect(await h.loans.watchActive().first, isEmpty);
    });

    test(
      'watchOverdue uses the clock: yesterday yes, today and later no',
      () async {
        final yesterday = await h.addLoan(
          bookId: 'b1',
          dueOn: DateTime(2025, 3, 9),
        );
        await h.addLoan(bookId: 'b2', dueOn: DateTime(2025, 3, 10));
        await h.addLoan(bookId: 'b3', dueOn: DateTime(2025, 3, 11));
        expect((await h.loans.watchOverdue().first).map((l) => l.id), [
          yesterday.id,
        ]);
        expect(yesterday.isOverdue(today), isTrue);
      },
    );

    test('returned loans are never overdue', () async {
      final l = await h.addLoan(bookId: 'b1', dueOn: DateTime(2025, 3, 1));
      await h.loans.markReturned(l.id, today);
      expect(await h.loans.watchOverdue().first, isEmpty);
    });

    test('watchHistory lists returned loans, latest return first', () async {
      final a = await h.addLoan(bookId: 'b1');
      final b = await h.addLoan(bookId: 'b2');
      await h.addLoan(bookId: 'b3');
      await h.loans.markReturned(a.id, DateTime(2025, 3, 5));
      await h.loans.markReturned(b.id, DateTime(2025, 3, 8));
      expect((await h.loans.watchHistory().first).map((l) => l.id), [
        b.id,
        a.id,
      ]);
    });

    test('streams are live', () async {
      final seen = <int>[];
      final sub = h.loans.watchActive().listen((l) => seen.add(l.length));
      await pumpEventQueue();
      final l = await h.addLoan(bookId: 'b1');
      await pumpEventQueue();
      await h.loans.markReturned(l.id, today);
      await pumpEventQueue();
      await sub.cancel();
      expect(seen, [0, 1, 0]);
    });
  });

  test('previous location is stored for restore on return', () async {
    final loc = await h.addLocation(name: 'Shelf');
    final r = await h.loans.create(
      h.newLoan(bookId: 'b1', previousLocationId: loc.id),
    );
    expect(r.getOrNull()!.previousLocationId, loc.id);
  });
}

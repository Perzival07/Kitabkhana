import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';
import 'package:kitabkhana/features/quotes/domain/quote.dart';
import 'package:kitabkhana/features/reading/domain/reading_log.dart';
import 'package:kitabkhana/features/stats/domain/goal.dart';
import 'package:kitabkhana/features/tags/domain/tag.dart';

void main() {
  final now = DateTime(2025, 3, 10, 9);

  group('Book', () {
    Book make() => Book.create(
      id: 'a',
      title: 'The Hobbit',
      authors: 'J. R. R. Tolkien',
      now: now,
      pages: 300,
    );

    test('create computes the title key and sensible defaults', () {
      final b = make();
      expect(b.titleKey.value, 'hobbit|tolkien');
      expect(b.ownership, Ownership.owned);
      expect(b.status, ReadStatus.want);
      expect(b.currentPage, 0);
      expect(b.rev, 1);
      expect(b.isDeleted, isFalse);
      expect(b.createdAt, b.updatedAt);
    });

    test('equality is by value', () {
      expect(make(), make());
      expect(make().hashCode, make().hashCode);
      expect(make(), isNot(make().copyWith(notes: 'x')));
    });

    test('copyWith changes only what is asked, including setting null', () {
      final b = make().copyWith(rating: 4, subtitle: 'There and Back Again');
      expect(b.rating, 4);
      expect(b.copyWith(title: 'X').rating, 4);
      expect(b.copyWith(rating: null).rating, isNull);
      expect(b.copyWith(subtitle: null).subtitle, isNull);
      expect(b.copyWith().subtitle, 'There and Back Again');
      expect(b.copyWith(isbn13: parseIsbn('9780143127550')).isbn13, isNotNull);
      expect(b.id, 'a');
    });

    test('editing title or authors keeps the title key in sync', () {
      final b = make();
      expect(b.copyWith(title: 'Dune').titleKey.value, 'dune|tolkien');
      expect(
        b.copyWith(authors: 'Frank Herbert').titleKey.value,
        'hobbit|herbert',
      );
      expect(
        b.copyWith(title: 'Dune', authors: 'Frank Herbert').titleKey.value,
        'dune|herbert',
      );
      expect(b.copyWith(notes: 'x').titleKey, b.titleKey);
    });

    test('progress handles unknown and clamps', () {
      expect(make().progress, 0);
      expect(make().copyWith(currentPage: 150).progress, 0.5);
      expect(make().copyWith(currentPage: 999).progress, 1);
      expect(make().copyWith(pages: null).progress, isNull);
    });

    test('deletedAt marks it deleted and can be cleared', () {
      final d = make().copyWith(deletedAt: now);
      expect(d.isDeleted, isTrue);
      expect(d.copyWith(deletedAt: null).isDeleted, isFalse);
    });
  });

  group('Loan', () {
    Loan make({DateTime? due}) => Loan.create(
      id: 'l',
      bookId: 'b',
      direction: LoanDirection.lent,
      personName: 'Priya',
      startedOn: DateTime(2025, 3, 1),
      dueOn: due,
      now: now,
    );

    test('overdue only when active, dated and before today', () {
      final today = DateTime(2025, 3, 10);
      expect(make(due: DateTime(2025, 3, 9)).isOverdue(today), isTrue);
      expect(make(due: DateTime(2025, 3, 10)).isOverdue(today), isFalse);
      expect(make().isOverdue(today), isFalse);
      expect(
        make(due: DateTime(2025, 3, 9))
            .copyWith(returnedOn: DateTime(2025, 3, 9))
            .isOverdue(today),
        isFalse,
      );
    });

    test('equality and copyWith', () {
      expect(make(), make());
      expect(make().copyWith(personName: 'Raj'), isNot(make()));
      expect(
        make(due: DateTime(2025, 4, 1)).copyWith(dueOn: null).dueOn,
        isNull,
      );
      expect(make().isActive, isTrue);
    });
  });

  test('Location, Quote, Goal, Tag, ReadingLog copyWith and equality', () {
    final l = Location.create(id: 'l', name: 'Shelf', now: now);
    expect(l, Location.create(id: 'l', name: 'Shelf', now: now));
    expect(l.copyWith(name: 'Box').name, 'Box');
    expect(l.copyWith(parentId: 'p').copyWith(parentId: null).parentId, isNull);
    expect(l.hashCode, isNotNull);

    final q = Quote.create(id: 'q', bookId: 'b', body: 'x', now: now, page: 3);
    expect(q.copyWith(page: null).page, isNull);
    expect(q.copyWith(isFavourite: true).isFavourite, isTrue);
    expect(q, Quote.create(id: 'q', bookId: 'b', body: 'x', now: now, page: 3));

    final g = Goal.create(id: 'g', year: 2025, targetBooks: 10, now: now);
    expect(g.copyWith(targetBooks: 12).targetBooks, 12);
    expect(g.year, 2025);
    expect(g, Goal.create(id: 'g', year: 2025, targetBooks: 10, now: now));

    final t = Tag.create(id: 't', name: 'x', now: now);
    expect(t.copyWith(name: 'y').name, 'y');
    expect(t, Tag.create(id: 't', name: 'x', now: now));

    final r = ReadingLog.create(
      id: 'r',
      bookId: 'b',
      date: DateTime(2025, 3, 1),
      fromPage: 1,
      toPage: 11,
      now: now,
    );
    expect(r.pagesRead, 10);
    expect(r.copyWith(pagesRead: 5).pagesRead, 5);
    expect(r.copyWith(deletedAt: now).isDeleted, isTrue);
  });
}

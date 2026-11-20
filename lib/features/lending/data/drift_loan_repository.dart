import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/converters.dart';
import '../../../data/db/db_guard.dart';
import '../../library/domain/book_enums.dart';
import '../domain/loan.dart';
import '../domain/loan_direction.dart';
import '../domain/loan_repository.dart';

Loan _toDomain(LoanRow r) => Loan(
  id: r.id,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  rev: r.rev,
  bookId: r.bookId,
  direction: r.direction,
  personName: r.personName,
  personPhone: r.personPhone,
  startedOn: r.startedOn,
  dueOn: r.dueOn,
  returnedOn: r.returnedOn,
  previousLocationId: r.previousLocationId,
  note: r.note,
);

LoansCompanion _toCompanion(
  Loan l, {
  required DateTime updatedAt,
  required int rev,
  DateTime? createdAt,
}) => LoansCompanion(
  id: Value(l.id),
  createdAt: createdAt == null ? const Value.absent() : Value(createdAt),
  updatedAt: Value(updatedAt),
  deletedAt: Value(l.deletedAt),
  rev: Value(rev),
  bookId: Value(l.bookId),
  direction: Value(l.direction),
  personName: Value(l.personName),
  personPhone: Value(l.personPhone),
  startedOn: Value(l.startedOn),
  dueOn: Value(l.dueOn),
  returnedOn: Value(l.returnedOn),
  previousLocationId: Value(l.previousLocationId),
  note: Value(l.note),
);

class DriftLoanRepository implements LoanRepository {
  DriftLoanRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  static const _dates = DateOnlyConverter();

  /// Loans joined to their (live) book, filtered by [where].
  JoinedSelectStatement<HasResultSet, dynamic> _joined(
    Expression<bool> Function($LoansTable l) where,
  ) {
    final l = _db.loans;
    return _db.select(l).join([
      innerJoin(_db.books, _db.books.id.equalsExp(l.bookId)),
    ])..where(l.deletedAt.isNull() & _db.books.deletedAt.isNull() & where(l));
  }

  List<Loan> _rows(List<TypedResult> rows) =>
      rows.map((r) => _toDomain(r.readTable(_db.loans))).toList();

  @override
  Stream<List<Loan>> watchActive() {
    final q = _joined((l) => l.returnedOn.isNull())
      ..orderBy([
        // Loans with a due date first (soonest), undated last.
        OrderingTerm.asc(_db.loans.dueOn.isNull()),
        OrderingTerm.asc(_db.loans.dueOn),
        OrderingTerm.asc(_db.loans.createdAt),
      ]);
    return q.watch().map(_rows);
  }

  @override
  Stream<List<Loan>> watchOverdue() {
    final today = _dates.toSql(_clock.today());
    final q = _joined(
      (l) => l.returnedOn.isNull() & l.dueOn.isSmallerThanValue(today),
    )..orderBy([OrderingTerm.asc(_db.loans.dueOn)]);
    return q.watch().map(_rows);
  }

  @override
  Stream<List<Loan>> watchHistory() {
    final q = _joined((l) => l.returnedOn.isNotNull())
      ..orderBy([
        OrderingTerm.desc(_db.loans.returnedOn),
        OrderingTerm.desc(_db.loans.createdAt),
      ]);
    return q.watch().map(_rows);
  }

  Future<LoanRow?> _activeRow(String bookId) {
    return (_db.liveLoans()
          ..where((t) => t.bookId.equals(bookId) & t.returnedOn.isNull()))
        .getSingleOrNull();
  }

  @override
  Future<Result<Loan?>> activeFor(String bookId) => dbGuard(() async {
    final row = await _activeRow(bookId);
    return row == null ? null : _toDomain(row);
  });

  @override
  Future<Result<Loan>> create(Loan loan) => dbGuard(
    () => _db.transaction(() async {
      final book =
          await (_db.liveBooks()..where((t) => t.id.equals(loan.bookId)))
              .getSingleOrNull();
      if (book == null) {
        throw const FailureException(NotFoundFailure('book'));
      }
      if (loan.returnedOn == null && await _activeRow(loan.bookId) != null) {
        throw const FailureException(ConflictFailure('failureBookAlreadyLent'));
      }
      final now = _clock.now();
      await _db
          .into(_db.loans)
          .insert(_toCompanion(loan, createdAt: now, updatedAt: now, rev: 1));
      final saved = await (_db.select(
        _db.loans,
      )..where((t) => t.id.equals(loan.id))).getSingle();
      return _toDomain(saved);
    }),
  );

  @override
  Future<Result<Loan>> update(Loan loan) => dbGuard(
    () => _db.transaction(() async {
      final existing = await (_db.select(
        _db.loans,
      )..where((t) => t.id.equals(loan.id))).getSingleOrNull();
      if (existing == null) {
        throw const FailureException(NotFoundFailure('loan'));
      }
      if (loan.returnedOn == null && loan.deletedAt == null) {
        final active = await _activeRow(loan.bookId);
        if (active != null && active.id != loan.id) {
          throw const FailureException(
            ConflictFailure('failureBookAlreadyLent'),
          );
        }
      }
      await (_db.update(_db.loans)..where((t) => t.id.equals(loan.id))).write(
        _toCompanion(loan, updatedAt: _clock.now(), rev: existing.rev + 1),
      );
      final saved = await (_db.select(
        _db.loans,
      )..where((t) => t.id.equals(loan.id))).getSingle();
      return _toDomain(saved);
    }),
  );

  @override
  Future<Result<Loan>> markReturned(String loanId, DateTime returnedOn) =>
      dbGuard(
        () => _db.transaction(() async {
          final existing =
              await (_db.liveLoans()..where((t) => t.id.equals(loanId)))
                  .getSingleOrNull();
          if (existing == null) {
            throw const FailureException(NotFoundFailure('loan'));
          }
          if (existing.returnedOn != null) {
            throw const FailureException(ConflictFailure());
          }
          await (_db.update(
            _db.loans,
          )..where((t) => t.id.equals(loanId))).write(
            LoansCompanion(
              returnedOn: Value(returnedOn),
              updatedAt: Value(_clock.now()),
              rev: Value(existing.rev + 1),
            ),
          );
          final saved = await (_db.select(
            _db.loans,
          )..where((t) => t.id.equals(loanId))).getSingle();
          return _toDomain(saved);
        }),
      );

  @override
  Future<Result<Loan>> startLoan(Loan loan) => dbGuard(
    () => _db.transaction(() async {
      final book =
          await (_db.liveBooks()..where((t) => t.id.equals(loan.bookId)))
              .getSingleOrNull();
      if (book == null) {
        throw const FailureException(NotFoundFailure('book'));
      }
      if (await _activeRow(loan.bookId) != null) {
        throw const FailureException(ConflictFailure('failureBookAlreadyLent'));
      }
      final now = _clock.now();
      final lending = loan.direction == LoanDirection.lent;
      final stored = lending
          ? loan.copyWith(previousLocationId: book.locationId)
          : loan;
      await _db
          .into(_db.loans)
          .insert(_toCompanion(stored, createdAt: now, updatedAt: now, rev: 1));
      if (lending) {
        await _db.customUpdate(
          'UPDATE books SET location_id = NULL, updated_at = ?1, '
          'rev = rev + 1 WHERE id = ?2',
          variables: [Variable<DateTime>(now), Variable<String>(book.id)],
          updates: {_db.books},
          updateKind: UpdateKind.update,
        );
      } else {
        await _db.customUpdate(
          'UPDATE books SET ownership = ?1, updated_at = ?2, '
          'rev = rev + 1 WHERE id = ?3',
          variables: [
            Variable<String>(Ownership.borrowed.name),
            Variable<DateTime>(now),
            Variable<String>(book.id),
          ],
          updates: {_db.books},
          updateKind: UpdateKind.update,
        );
      }
      final saved = await (_db.select(
        _db.loans,
      )..where((t) => t.id.equals(loan.id))).getSingle();
      return _toDomain(saved);
    }),
  );

  @override
  Future<Result<Loan>> finishLoan(
    String loanId,
    DateTime returnedOn, {
    String? restoreLocationId,
    BorrowedReturnAction borrowedAction =
        BorrowedReturnAction.removeFromLibrary,
  }) => dbGuard(
    () => _db.transaction(() async {
      final existing =
          await (_db.liveLoans()..where((t) => t.id.equals(loanId)))
              .getSingleOrNull();
      if (existing == null) {
        throw const FailureException(NotFoundFailure('loan'));
      }
      if (existing.returnedOn != null) {
        throw const FailureException(ConflictFailure());
      }
      if (restoreLocationId != null) {
        final place =
            await (_db.liveLocations()
                  ..where((t) => t.id.equals(restoreLocationId)))
                .getSingleOrNull();
        if (place == null) {
          throw const FailureException(NotFoundFailure('location'));
        }
      }
      final now = _clock.now();
      await (_db.update(_db.loans)..where((t) => t.id.equals(loanId))).write(
        LoansCompanion(
          returnedOn: Value(returnedOn),
          updatedAt: Value(now),
          rev: Value(existing.rev + 1),
        ),
      );
      if (existing.direction == LoanDirection.lent) {
        await _db.customUpdate(
          'UPDATE books SET location_id = ?1, updated_at = ?2, '
          'rev = rev + 1 WHERE id = ?3',
          variables: [
            Variable<String>(restoreLocationId),
            Variable<DateTime>(now),
            Variable<String>(existing.bookId),
          ],
          updates: {_db.books},
          updateKind: UpdateKind.update,
        );
      } else if (borrowedAction == BorrowedReturnAction.removeFromLibrary) {
        await _db.customUpdate(
          'UPDATE books SET deleted_at = ?1, updated_at = ?1, '
          'rev = rev + 1 WHERE id = ?2',
          variables: [
            Variable<DateTime>(now),
            Variable<String>(existing.bookId),
          ],
          updates: {_db.books},
          updateKind: UpdateKind.update,
        );
      } else {
        await _db.customUpdate(
          'UPDATE books SET ownership = ?1, updated_at = ?2, '
          'rev = rev + 1 WHERE id = ?3',
          variables: [
            Variable<String>(Ownership.wishlist.name),
            Variable<DateTime>(now),
            Variable<String>(existing.bookId),
          ],
          updates: {_db.books},
          updateKind: UpdateKind.update,
        );
      }
      final saved = await (_db.select(
        _db.loans,
      )..where((t) => t.id.equals(loanId))).getSingle();
      return _toDomain(saved);
    }),
  );

  @override
  Future<List<String>> recentPeople({int limit = 20}) async {
    final rows = await _db
        .customSelect(
          'SELECT person_name AS n, MAX(created_at) AS t FROM loans '
          'WHERE deleted_at IS NULL GROUP BY LOWER(person_name) '
          'ORDER BY t DESC LIMIT ?1',
          variables: [Variable<int>(limit)],
          readsFrom: {_db.loans},
        )
        .get();
    return <String>[for (final r in rows) r.read<String>('n')];
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/lending/domain/loan.dart';
import '../features/library/domain/book.dart';
import '../features/tags/domain/tag.dart';
import 'repositories.dart';

part 'book_detail_providers.g.dart';

/// One live book; null when missing or deleted.
@riverpod
Stream<Book?> bookById(Ref ref, String id) =>
    ref.watch(bookRepositoryProvider).watchById(id);

/// The book's active loan, if it is out or borrowed in.
@riverpod
Stream<Loan?> activeLoanFor(Ref ref, String bookId) => ref
    .watch(loanRepositoryProvider)
    .watchActive()
    .map((loans) => loans.where((l) => l.bookId == bookId).firstOrNull);

/// Tags attached to the book.
@riverpod
Stream<List<Tag>> bookTags(Ref ref, String bookId) =>
    ref.watch(tagRepositoryProvider).watchForBook(bookId);

/// Active loans past their due date.
@riverpod
Stream<List<Loan>> overdueLoans(Ref ref) =>
    ref.watch(loanRepositoryProvider).watchOverdue();

/// Loans not yet returned, soonest due first.
@riverpod
Stream<List<Loan>> activeLoans(Ref ref) =>
    ref.watch(loanRepositoryProvider).watchActive();

/// Returned loans, most recent first.
@riverpod
Stream<List<Loan>> loanHistory(Ref ref) =>
    ref.watch(loanRepositoryProvider).watchHistory();

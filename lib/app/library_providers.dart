import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/db/app_database.dart';
import '../data/db/database_provider.dart';
import '../features/lending/domain/loan_direction.dart';
import '../features/library/application/demo_seeder.dart';
import '../features/library/application/library_query.dart';
import '../features/library/domain/book.dart';
import '../features/library/domain/book_enums.dart';
import '../features/library/domain/book_filter.dart';
import '../features/tags/domain/tag.dart';
import 'providers.dart';
import 'repositories.dart';

part 'library_providers.g.dart';

/// The library's current filter and sort. Survives tab switches.
@Riverpod(keepAlive: true)
class LibraryQueryController extends _$LibraryQueryController {
  @override
  LibraryQuery build() => const LibraryQuery();

  /// The "All" chip: drops the status, wishlist, lent and borrowed chips
  /// but keeps the search text, location and tag.
  void showAll() => state = state.copyWith(
    filter: state.filter.copyWith(
      status: null,
      ownership: null,
      lentOut: false,
      borrowed: false,
    ),
  );

  void setText(String text) =>
      state = state.copyWith(filter: state.filter.copyWith(query: text));

  /// Picks one reading status, or none for null. Statuses are exclusive.
  void setStatus(ReadStatus? status) =>
      state = state.copyWith(filter: state.filter.copyWith(status: status));

  void toggleWishlist() => state = state.copyWith(
    filter: state.filter.copyWith(
      ownership: state.filter.ownership == Ownership.wishlist
          ? null
          : Ownership.wishlist,
    ),
  );

  void toggleLentOut() => state = state.copyWith(
    filter: state.filter.copyWith(lentOut: !state.filter.lentOut),
  );

  void toggleBorrowed() => state = state.copyWith(
    filter: state.filter.copyWith(borrowed: !state.filter.borrowed),
  );

  void setLocation(String? id) =>
      state = state.copyWith(filter: state.filter.copyWith(locationId: id));

  void setTag(String? id) =>
      state = state.copyWith(filter: state.filter.copyWith(tagId: id));

  void setSort(BookSort sort) => state = state.copyWith(sort: sort);

  /// Clears every filter and the search text; keeps the sort.
  void clearFilters() => state = state.copyWith(filter: const BookFilter());
}

/// How many pages of the library are loaded. Starts over when the filter or
/// sort changes.
@Riverpod(keepAlive: true)
class LibraryPages extends _$LibraryPages {
  @override
  int build() {
    ref.watch(libraryQueryControllerProvider);
    return 1;
  }

  void loadMore() => state = state + 1;
}

/// The books on screen: live, filtered, sorted, loaded a page at a time.
@riverpod
Stream<List<Book>> libraryBooks(Ref ref) {
  final query = ref.watch(libraryQueryControllerProvider);
  final pages = ref.watch(libraryPagesProvider);
  return ref
      .watch(bookRepositoryProvider)
      .watchAll(
        filter: query.filter,
        sort: query.sort,
        limit: pages * kLibraryPageSize,
      );
}

/// Number of books matching the current filter.
@riverpod
Stream<int> libraryMatchCount(Ref ref) {
  final query = ref.watch(libraryQueryControllerProvider);
  return ref.watch(bookRepositoryProvider).watchCount(filter: query.filter);
}

/// Number of books in the whole library, ignoring filters.
@riverpod
Stream<int> libraryTotalCount(Ref ref) =>
    ref.watch(bookRepositoryProvider).watchCount();

/// Number of books currently lent out.
@riverpod
Stream<int> libraryLentCount(Ref ref) => ref
    .watch(bookRepositoryProvider)
    .watchCount(filter: const BookFilter(lentOut: true));

/// Ids of books currently lent to someone, for the "Lent" ribbon.
@riverpod
Stream<Set<String>> lentBookIds(Ref ref) => ref
    .watch(loanRepositoryProvider)
    .watchActive()
    .map(
      (loans) => <String>{
        for (final loan in loans)
          if (loan.direction == LoanDirection.lent) loan.bookId,
      },
    );

/// All tags, for the tag filter.
@riverpod
Stream<List<Tag>> libraryTags(Ref ref) =>
    ref.watch(tagRepositoryProvider).watchAll();

const String _viewKey = 'library.view';

/// Grid or list, remembered on this device.
@Riverpod(keepAlive: true)
class LibraryViewController extends _$LibraryViewController {
  @override
  LibraryView build() {
    _load();
    return LibraryView.grid;
  }

  Future<void> _load() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final row = await (db.select(
        db.appMeta,
      )..where((t) => t.key.equals(_viewKey))).getSingleOrNull();
      if (row != null && ref.mounted) {
        state = row.value == LibraryView.list.name
            ? LibraryView.list
            : LibraryView.grid;
      }
    } on Object catch (e) {
      ref.read(appLoggerProvider).warn('Reading library view failed: $e');
    }
  }

  Future<void> set(LibraryView view) async {
    state = view;
    try {
      final db = ref.read(appDatabaseProvider);
      await db
          .into(db.appMeta)
          .insertOnConflictUpdate(
            AppMetaCompanion(
              key: const Value(_viewKey),
              value: Value(view.name),
            ),
          );
    } on Object catch (e) {
      ref.read(appLoggerProvider).warn('Saving library view failed: $e');
    }
  }
}

@Riverpod(keepAlive: true)
DemoSeeder demoSeeder(Ref ref) => DemoSeeder(
  books: ref.watch(bookRepositoryProvider),
  locations: ref.watch(locationRepositoryProvider),
  clock: ref.watch(clockProvider),
);

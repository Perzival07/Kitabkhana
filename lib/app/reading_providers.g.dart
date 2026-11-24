// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateProgress)
final updateProgressProvider = UpdateProgressProvider._();

final class UpdateProgressProvider
    extends $FunctionalProvider<UpdateProgress, UpdateProgress, UpdateProgress>
    with $Provider<UpdateProgress> {
  UpdateProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProgressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProgressHash();

  @$internal
  @override
  $ProviderElement<UpdateProgress> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateProgress create(Ref ref) {
    return updateProgress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProgress value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProgress>(value),
    );
  }
}

String _$updateProgressHash() => r'983721af2e0198de819af4432902a71bcddce126';

/// The reader's current and longest streak, across all books.

@ProviderFor(readingStreak)
final readingStreakProvider = ReadingStreakProvider._();

/// The reader's current and longest streak, across all books.

final class ReadingStreakProvider
    extends $FunctionalProvider<AsyncValue<Streak>, Streak, Stream<Streak>>
    with $FutureModifier<Streak>, $StreamProvider<Streak> {
  /// The reader's current and longest streak, across all books.
  ReadingStreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingStreakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingStreakHash();

  @$internal
  @override
  $StreamProviderElement<Streak> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Streak> create(Ref ref) {
    return readingStreak(ref);
  }
}

String _$readingStreakHash() => r'c7481d6ed43cf920b5b7333f31a4884b089f3ce2';

/// Live logs of one book, newest day first.

@ProviderFor(bookReadingLogs)
final bookReadingLogsProvider = BookReadingLogsFamily._();

/// Live logs of one book, newest day first.

final class BookReadingLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReadingLog>>,
          List<ReadingLog>,
          Stream<List<ReadingLog>>
        >
    with $FutureModifier<List<ReadingLog>>, $StreamProvider<List<ReadingLog>> {
  /// Live logs of one book, newest day first.
  BookReadingLogsProvider._({
    required BookReadingLogsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookReadingLogsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookReadingLogsHash();

  @override
  String toString() {
    return r'bookReadingLogsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ReadingLog>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ReadingLog>> create(Ref ref) {
    final argument = this.argument as String;
    return bookReadingLogs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookReadingLogsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookReadingLogsHash() => r'be14d1383883c6536fb3bf509c94c65cc6468889';

/// Live logs of one book, newest day first.

final class BookReadingLogsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ReadingLog>>, String> {
  BookReadingLogsFamily._()
    : super(
        retry: null,
        name: r'bookReadingLogsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live logs of one book, newest day first.

  BookReadingLogsProvider call(String bookId) =>
      BookReadingLogsProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookReadingLogsProvider';
}

/// The predicted finish for a book with [remainingPages] left; null when
/// there is not enough reading to go on.

@ProviderFor(bookPace)
final bookPaceProvider = BookPaceFamily._();

/// The predicted finish for a book with [remainingPages] left; null when
/// there is not enough reading to go on.

final class BookPaceProvider
    extends $FunctionalProvider<PaceEstimate?, PaceEstimate?, PaceEstimate?>
    with $Provider<PaceEstimate?> {
  /// The predicted finish for a book with [remainingPages] left; null when
  /// there is not enough reading to go on.
  BookPaceProvider._({
    required BookPaceFamily super.from,
    required (String, {int remainingPages, DateTime? startedOn}) super.argument,
  }) : super(
         retry: null,
         name: r'bookPaceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookPaceHash();

  @override
  String toString() {
    return r'bookPaceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<PaceEstimate?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PaceEstimate? create(Ref ref) {
    final argument =
        this.argument as (String, {int remainingPages, DateTime? startedOn});
    return bookPace(
      ref,
      argument.$1,
      remainingPages: argument.remainingPages,
      startedOn: argument.startedOn,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaceEstimate? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaceEstimate?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BookPaceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookPaceHash() => r'12a84f51aef3e435c3d31fad2a2145be5a2fd5c2';

/// The predicted finish for a book with [remainingPages] left; null when
/// there is not enough reading to go on.

final class BookPaceFamily extends $Family
    with
        $FunctionalFamilyOverride<
          PaceEstimate?,
          (String, {int remainingPages, DateTime? startedOn})
        > {
  BookPaceFamily._()
    : super(
        retry: null,
        name: r'bookPaceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The predicted finish for a book with [remainingPages] left; null when
  /// there is not enough reading to go on.

  BookPaceProvider call(
    String bookId, {
    required int remainingPages,
    DateTime? startedOn,
  }) => BookPaceProvider._(
    argument: (bookId, remainingPages: remainingPages, startedOn: startedOn),
    from: this,
  );

  @override
  String toString() => r'bookPaceProvider';
}

/// Books being read now, most recently read first.

@ProviderFor(currentlyReading)
final currentlyReadingProvider = CurrentlyReadingProvider._();

/// Books being read now, most recently read first.

final class CurrentlyReadingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          Stream<List<Book>>
        >
    with $FutureModifier<List<Book>>, $StreamProvider<List<Book>> {
  /// Books being read now, most recently read first.
  CurrentlyReadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentlyReadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentlyReadingHash();

  @$internal
  @override
  $StreamProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Book>> create(Ref ref) {
    return currentlyReading(ref);
  }
}

String _$currentlyReadingHash() => r'9b3372b4f1de80110adceaf328fd4cce37b676be';

/// A few books from the want-to-read shelf, newest first.

@ProviderFor(upNextBooks)
final upNextBooksProvider = UpNextBooksProvider._();

/// A few books from the want-to-read shelf, newest first.

final class UpNextBooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          Stream<List<Book>>
        >
    with $FutureModifier<List<Book>>, $StreamProvider<List<Book>> {
  /// A few books from the want-to-read shelf, newest first.
  UpNextBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upNextBooksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upNextBooksHash();

  @$internal
  @override
  $StreamProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Book>> create(Ref ref) {
    return upNextBooks(ref);
  }
}

String _$upNextBooksHash() => r'76ae21af9048a7b434547b2ff5bc90b2972400e9';

/// Pages read on each of the last 7 days, oldest first (today is last).

@ProviderFor(pagesLast7Days)
final pagesLast7DaysProvider = PagesLast7DaysProvider._();

/// Pages read on each of the last 7 days, oldest first (today is last).

final class PagesLast7DaysProvider
    extends
        $FunctionalProvider<AsyncValue<List<int>>, List<int>, Stream<List<int>>>
    with $FutureModifier<List<int>>, $StreamProvider<List<int>> {
  /// Pages read on each of the last 7 days, oldest first (today is last).
  PagesLast7DaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pagesLast7DaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pagesLast7DaysHash();

  @$internal
  @override
  $StreamProviderElement<List<int>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<int>> create(Ref ref) {
    return pagesLast7Days(ref);
  }
}

String _$pagesLast7DaysHash() => r'd5472626342c5e177f6e314aeaf77e53fed33430';

@ProviderFor(readingSessionRepository)
final readingSessionRepositoryProvider = ReadingSessionRepositoryProvider._();

final class ReadingSessionRepositoryProvider
    extends
        $FunctionalProvider<
          ReadingSessionRepository,
          ReadingSessionRepository,
          ReadingSessionRepository
        >
    with $Provider<ReadingSessionRepository> {
  ReadingSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingSessionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReadingSessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingSessionRepository create(Ref ref) {
    return readingSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingSessionRepository>(value),
    );
  }
}

String _$readingSessionRepositoryHash() =>
    r'dd22f251c5f76ce9b7c578fbd1d154d277a61007';

@ProviderFor(readingTimerStore)
final readingTimerStoreProvider = ReadingTimerStoreProvider._();

final class ReadingTimerStoreProvider
    extends
        $FunctionalProvider<
          ReadingTimerStore,
          ReadingTimerStore,
          ReadingTimerStore
        >
    with $Provider<ReadingTimerStore> {
  ReadingTimerStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingTimerStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingTimerStoreHash();

  @$internal
  @override
  $ProviderElement<ReadingTimerStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingTimerStore create(Ref ref) {
    return readingTimerStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingTimerStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingTimerStore>(value),
    );
  }
}

String _$readingTimerStoreHash() => r'7f2a9cc58ee3d27406b85978da485c3893a89b67';

/// The reading timer: at most one runs, for one book. Kept in the database,
/// so closing the app does not lose it.

@ProviderFor(ReadingTimer)
final readingTimerProvider = ReadingTimerProvider._();

/// The reading timer: at most one runs, for one book. Kept in the database,
/// so closing the app does not lose it.
final class ReadingTimerProvider
    extends $AsyncNotifierProvider<ReadingTimer, RunningTimer?> {
  /// The reading timer: at most one runs, for one book. Kept in the database,
  /// so closing the app does not lose it.
  ReadingTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingTimerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingTimerHash();

  @$internal
  @override
  ReadingTimer create() => ReadingTimer();
}

String _$readingTimerHash() => r'af4d5e859c7086bddd947cf0880fb20ebceeb53c';

/// The reading timer: at most one runs, for one book. Kept in the database,
/// so closing the app does not lose it.

abstract class _$ReadingTimer extends $AsyncNotifier<RunningTimer?> {
  FutureOr<RunningTimer?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RunningTimer?>, RunningTimer?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RunningTimer?>, RunningTimer?>,
              AsyncValue<RunningTimer?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Minutes read today (from the timer).

@ProviderFor(minutesToday)
final minutesTodayProvider = MinutesTodayProvider._();

/// Minutes read today (from the timer).

final class MinutesTodayProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Minutes read today (from the timer).
  MinutesTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'minutesTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$minutesTodayHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return minutesToday(ref);
  }
}

String _$minutesTodayHash() => r'f11bc51d3e2c13bd5d189ae0f00f213089bdb6c3';

/// Minutes read in [year] (from the timer).

@ProviderFor(minutesInYear)
final minutesInYearProvider = MinutesInYearFamily._();

/// Minutes read in [year] (from the timer).

final class MinutesInYearProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Minutes read in [year] (from the timer).
  MinutesInYearProvider._({
    required MinutesInYearFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'minutesInYearProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$minutesInYearHash();

  @override
  String toString() {
    return r'minutesInYearProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as int;
    return minutesInYear(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MinutesInYearProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$minutesInYearHash() => r'c623dca2e8b89927101319ce2ecb8c0f36ea3e72';

/// Minutes read in [year] (from the timer).

final class MinutesInYearFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
  MinutesInYearFamily._()
    : super(
        retry: null,
        name: r'minutesInYearProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Minutes read in [year] (from the timer).

  MinutesInYearProvider call(int year) =>
      MinutesInYearProvider._(argument: year, from: this);

  @override
  String toString() => r'minutesInYearProvider';
}

@ProviderFor(readThroughRepository)
final readThroughRepositoryProvider = ReadThroughRepositoryProvider._();

final class ReadThroughRepositoryProvider
    extends
        $FunctionalProvider<
          ReadThroughRepository,
          ReadThroughRepository,
          ReadThroughRepository
        >
    with $Provider<ReadThroughRepository> {
  ReadThroughRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readThroughRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readThroughRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReadThroughRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadThroughRepository create(Ref ref) {
    return readThroughRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadThroughRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadThroughRepository>(value),
    );
  }
}

String _$readThroughRepositoryHash() =>
    r'67a65590a6261bed0922fa10e2c006031c9d1fce';

@ProviderFor(readAgain)
final readAgainProvider = ReadAgainProvider._();

final class ReadAgainProvider
    extends $FunctionalProvider<ReadAgain, ReadAgain, ReadAgain>
    with $Provider<ReadAgain> {
  ReadAgainProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readAgainProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readAgainHash();

  @$internal
  @override
  $ProviderElement<ReadAgain> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReadAgain create(Ref ref) {
    return readAgain(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadAgain value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadAgain>(value),
    );
  }
}

String _$readAgainHash() => r'c470cdeb29ee95a0bbe631085a3241ba44f1590d';

/// Earlier reads of a book, most recent first.

@ProviderFor(bookReadThroughs)
final bookReadThroughsProvider = BookReadThroughsFamily._();

/// Earlier reads of a book, most recent first.

final class BookReadThroughsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReadThrough>>,
          List<ReadThrough>,
          Stream<List<ReadThrough>>
        >
    with
        $FutureModifier<List<ReadThrough>>,
        $StreamProvider<List<ReadThrough>> {
  /// Earlier reads of a book, most recent first.
  BookReadThroughsProvider._({
    required BookReadThroughsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookReadThroughsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookReadThroughsHash();

  @override
  String toString() {
    return r'bookReadThroughsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ReadThrough>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ReadThrough>> create(Ref ref) {
    final argument = this.argument as String;
    return bookReadThroughs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookReadThroughsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookReadThroughsHash() => r'19f900aa9044cc8d8a7c00e5e6677972b7f68c76';

/// Earlier reads of a book, most recent first.

final class BookReadThroughsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ReadThrough>>, String> {
  BookReadThroughsFamily._()
    : super(
        retry: null,
        name: r'bookReadThroughsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Earlier reads of a book, most recent first.

  BookReadThroughsProvider call(String bookId) =>
      BookReadThroughsProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookReadThroughsProvider';
}

/// The home-screen widget (Android only). Tests swap in a fake.

@ProviderFor(homeScreenWidget)
final homeScreenWidgetProvider = HomeScreenWidgetProvider._();

/// The home-screen widget (Android only). Tests swap in a fake.

final class HomeScreenWidgetProvider
    extends
        $FunctionalProvider<
          HomeScreenWidget,
          HomeScreenWidget,
          HomeScreenWidget
        >
    with $Provider<HomeScreenWidget> {
  /// The home-screen widget (Android only). Tests swap in a fake.
  HomeScreenWidgetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeScreenWidgetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeScreenWidgetHash();

  @$internal
  @override
  $ProviderElement<HomeScreenWidget> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeScreenWidget create(Ref ref) {
    return homeScreenWidget(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeScreenWidget value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeScreenWidget>(value),
    );
  }
}

String _$homeScreenWidgetHash() => r'aa3a8eafee83674da12a75468ce768760bec5590';

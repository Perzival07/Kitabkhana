// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The year the Stats tab is showing. Starts as the current year.

@ProviderFor(StatsYear)
final statsYearProvider = StatsYearProvider._();

/// The year the Stats tab is showing. Starts as the current year.
final class StatsYearProvider extends $NotifierProvider<StatsYear, int> {
  /// The year the Stats tab is showing. Starts as the current year.
  StatsYearProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsYearProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsYearHash();

  @$internal
  @override
  StatsYear create() => StatsYear();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$statsYearHash() => r'ff1b8699223c4547040271079a07b32033852053';

/// The year the Stats tab is showing. Starts as the current year.

abstract class _$StatsYear extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Years the selector offers: every year with finished books or a goal,
/// plus the current one, newest first.

@ProviderFor(statsYears)
final statsYearsProvider = StatsYearsProvider._();

/// Years the selector offers: every year with finished books or a goal,
/// plus the current one, newest first.

final class StatsYearsProvider
    extends
        $FunctionalProvider<AsyncValue<List<int>>, List<int>, Stream<List<int>>>
    with $FutureModifier<List<int>>, $StreamProvider<List<int>> {
  /// Years the selector offers: every year with finished books or a goal,
  /// plus the current one, newest first.
  StatsYearsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsYearsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsYearsHash();

  @$internal
  @override
  $StreamProviderElement<List<int>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<int>> create(Ref ref) {
    return statsYears(ref);
  }
}

String _$statsYearsHash() => r'31328a8b348eed446ef92b164aeeef1ebfa540e4';

@ProviderFor(yearGoal)
final yearGoalProvider = YearGoalFamily._();

final class YearGoalProvider
    extends $FunctionalProvider<AsyncValue<Goal?>, Goal?, Stream<Goal?>>
    with $FutureModifier<Goal?>, $StreamProvider<Goal?> {
  YearGoalProvider._({
    required YearGoalFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'yearGoalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearGoalHash();

  @override
  String toString() {
    return r'yearGoalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Goal?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Goal?> create(Ref ref) {
    final argument = this.argument as int;
    return yearGoal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearGoalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearGoalHash() => r'fc5c29016ae87e301ddd22f1e5057954b3c2ade1';

final class YearGoalFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Goal?>, int> {
  YearGoalFamily._()
    : super(
        retry: null,
        name: r'yearGoalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  YearGoalProvider call(int year) =>
      YearGoalProvider._(argument: year, from: this);

  @override
  String toString() => r'yearGoalProvider';
}

@ProviderFor(yearFinishedCount)
final yearFinishedCountProvider = YearFinishedCountFamily._();

final class YearFinishedCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  YearFinishedCountProvider._({
    required YearFinishedCountFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'yearFinishedCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearFinishedCountHash();

  @override
  String toString() {
    return r'yearFinishedCountProvider'
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
    return yearFinishedCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearFinishedCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearFinishedCountHash() => r'4117953f964b0d60785e2b272dbb45172327c254';

final class YearFinishedCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
  YearFinishedCountFamily._()
    : super(
        retry: null,
        name: r'yearFinishedCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  YearFinishedCountProvider call(int year) =>
      YearFinishedCountProvider._(argument: year, from: this);

  @override
  String toString() => r'yearFinishedCountProvider';
}

@ProviderFor(yearFinishedPerMonth)
final yearFinishedPerMonthProvider = YearFinishedPerMonthFamily._();

final class YearFinishedPerMonthProvider
    extends
        $FunctionalProvider<AsyncValue<List<int>>, List<int>, Stream<List<int>>>
    with $FutureModifier<List<int>>, $StreamProvider<List<int>> {
  YearFinishedPerMonthProvider._({
    required YearFinishedPerMonthFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'yearFinishedPerMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearFinishedPerMonthHash();

  @override
  String toString() {
    return r'yearFinishedPerMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<int>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<int>> create(Ref ref) {
    final argument = this.argument as int;
    return yearFinishedPerMonth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearFinishedPerMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearFinishedPerMonthHash() =>
    r'e6eaa804d38ff8e7075cf19b3c79bd8198073513';

final class YearFinishedPerMonthFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<int>>, int> {
  YearFinishedPerMonthFamily._()
    : super(
        retry: null,
        name: r'yearFinishedPerMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  YearFinishedPerMonthProvider call(int year) =>
      YearFinishedPerMonthProvider._(argument: year, from: this);

  @override
  String toString() => r'yearFinishedPerMonthProvider';
}

/// The last 12 weeks of pages: ending today for the current year, else on
/// the year's last day.

@ProviderFor(yearPagesPerWeek)
final yearPagesPerWeekProvider = YearPagesPerWeekFamily._();

/// The last 12 weeks of pages: ending today for the current year, else on
/// the year's last day.

final class YearPagesPerWeekProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeekPages>>,
          List<WeekPages>,
          Stream<List<WeekPages>>
        >
    with $FutureModifier<List<WeekPages>>, $StreamProvider<List<WeekPages>> {
  /// The last 12 weeks of pages: ending today for the current year, else on
  /// the year's last day.
  YearPagesPerWeekProvider._({
    required YearPagesPerWeekFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'yearPagesPerWeekProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearPagesPerWeekHash();

  @override
  String toString() {
    return r'yearPagesPerWeekProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<WeekPages>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WeekPages>> create(Ref ref) {
    final argument = this.argument as int;
    return yearPagesPerWeek(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearPagesPerWeekProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearPagesPerWeekHash() => r'4d8c57fc7b607c03d56f5870d0c7b6ffa5a2fdbc';

/// The last 12 weeks of pages: ending today for the current year, else on
/// the year's last day.

final class YearPagesPerWeekFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<WeekPages>>, int> {
  YearPagesPerWeekFamily._()
    : super(
        retry: null,
        name: r'yearPagesPerWeekProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The last 12 weeks of pages: ending today for the current year, else on
  /// the year's last day.

  YearPagesPerWeekProvider call(int year) =>
      YearPagesPerWeekProvider._(argument: year, from: this);

  @override
  String toString() => r'yearPagesPerWeekProvider';
}

@ProviderFor(yearTopGenres)
final yearTopGenresProvider = YearTopGenresFamily._();

final class YearTopGenresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LabelCount>>,
          List<LabelCount>,
          Stream<List<LabelCount>>
        >
    with $FutureModifier<List<LabelCount>>, $StreamProvider<List<LabelCount>> {
  YearTopGenresProvider._({
    required YearTopGenresFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'yearTopGenresProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearTopGenresHash();

  @override
  String toString() {
    return r'yearTopGenresProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LabelCount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LabelCount>> create(Ref ref) {
    final argument = this.argument as int;
    return yearTopGenres(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearTopGenresProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearTopGenresHash() => r'b7d351d697970d59dc3120c26c1d6cda3a69e6e9';

final class YearTopGenresFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LabelCount>>, int> {
  YearTopGenresFamily._()
    : super(
        retry: null,
        name: r'yearTopGenresProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  YearTopGenresProvider call(int year) =>
      YearTopGenresProvider._(argument: year, from: this);

  @override
  String toString() => r'yearTopGenresProvider';
}

@ProviderFor(yearTopAuthors)
final yearTopAuthorsProvider = YearTopAuthorsFamily._();

final class YearTopAuthorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LabelCount>>,
          List<LabelCount>,
          Stream<List<LabelCount>>
        >
    with $FutureModifier<List<LabelCount>>, $StreamProvider<List<LabelCount>> {
  YearTopAuthorsProvider._({
    required YearTopAuthorsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'yearTopAuthorsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearTopAuthorsHash();

  @override
  String toString() {
    return r'yearTopAuthorsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LabelCount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LabelCount>> create(Ref ref) {
    final argument = this.argument as int;
    return yearTopAuthors(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearTopAuthorsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearTopAuthorsHash() => r'7d6a66617db4b04cf6b8d9a6b0976ecc79f01298';

final class YearTopAuthorsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LabelCount>>, int> {
  YearTopAuthorsFamily._()
    : super(
        retry: null,
        name: r'yearTopAuthorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  YearTopAuthorsProvider call(int year) =>
      YearTopAuthorsProvider._(argument: year, from: this);

  @override
  String toString() => r'yearTopAuthorsProvider';
}

@ProviderFor(yearFacts)
final yearFactsProvider = YearFactsFamily._();

final class YearFactsProvider
    extends
        $FunctionalProvider<
          AsyncValue<LibraryFacts>,
          LibraryFacts,
          Stream<LibraryFacts>
        >
    with $FutureModifier<LibraryFacts>, $StreamProvider<LibraryFacts> {
  YearFactsProvider._({
    required YearFactsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'yearFactsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearFactsHash();

  @override
  String toString() {
    return r'yearFactsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<LibraryFacts> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LibraryFacts> create(Ref ref) {
    final argument = this.argument as int;
    return yearFacts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearFactsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearFactsHash() => r'e235eb7380e2fc090ea2b8d21b51ae3509465c17';

final class YearFactsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<LibraryFacts>, int> {
  YearFactsFamily._()
    : super(
        retry: null,
        name: r'yearFactsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  YearFactsProvider call(int year) =>
      YearFactsProvider._(argument: year, from: this);

  @override
  String toString() => r'yearFactsProvider';
}

/// Books finished in one month, for the bar-tap list.

@ProviderFor(booksFinishedInMonth)
final booksFinishedInMonthProvider = BooksFinishedInMonthFamily._();

/// Books finished in one month, for the bar-tap list.

final class BooksFinishedInMonthProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          FutureOr<List<Book>>
        >
    with $FutureModifier<List<Book>>, $FutureProvider<List<Book>> {
  /// Books finished in one month, for the bar-tap list.
  BooksFinishedInMonthProvider._({
    required BooksFinishedInMonthFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'booksFinishedInMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$booksFinishedInMonthHash();

  @override
  String toString() {
    return r'booksFinishedInMonthProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Book>> create(Ref ref) {
    final argument = this.argument as (int, int);
    return booksFinishedInMonth(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is BooksFinishedInMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$booksFinishedInMonthHash() =>
    r'6269b3fdb6f2a8a9d7fa0d415bb863ca6ac01595';

/// Books finished in one month, for the bar-tap list.

final class BooksFinishedInMonthFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Book>>, (int, int)> {
  BooksFinishedInMonthFamily._()
    : super(
        retry: null,
        name: r'booksFinishedInMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Books finished in one month, for the bar-tap list.

  BooksFinishedInMonthProvider call(int year, int month) =>
      BooksFinishedInMonthProvider._(argument: (year, month), from: this);

  @override
  String toString() => r'booksFinishedInMonthProvider';
}

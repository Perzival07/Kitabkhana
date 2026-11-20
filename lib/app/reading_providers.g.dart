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

String _$readingStreakHash() => r'87d8b111c7c697c4df86455ddaae527a231f9112';

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

String _$bookPaceHash() => r'c39bb62b3408819ad47a3b8e97eef2e5a5f35b8a';

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

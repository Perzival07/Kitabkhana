// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One live book; null when missing or deleted.

@ProviderFor(bookById)
final bookByIdProvider = BookByIdFamily._();

/// One live book; null when missing or deleted.

final class BookByIdProvider
    extends $FunctionalProvider<AsyncValue<Book?>, Book?, Stream<Book?>>
    with $FutureModifier<Book?>, $StreamProvider<Book?> {
  /// One live book; null when missing or deleted.
  BookByIdProvider._({
    required BookByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookByIdHash();

  @override
  String toString() {
    return r'bookByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Book?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Book?> create(Ref ref) {
    final argument = this.argument as String;
    return bookById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookByIdHash() => r'713654d22429e62ef062177e7f11be83dcac53d5';

/// One live book; null when missing or deleted.

final class BookByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Book?>, String> {
  BookByIdFamily._()
    : super(
        retry: null,
        name: r'bookByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One live book; null when missing or deleted.

  BookByIdProvider call(String id) =>
      BookByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'bookByIdProvider';
}

/// The book's active loan, if it is out or borrowed in.

@ProviderFor(activeLoanFor)
final activeLoanForProvider = ActiveLoanForFamily._();

/// The book's active loan, if it is out or borrowed in.

final class ActiveLoanForProvider
    extends $FunctionalProvider<AsyncValue<Loan?>, Loan?, Stream<Loan?>>
    with $FutureModifier<Loan?>, $StreamProvider<Loan?> {
  /// The book's active loan, if it is out or borrowed in.
  ActiveLoanForProvider._({
    required ActiveLoanForFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeLoanForProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeLoanForHash();

  @override
  String toString() {
    return r'activeLoanForProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Loan?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Loan?> create(Ref ref) {
    final argument = this.argument as String;
    return activeLoanFor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveLoanForProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeLoanForHash() => r'0c640ebd46e71a2afb37c8d466ae8cb22079c2ca';

/// The book's active loan, if it is out or borrowed in.

final class ActiveLoanForFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Loan?>, String> {
  ActiveLoanForFamily._()
    : super(
        retry: null,
        name: r'activeLoanForProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The book's active loan, if it is out or borrowed in.

  ActiveLoanForProvider call(String bookId) =>
      ActiveLoanForProvider._(argument: bookId, from: this);

  @override
  String toString() => r'activeLoanForProvider';
}

/// Tags attached to the book.

@ProviderFor(bookTags)
final bookTagsProvider = BookTagsFamily._();

/// Tags attached to the book.

final class BookTagsProvider
    extends
        $FunctionalProvider<AsyncValue<List<Tag>>, List<Tag>, Stream<List<Tag>>>
    with $FutureModifier<List<Tag>>, $StreamProvider<List<Tag>> {
  /// Tags attached to the book.
  BookTagsProvider._({
    required BookTagsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookTagsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookTagsHash();

  @override
  String toString() {
    return r'bookTagsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Tag>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Tag>> create(Ref ref) {
    final argument = this.argument as String;
    return bookTags(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookTagsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookTagsHash() => r'3960be1549becdecc9d07deaeec862486b2b85ba';

/// Tags attached to the book.

final class BookTagsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Tag>>, String> {
  BookTagsFamily._()
    : super(
        retry: null,
        name: r'bookTagsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Tags attached to the book.

  BookTagsProvider call(String bookId) =>
      BookTagsProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookTagsProvider';
}

/// Active loans past their due date.

@ProviderFor(overdueLoans)
final overdueLoansProvider = OverdueLoansProvider._();

/// Active loans past their due date.

final class OverdueLoansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Loan>>,
          List<Loan>,
          Stream<List<Loan>>
        >
    with $FutureModifier<List<Loan>>, $StreamProvider<List<Loan>> {
  /// Active loans past their due date.
  OverdueLoansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'overdueLoansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$overdueLoansHash();

  @$internal
  @override
  $StreamProviderElement<List<Loan>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Loan>> create(Ref ref) {
    return overdueLoans(ref);
  }
}

String _$overdueLoansHash() => r'f8262f8541c55f38323e02980faec2d10cdc8369';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lending_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Schedules loan reminders (local notifications; none on the web).

@ProviderFor(reminderService)
final reminderServiceProvider = ReminderServiceProvider._();

/// Schedules loan reminders (local notifications; none on the web).

final class ReminderServiceProvider
    extends
        $FunctionalProvider<ReminderService, ReminderService, ReminderService>
    with $Provider<ReminderService> {
  /// Schedules loan reminders (local notifications; none on the web).
  ReminderServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderServiceHash();

  @$internal
  @override
  $ProviderElement<ReminderService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReminderService create(Ref ref) {
    return reminderService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderService>(value),
    );
  }
}

String _$reminderServiceHash() => r'fe2a001f3efde431559826c1a6d10334f5a98f32';

@ProviderFor(lendBook)
final lendBookProvider = LendBookProvider._();

final class LendBookProvider
    extends $FunctionalProvider<LendBook, LendBook, LendBook>
    with $Provider<LendBook> {
  LendBookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lendBookProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lendBookHash();

  @$internal
  @override
  $ProviderElement<LendBook> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LendBook create(Ref ref) {
    return lendBook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LendBook value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LendBook>(value),
    );
  }
}

String _$lendBookHash() => r'ac7d2755ba328135afd10b61b4d84f8e6c51b3dc';

@ProviderFor(recordBorrowedBook)
final recordBorrowedBookProvider = RecordBorrowedBookProvider._();

final class RecordBorrowedBookProvider
    extends
        $FunctionalProvider<
          RecordBorrowedBook,
          RecordBorrowedBook,
          RecordBorrowedBook
        >
    with $Provider<RecordBorrowedBook> {
  RecordBorrowedBookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordBorrowedBookProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordBorrowedBookHash();

  @$internal
  @override
  $ProviderElement<RecordBorrowedBook> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecordBorrowedBook create(Ref ref) {
    return recordBorrowedBook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecordBorrowedBook value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecordBorrowedBook>(value),
    );
  }
}

String _$recordBorrowedBookHash() =>
    r'84b30f5cb4da774540a7353bde3b4d6f9a5599d6';

@ProviderFor(returnLoan)
final returnLoanProvider = ReturnLoanProvider._();

final class ReturnLoanProvider
    extends $FunctionalProvider<ReturnLoan, ReturnLoan, ReturnLoan>
    with $Provider<ReturnLoan> {
  ReturnLoanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'returnLoanProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$returnLoanHash();

  @$internal
  @override
  $ProviderElement<ReturnLoan> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReturnLoan create(Ref ref) {
    return returnLoan(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReturnLoan value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReturnLoan>(value),
    );
  }
}

String _$returnLoanHash() => r'fac2f2ed45aeed97752f81458d0cc37a749036b4';

@ProviderFor(extendDueDate)
final extendDueDateProvider = ExtendDueDateProvider._();

final class ExtendDueDateProvider
    extends $FunctionalProvider<ExtendDueDate, ExtendDueDate, ExtendDueDate>
    with $Provider<ExtendDueDate> {
  ExtendDueDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'extendDueDateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$extendDueDateHash();

  @$internal
  @override
  $ProviderElement<ExtendDueDate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExtendDueDate create(Ref ref) {
    return extendDueDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExtendDueDate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExtendDueDate>(value),
    );
  }
}

String _$extendDueDateHash() => r'47796450b609a085e332f49e4f83d426ecb707cf';

/// Names of people from past loans, for autocomplete.

@ProviderFor(recentPeople)
final recentPeopleProvider = RecentPeopleProvider._();

/// Names of people from past loans, for autocomplete.

final class RecentPeopleProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Names of people from past loans, for autocomplete.
  RecentPeopleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentPeopleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentPeopleHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return recentPeople(ref);
  }
}

String _$recentPeopleHash() => r'32fe244c44a0dd2236d4f93aa222c934105ccc2d';

/// The country code (digits only) assumed for phone numbers typed without
/// one. Defaults to India (91); stored on this device.

@ProviderFor(DefaultCountryCode)
final defaultCountryCodeProvider = DefaultCountryCodeProvider._();

/// The country code (digits only) assumed for phone numbers typed without
/// one. Defaults to India (91); stored on this device.
final class DefaultCountryCodeProvider
    extends $NotifierProvider<DefaultCountryCode, String> {
  /// The country code (digits only) assumed for phone numbers typed without
  /// one. Defaults to India (91); stored on this device.
  DefaultCountryCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultCountryCodeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultCountryCodeHash();

  @$internal
  @override
  DefaultCountryCode create() => DefaultCountryCode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$defaultCountryCodeHash() =>
    r'532362b6edf11b88425705b740a7bf415a7a8d95';

/// The country code (digits only) assumed for phone numbers typed without
/// one. Defaults to India (91); stored on this device.

abstract class _$DefaultCountryCode extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

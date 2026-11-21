// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The library's current filter and sort. Survives tab switches.

@ProviderFor(LibraryQueryController)
final libraryQueryControllerProvider = LibraryQueryControllerProvider._();

/// The library's current filter and sort. Survives tab switches.
final class LibraryQueryControllerProvider
    extends $NotifierProvider<LibraryQueryController, LibraryQuery> {
  /// The library's current filter and sort. Survives tab switches.
  LibraryQueryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryQueryControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryQueryControllerHash();

  @$internal
  @override
  LibraryQueryController create() => LibraryQueryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LibraryQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LibraryQuery>(value),
    );
  }
}

String _$libraryQueryControllerHash() =>
    r'8d372d48be1872217760b971eca62bb2034bcdb6';

/// The library's current filter and sort. Survives tab switches.

abstract class _$LibraryQueryController extends $Notifier<LibraryQuery> {
  LibraryQuery build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LibraryQuery, LibraryQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LibraryQuery, LibraryQuery>,
              LibraryQuery,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// How many pages of the library are loaded. Starts over when the filter or
/// sort changes.

@ProviderFor(LibraryPages)
final libraryPagesProvider = LibraryPagesProvider._();

/// How many pages of the library are loaded. Starts over when the filter or
/// sort changes.
final class LibraryPagesProvider extends $NotifierProvider<LibraryPages, int> {
  /// How many pages of the library are loaded. Starts over when the filter or
  /// sort changes.
  LibraryPagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryPagesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryPagesHash();

  @$internal
  @override
  LibraryPages create() => LibraryPages();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$libraryPagesHash() => r'a16faf31f9e8e89534bb18cd09b06b900f4da3ae';

/// How many pages of the library are loaded. Starts over when the filter or
/// sort changes.

abstract class _$LibraryPages extends $Notifier<int> {
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

/// The books on screen: live, filtered, sorted, loaded a page at a time.

@ProviderFor(libraryBooks)
final libraryBooksProvider = LibraryBooksProvider._();

/// The books on screen: live, filtered, sorted, loaded a page at a time.

final class LibraryBooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          Stream<List<Book>>
        >
    with $FutureModifier<List<Book>>, $StreamProvider<List<Book>> {
  /// The books on screen: live, filtered, sorted, loaded a page at a time.
  LibraryBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryBooksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryBooksHash();

  @$internal
  @override
  $StreamProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Book>> create(Ref ref) {
    return libraryBooks(ref);
  }
}

String _$libraryBooksHash() => r'b82d06c95b73a49f7f866140f91fc4374ccec4d7';

/// Number of books matching the current filter.

@ProviderFor(libraryMatchCount)
final libraryMatchCountProvider = LibraryMatchCountProvider._();

/// Number of books matching the current filter.

final class LibraryMatchCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Number of books matching the current filter.
  LibraryMatchCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryMatchCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryMatchCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return libraryMatchCount(ref);
  }
}

String _$libraryMatchCountHash() => r'e6514d201a654ea75b6cce6e8cea9c6abc9b7c9d';

/// Number of books in the whole library, ignoring filters.

@ProviderFor(libraryTotalCount)
final libraryTotalCountProvider = LibraryTotalCountProvider._();

/// Number of books in the whole library, ignoring filters.

final class LibraryTotalCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Number of books in the whole library, ignoring filters.
  LibraryTotalCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryTotalCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryTotalCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return libraryTotalCount(ref);
  }
}

String _$libraryTotalCountHash() => r'5bdfe08793ad291ef9cbe5377568665d817cbe4b';

/// Number of books currently lent out.

@ProviderFor(libraryLentCount)
final libraryLentCountProvider = LibraryLentCountProvider._();

/// Number of books currently lent out.

final class LibraryLentCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Number of books currently lent out.
  LibraryLentCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryLentCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryLentCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return libraryLentCount(ref);
  }
}

String _$libraryLentCountHash() => r'e8b7ef378bf50f46576323495155df7e62af906e';

/// Ids of books currently lent to someone, for the "Lent" ribbon.

@ProviderFor(lentBookIds)
final lentBookIdsProvider = LentBookIdsProvider._();

/// Ids of books currently lent to someone, for the "Lent" ribbon.

final class LentBookIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  /// Ids of books currently lent to someone, for the "Lent" ribbon.
  LentBookIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lentBookIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lentBookIdsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return lentBookIds(ref);
  }
}

String _$lentBookIdsHash() => r'f3562c41d6719ff0ed8b96779b786c7d93a17ed8';

/// All tags, for the tag filter.

@ProviderFor(libraryTags)
final libraryTagsProvider = LibraryTagsProvider._();

/// All tags, for the tag filter.

final class LibraryTagsProvider
    extends
        $FunctionalProvider<AsyncValue<List<Tag>>, List<Tag>, Stream<List<Tag>>>
    with $FutureModifier<List<Tag>>, $StreamProvider<List<Tag>> {
  /// All tags, for the tag filter.
  LibraryTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryTagsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryTagsHash();

  @$internal
  @override
  $StreamProviderElement<List<Tag>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Tag>> create(Ref ref) {
    return libraryTags(ref);
  }
}

String _$libraryTagsHash() => r'7ac1a4a12429fb18f0582f22063cb7af0ff5950d';

/// The book open in the detail pane of the two-pane layout.

@ProviderFor(SelectedBookId)
final selectedBookIdProvider = SelectedBookIdProvider._();

/// The book open in the detail pane of the two-pane layout.
final class SelectedBookIdProvider
    extends $NotifierProvider<SelectedBookId, String?> {
  /// The book open in the detail pane of the two-pane layout.
  SelectedBookIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedBookIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedBookIdHash();

  @$internal
  @override
  SelectedBookId create() => SelectedBookId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedBookIdHash() => r'f2c6528ce4b5ef945b89caeb317d85d55b150e87';

/// The book open in the detail pane of the two-pane layout.

abstract class _$SelectedBookId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Grid or list, remembered on this device.

@ProviderFor(LibraryViewController)
final libraryViewControllerProvider = LibraryViewControllerProvider._();

/// Grid or list, remembered on this device.
final class LibraryViewControllerProvider
    extends $NotifierProvider<LibraryViewController, LibraryView> {
  /// Grid or list, remembered on this device.
  LibraryViewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryViewControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryViewControllerHash();

  @$internal
  @override
  LibraryViewController create() => LibraryViewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LibraryView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LibraryView>(value),
    );
  }
}

String _$libraryViewControllerHash() =>
    r'a2e5d51de29eeaf516674470f6bf38614433e84b';

/// Grid or list, remembered on this device.

abstract class _$LibraryViewController extends $Notifier<LibraryView> {
  LibraryView build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LibraryView, LibraryView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LibraryView, LibraryView>,
              LibraryView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(demoSeeder)
final demoSeederProvider = DemoSeederProvider._();

final class DemoSeederProvider
    extends $FunctionalProvider<DemoSeeder, DemoSeeder, DemoSeeder>
    with $Provider<DemoSeeder> {
  DemoSeederProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'demoSeederProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$demoSeederHash();

  @$internal
  @override
  $ProviderElement<DemoSeeder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DemoSeeder create(Ref ref) {
    return demoSeeder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoSeeder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoSeeder>(value),
    );
  }
}

String _$demoSeederHash() => r'1f6e2fa7a9a5f161358aaa466381e9b4f8ab92d3';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_book_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(addBook)
final addBookProvider = AddBookProvider._();

final class AddBookProvider
    extends $FunctionalProvider<AddBook, AddBook, AddBook>
    with $Provider<AddBook> {
  AddBookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addBookProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addBookHash();

  @$internal
  @override
  $ProviderElement<AddBook> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AddBook create(Ref ref) {
    return addBook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddBook value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddBook>(value),
    );
  }
}

String _$addBookHash() => r'1e64ad417e8f764e33778e3f1eb8645066e364c9';

/// Live list of locations for pickers.

@ProviderFor(locations)
final locationsProvider = LocationsProvider._();

/// Live list of locations for pickers.

final class LocationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Location>>,
          List<Location>,
          Stream<List<Location>>
        >
    with $FutureModifier<List<Location>>, $StreamProvider<List<Location>> {
  /// Live list of locations for pickers.
  LocationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationsHash();

  @$internal
  @override
  $StreamProviderElement<List<Location>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Location>> create(Ref ref) {
    return locations(ref);
  }
}

String _$locationsHash() => r'1a456b53c51df9f278118a201d1293e081143864';

@ProviderFor(photoPicker)
final photoPickerProvider = PhotoPickerProvider._();

final class PhotoPickerProvider
    extends $FunctionalProvider<PhotoPicker, PhotoPicker, PhotoPicker>
    with $Provider<PhotoPicker> {
  PhotoPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoPickerHash();

  @$internal
  @override
  $ProviderElement<PhotoPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoPicker create(Ref ref) {
    return photoPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoPicker>(value),
    );
  }
}

String _$photoPickerHash() => r'b71d30bec047cf99e031ecba15124a094c433ac0';

/// The camera view used by the scan screens; overridden in tests.

@ProviderFor(barcodeViewBuilder)
final barcodeViewBuilderProvider = BarcodeViewBuilderProvider._();

/// The camera view used by the scan screens; overridden in tests.

final class BarcodeViewBuilderProvider
    extends
        $FunctionalProvider<
          BarcodeViewBuilder,
          BarcodeViewBuilder,
          BarcodeViewBuilder
        >
    with $Provider<BarcodeViewBuilder> {
  /// The camera view used by the scan screens; overridden in tests.
  BarcodeViewBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barcodeViewBuilderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barcodeViewBuilderHash();

  @$internal
  @override
  $ProviderElement<BarcodeViewBuilder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BarcodeViewBuilder create(Ref ref) {
    return barcodeViewBuilder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BarcodeViewBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BarcodeViewBuilder>(value),
    );
  }
}

String _$barcodeViewBuilderHash() =>
    r'83535d091b6f1c188dad946254f32a9bfa77cc2e';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's cover store: files on mobile, database blobs on web.
/// Image decoding and resizing run off the UI thread via `compute`.

@ProviderFor(coverStore)
final coverStoreProvider = CoverStoreProvider._();

/// The platform's cover store: files on mobile, database blobs on web.
/// Image decoding and resizing run off the UI thread via `compute`.

final class CoverStoreProvider
    extends $FunctionalProvider<CoverStore, CoverStore, CoverStore>
    with $Provider<CoverStore> {
  /// The platform's cover store: files on mobile, database blobs on web.
  /// Image decoding and resizing run off the UI thread via `compute`.
  CoverStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coverStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coverStoreHash();

  @$internal
  @override
  $ProviderElement<CoverStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CoverStore create(Ref ref) {
    return coverStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoverStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoverStore>(value),
    );
  }
}

String _$coverStoreHash() => r'c6f0dc959bf4eebec443694c0f9ea88efb584820';

/// Resolves a `Book.coverLocalPath` reference to an image (null if none).

@ProviderFor(coverImage)
final coverImageProvider = CoverImageFamily._();

/// Resolves a `Book.coverLocalPath` reference to an image (null if none).

final class CoverImageProvider
    extends
        $FunctionalProvider<
          AsyncValue<ImageProvider<Object>?>,
          ImageProvider<Object>?,
          FutureOr<ImageProvider<Object>?>
        >
    with
        $FutureModifier<ImageProvider<Object>?>,
        $FutureProvider<ImageProvider<Object>?> {
  /// Resolves a `Book.coverLocalPath` reference to an image (null if none).
  CoverImageProvider._({
    required CoverImageFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'coverImageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coverImageHash();

  @override
  String toString() {
    return r'coverImageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ImageProvider<Object>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ImageProvider<Object>?> create(Ref ref) {
    final argument = this.argument as String?;
    return coverImage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CoverImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coverImageHash() => r'c84722ab311b58a27b8f96482e8c9e4ab2204573';

/// Resolves a `Book.coverLocalPath` reference to an image (null if none).

final class CoverImageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ImageProvider<Object>?>, String?> {
  CoverImageFamily._()
    : super(
        retry: null,
        name: r'coverImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolves a `Book.coverLocalPath` reference to an image (null if none).

  CoverImageProvider call(String? reference) =>
      CoverImageProvider._(argument: reference, from: this);

  @override
  String toString() => r'coverImageProvider';
}

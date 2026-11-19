// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lookup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(httpClient)
final httpClientProvider = HttpClientProvider._();

final class HttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  HttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'httpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$httpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return httpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$httpClientHash() => r'7ec49beae0f15115de79f9aa98dbd250130e26d8';

@ProviderFor(bookInfoSource)
final bookInfoSourceProvider = BookInfoSourceProvider._();

final class BookInfoSourceProvider
    extends $FunctionalProvider<BookInfoSource, BookInfoSource, BookInfoSource>
    with $Provider<BookInfoSource> {
  BookInfoSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookInfoSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookInfoSourceHash();

  @$internal
  @override
  $ProviderElement<BookInfoSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BookInfoSource create(Ref ref) {
    return bookInfoSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookInfoSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookInfoSource>(value),
    );
  }
}

String _$bookInfoSourceHash() => r'd85e8fce782567e1913b19ac3ac1043c122ff569';

@ProviderFor(lookupCacheStore)
final lookupCacheStoreProvider = LookupCacheStoreProvider._();

final class LookupCacheStoreProvider
    extends
        $FunctionalProvider<
          LookupCacheStore,
          LookupCacheStore,
          LookupCacheStore
        >
    with $Provider<LookupCacheStore> {
  LookupCacheStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lookupCacheStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lookupCacheStoreHash();

  @$internal
  @override
  $ProviderElement<LookupCacheStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LookupCacheStore create(Ref ref) {
    return lookupCacheStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LookupCacheStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LookupCacheStore>(value),
    );
  }
}

String _$lookupCacheStoreHash() => r'995b7dd22d40350b39fbf747a8b90faa9366c736';

@ProviderFor(bookLookupService)
final bookLookupServiceProvider = BookLookupServiceProvider._();

final class BookLookupServiceProvider
    extends
        $FunctionalProvider<
          BookLookupService,
          BookLookupService,
          BookLookupService
        >
    with $Provider<BookLookupService> {
  BookLookupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookLookupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookLookupServiceHash();

  @$internal
  @override
  $ProviderElement<BookLookupService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookLookupService create(Ref ref) {
    return bookLookupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookLookupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookLookupService>(value),
    );
  }
}

String _$bookLookupServiceHash() => r'89e09950e53a4ecae3d8dff759a9866a3173f7da';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live number of books in each location, keyed by location id.

@ProviderFor(locationBookCounts)
final locationBookCountsProvider = LocationBookCountsProvider._();

/// Live number of books in each location, keyed by location id.

final class LocationBookCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          Stream<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $StreamProvider<Map<String, int>> {
  /// Live number of books in each location, keyed by location id.
  LocationBookCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationBookCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationBookCountsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, int>> create(Ref ref) {
    return locationBookCounts(ref);
  }
}

String _$locationBookCountsHash() =>
    r'bbbf866a3f6c84626f5fd7535a2aae99fcf540a4';

/// Ids of recently chosen locations, newest first. Kept on this device.

@ProviderFor(RecentLocations)
final recentLocationsProvider = RecentLocationsProvider._();

/// Ids of recently chosen locations, newest first. Kept on this device.
final class RecentLocationsProvider
    extends $NotifierProvider<RecentLocations, List<String>> {
  /// Ids of recently chosen locations, newest first. Kept on this device.
  RecentLocationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentLocationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentLocationsHash();

  @$internal
  @override
  RecentLocations create() => RecentLocations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$recentLocationsHash() => r'f62253a7d240f594f43362aa69a817d95ae74510';

/// Ids of recently chosen locations, newest first. Kept on this device.

abstract class _$RecentLocations extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the first-run starter suggestion was accepted or skipped.

@ProviderFor(StarterLocationsDone)
final starterLocationsDoneProvider = StarterLocationsDoneProvider._();

/// Whether the first-run starter suggestion was accepted or skipped.
final class StarterLocationsDoneProvider
    extends $NotifierProvider<StarterLocationsDone, bool> {
  /// Whether the first-run starter suggestion was accepted or skipped.
  StarterLocationsDoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'starterLocationsDoneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$starterLocationsDoneHash();

  @$internal
  @override
  StarterLocationsDone create() => StarterLocationsDone();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$starterLocationsDoneHash() =>
    r'078a9a1b482bcf08bb9a635d5bf6a8c3ec337618';

/// Whether the first-run starter suggestion was accepted or skipped.

abstract class _$StarterLocationsDone extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

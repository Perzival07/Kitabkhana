// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'0eda22c9c7a5e68c8661bf58b528d73264ef9a19';

/// Settings as they change.

@ProviderFor(settingsStream)
final settingsStreamProvider = SettingsStreamProvider._();

/// Settings as they change.

final class SettingsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppSettings>,
          AppSettings,
          Stream<AppSettings>
        >
    with $FutureModifier<AppSettings>, $StreamProvider<AppSettings> {
  /// Settings as they change.
  SettingsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsStreamHash();

  @$internal
  @override
  $StreamProviderElement<AppSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppSettings> create(Ref ref) {
    return settingsStream(ref);
  }
}

String _$settingsStreamHash() => r'9e1fe07f7956bb538d258576139962e8e9207b79';

/// The current settings: the defaults until they have loaded.

@ProviderFor(appSettings)
final appSettingsProvider = AppSettingsProvider._();

/// The current settings: the defaults until they have loaded.

final class AppSettingsProvider
    extends $FunctionalProvider<AppSettings, AppSettings, AppSettings>
    with $Provider<AppSettings> {
  /// The current settings: the defaults until they have loaded.
  AppSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsHash();

  @$internal
  @override
  $ProviderElement<AppSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppSettings create(Ref ref) {
    return appSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$appSettingsHash() => r'b9e6fbd74159a3addc72226e74536c4c84bc35d8';

/// Opens links and mail apps. Tests swap in a fake.

@ProviderFor(externalLauncher)
final externalLauncherProvider = ExternalLauncherProvider._();

/// Opens links and mail apps. Tests swap in a fake.

final class ExternalLauncherProvider
    extends $FunctionalProvider<NudgeLauncher, NudgeLauncher, NudgeLauncher>
    with $Provider<NudgeLauncher> {
  /// Opens links and mail apps. Tests swap in a fake.
  ExternalLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'externalLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$externalLauncherHash();

  @$internal
  @override
  $ProviderElement<NudgeLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NudgeLauncher create(Ref ref) {
    return externalLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NudgeLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NudgeLauncher>(value),
    );
  }
}

String _$externalLauncherHash() => r'52fe645d0c49bfb3685e74dc4db95a772af7b473';

/// Where the app opens: the introduction on first run (and after erasing
/// everything), the library otherwise. `bootstrap` sets it before the first
/// screen; tests leave it at the library.

@ProviderFor(InitialRoute)
final initialRouteProvider = InitialRouteProvider._();

/// Where the app opens: the introduction on first run (and after erasing
/// everything), the library otherwise. `bootstrap` sets it before the first
/// screen; tests leave it at the library.
final class InitialRouteProvider
    extends $NotifierProvider<InitialRoute, String> {
  /// Where the app opens: the introduction on first run (and after erasing
  /// everything), the library otherwise. `bootstrap` sets it before the first
  /// screen; tests leave it at the library.
  InitialRouteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialRouteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialRouteHash();

  @$internal
  @override
  InitialRoute create() => InitialRoute();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$initialRouteHash() => r'cf28eb92cafaa3e9f9888c62ec853ddbf6b068ce';

/// Where the app opens: the introduction on first run (and after erasing
/// everything), the library otherwise. `bootstrap` sets it before the first
/// screen; tests leave it at the library.

abstract class _$InitialRoute extends $Notifier<String> {
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

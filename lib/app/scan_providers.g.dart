// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Do I already own this?" over the local library and the lookup cache.

@ProviderFor(checkOwnership)
final checkOwnershipProvider = CheckOwnershipProvider._();

/// "Do I already own this?" over the local library and the lookup cache.

final class CheckOwnershipProvider
    extends $FunctionalProvider<CheckOwnership, CheckOwnership, CheckOwnership>
    with $Provider<CheckOwnership> {
  /// "Do I already own this?" over the local library and the lookup cache.
  CheckOwnershipProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkOwnershipProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkOwnershipHash();

  @$internal
  @override
  $ProviderElement<CheckOwnership> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CheckOwnership create(Ref ref) {
    return checkOwnership(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckOwnership value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckOwnership>(value),
    );
  }
}

String _$checkOwnershipHash() => r'4d7c46cec5bf7ad6540fca0b8ae400fa8272517e';

/// Camera permission, overridden in tests.

@ProviderFor(cameraPermission)
final cameraPermissionProvider = CameraPermissionProvider._();

/// Camera permission, overridden in tests.

final class CameraPermissionProvider
    extends
        $FunctionalProvider<
          CameraPermissionService,
          CameraPermissionService,
          CameraPermissionService
        >
    with $Provider<CameraPermissionService> {
  /// Camera permission, overridden in tests.
  CameraPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraPermissionHash();

  @$internal
  @override
  $ProviderElement<CameraPermissionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CameraPermissionService create(Ref ref) {
    return cameraPermission(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CameraPermissionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CameraPermissionService>(value),
    );
  }
}

String _$cameraPermissionHash() => r'a1c2d85b52e9bd85cfd9104049580ced9cd4580d';

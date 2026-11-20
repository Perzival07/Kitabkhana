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

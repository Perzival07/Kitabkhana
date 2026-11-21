// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every tag with how many books carry it.

@ProviderFor(tagsWithCounts)
final tagsWithCountsProvider = TagsWithCountsProvider._();

/// Every tag with how many books carry it.

final class TagsWithCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TagWithCount>>,
          List<TagWithCount>,
          Stream<List<TagWithCount>>
        >
    with
        $FutureModifier<List<TagWithCount>>,
        $StreamProvider<List<TagWithCount>> {
  /// Every tag with how many books carry it.
  TagsWithCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagsWithCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagsWithCountsHash();

  @$internal
  @override
  $StreamProviderElement<List<TagWithCount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TagWithCount>> create(Ref ref) {
    return tagsWithCounts(ref);
  }
}

String _$tagsWithCountsHash() => r'f773e27c4a9ad2f4f9ceb8d80a00ac5f0849c406';

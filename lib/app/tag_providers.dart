import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/tags/domain/tag_repository.dart';
import 'repositories.dart';

part 'tag_providers.g.dart';

/// Every tag with how many books carry it.
@riverpod
Stream<List<TagWithCount>> tagsWithCounts(Ref ref) =>
    ref.watch(tagRepositoryProvider).watchWithCounts();

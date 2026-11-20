import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/scan_check/application/check_ownership.dart';
import 'lookup_providers.dart';
import 'repositories.dart';

part 'scan_providers.g.dart';

/// "Do I already own this?" over the local library and the lookup cache.
@Riverpod(keepAlive: true)
CheckOwnership checkOwnership(Ref ref) => CheckOwnership(
  books: ref.watch(bookRepositoryProvider),
  loans: ref.watch(loanRepositoryProvider),
  locations: ref.watch(locationRepositoryProvider),
  lookup: ref.watch(bookLookupServiceProvider),
);

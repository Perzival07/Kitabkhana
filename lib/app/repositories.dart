import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/db/database_provider.dart';
import '../features/lending/data/drift_loan_repository.dart';
import '../features/lending/domain/loan_repository.dart';
import '../features/library/data/drift_book_repository.dart';
import '../features/library/domain/book_repository.dart';
import '../features/locations/data/drift_location_repository.dart';
import '../features/locations/domain/location_repository.dart';
import '../features/quotes/data/drift_quote_repository.dart';
import '../features/quotes/domain/quote_repository.dart';
import '../features/reading/data/drift_reading_repository.dart';
import '../features/reading/domain/reading_repository.dart';
import '../features/stats/data/drift_goal_repository.dart';
import '../features/stats/data/drift_stats_repository.dart';
import '../features/stats/domain/stats_repository.dart';
import '../features/stats/domain/goal_repository.dart';
import '../features/tags/data/drift_tag_repository.dart';
import '../features/tags/domain/tag_repository.dart';
import 'providers.dart';

part 'repositories.g.dart';

// Repository providers live for the app's lifetime and never retry: a failing
// database should surface immediately.

@Riverpod(keepAlive: true, retry: noRetry)
BookRepository bookRepository(Ref ref) => DriftBookRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true, retry: noRetry)
LocationRepository locationRepository(Ref ref) => DriftLocationRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true, retry: noRetry)
LoanRepository loanRepository(Ref ref) => DriftLoanRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true, retry: noRetry)
ReadingRepository readingRepository(Ref ref) => DriftReadingRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true, retry: noRetry)
QuoteRepository quoteRepository(Ref ref) => DriftQuoteRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true, retry: noRetry)
GoalRepository goalRepository(Ref ref) => DriftGoalRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true, retry: noRetry)
TagRepository tagRepository(Ref ref) => DriftTagRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@Riverpod(keepAlive: true, retry: noRetry)
StatsRepository statsRepository(Ref ref) =>
    DriftStatsRepository(ref.watch(appDatabaseProvider));

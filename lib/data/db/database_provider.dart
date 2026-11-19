import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config_provider.dart';
import '../../app/providers.dart';
import 'app_database.dart';
import 'connection.dart';

part 'database_provider.g.dart';

/// Database providers never retry automatically: a failed open should surface
/// immediately instead of looping.
Duration? noRetry(int retryCount, Object error) => null;

/// The app database, opened once for the app's lifetime.
@Riverpod(keepAlive: true, retry: noRetry)
AppDatabase appDatabase(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final db = AppDatabase(
    openAppConnection(),
    logger: ref.watch(appLoggerProvider),
    runIntegrityCheck: config.isDev,
  );
  ref.onDispose(db.close);
  return db;
}

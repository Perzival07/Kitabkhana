import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_config.dart';

part 'app_config_provider.g.dart';

/// The flavor config; overridden in `bootstrap` (and in tests).
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) =>
    throw StateError('appConfigProvider must be overridden');

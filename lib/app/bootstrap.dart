import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';
import 'app_root.dart';
import 'theme/font_licenses.dart';
import 'theme/system_ui.dart';

/// Shared entry point used by every flavor's `main_*.dart`.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  enableEdgeToEdge();
  registerFontLicenses();
  runApp(ProviderScope(child: AppRoot(config: config)));
}

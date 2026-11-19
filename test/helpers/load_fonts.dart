import 'package:flutter/services.dart';

/// Loads the bundled Fraunces and Inter fonts and the Material icon font so
/// tests render real glyphs (flutter_test otherwise substitutes blocks).
Future<void> loadAppFonts() async {
  const families = <String, List<String>>{
    'Fraunces': <String>[
      'assets/fonts/Fraunces-400.ttf',
      'assets/fonts/Fraunces-500.ttf',
      'assets/fonts/Fraunces-600.ttf',
      'assets/fonts/Fraunces-700.ttf',
      'assets/fonts/Fraunces-Italic-400.ttf',
    ],
    'Inter': <String>[
      'assets/fonts/Inter-400.ttf',
      'assets/fonts/Inter-500.ttf',
      'assets/fonts/Inter-600.ttf',
      'assets/fonts/Inter-700.ttf',
    ],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      loader.addFont(rootBundle.load(path));
    }
    await loader.load();
  }
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();
}

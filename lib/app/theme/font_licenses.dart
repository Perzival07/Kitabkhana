import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registers the bundled fonts' OFL licenses with the license page.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final entry in const <String, String>{
      'Fraunces': 'assets/licenses/OFL-Fraunces.txt',
      'Inter': 'assets/licenses/OFL-Inter.txt',
    }.entries) {
      final text = await rootBundle.loadString(entry.value);
      yield LicenseEntryWithLineBreaks(<String>[entry.key], text);
    }
  });
}

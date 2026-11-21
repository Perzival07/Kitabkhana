import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lending_providers.dart';
import 'library_providers.dart';
import 'location_providers.dart';
import 'theme/theme_mode_provider.dart';

/// Forgets settings that were loaded from the (now erased) database, so the
/// app starts over with its defaults instead of what was there before.
void resetSettingsState(WidgetRef ref) {
  ref
    ..invalidate(defaultCountryCodeProvider)
    ..invalidate(libraryQueryControllerProvider)
    ..invalidate(libraryViewControllerProvider)
    ..invalidate(selectedBookIdProvider)
    ..invalidate(recentLocationsProvider)
    ..invalidate(starterLocationsDoneProvider)
    ..invalidate(themeModeControllerProvider);
}

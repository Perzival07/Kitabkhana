// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String coverSemantics(String title, String author) {
    return 'Cover of $title by $author';
  }

  @override
  String coverSemanticsNoAuthor(String title) {
    return 'Cover of $title';
  }

  @override
  String get statusWant => 'Want to read';

  @override
  String get statusReading => 'Reading';

  @override
  String get statusFinished => 'Finished';

  @override
  String get statusDropped => 'Dropped';

  @override
  String get seeAll => 'See all';

  @override
  String get loading => 'Loading';

  @override
  String percentSemantics(int percent) {
    return '$percent percent';
  }

  @override
  String get appName => 'Kitabkhana';

  @override
  String get navLibrary => 'Library';

  @override
  String get navScan => 'Scan';

  @override
  String get navReading => 'Reading';

  @override
  String get navStats => 'Stats';

  @override
  String get navMore => 'More';

  @override
  String get libraryTitle => 'Your library';

  @override
  String get libraryEmptyBody =>
      'Your books will live here. Add the first one soon.';

  @override
  String get scanTitle => 'Never buy it twice';

  @override
  String get scanEmptyBody =>
      'Scan a barcode to check whether you already own a book.';

  @override
  String get readingTitle => 'Now reading';

  @override
  String get readingEmptyBody =>
      'Your progress, streaks and pace will show up here.';

  @override
  String get statsTitle => 'Your reading year';

  @override
  String get statsEmptyBody =>
      'Goals and charts will appear once you log some reading.';

  @override
  String get moreTitle => 'More';

  @override
  String get moreEmptyBody =>
      'Loans, quotes, locations and settings live here.';

  @override
  String get routeAddBook => 'Add a book';

  @override
  String get routeBook => 'Book';

  @override
  String get routeEditBook => 'Edit book';

  @override
  String get routeLoans => 'Loans';

  @override
  String get routeQuotes => 'Quotes';

  @override
  String get routeLocations => 'Locations';

  @override
  String get routeSettings => 'Settings';

  @override
  String get routeOnboarding => 'Welcome';

  @override
  String get routeStubBody => 'This screen is on its way.';

  @override
  String get notFoundTitle => 'We can\'t find that page';

  @override
  String get notFoundBody => 'The link may be old or mistyped.';

  @override
  String get goToLibrary => 'Go to your library';

  @override
  String get detailPlaceholderTitle => 'Pick a book';

  @override
  String get detailPlaceholderBody =>
      'Choose a book on the left to see its details here.';

  @override
  String get failureOffline =>
      'You appear to be offline. Everything else still works.';

  @override
  String get failureTimeout => 'That took too long. Please try again.';

  @override
  String get failureServer =>
      'The book service is having trouble. Please try again later.';

  @override
  String get failureRateLimited =>
      'Too many lookups at once. Give it a moment.';

  @override
  String get failureNotFound => 'We couldn\'t find that.';

  @override
  String get failureValidation => 'Please check what you entered.';

  @override
  String get failureConflict => 'That conflicts with something already saved.';

  @override
  String get failureBookAlreadyLent => 'This book is already lent out.';

  @override
  String get failureStorage => 'We couldn\'t save that on this device.';

  @override
  String get failurePermissionCamera =>
      'Camera access is needed to scan barcodes.';

  @override
  String get failurePermissionNotifications =>
      'Notifications are needed for loan reminders.';

  @override
  String get failurePermissionFiles => 'File access is needed to do that.';

  @override
  String get failureUnsupported => 'That isn\'t available on this device.';

  @override
  String get failureUnexpected => 'Something went wrong. Please try again.';

  @override
  String get errorWidgetTitle => 'Something went wrong here';

  @override
  String get errorWidgetBody => 'Go back and try again. Your library is safe.';
}

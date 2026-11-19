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

  @override
  String get addBookTitle => 'Add a book';

  @override
  String get addScanTitle => 'Scan barcode';

  @override
  String get addScanBody => 'Point your camera at the back cover';

  @override
  String get addIsbnTitle => 'Type ISBN';

  @override
  String get addIsbnBody => 'Enter the 10 or 13 digit number';

  @override
  String get addSearchTitle => 'Search by title';

  @override
  String get addSearchBody => 'Find it in the Open Library catalogue';

  @override
  String get addManualTitle => 'Enter manually';

  @override
  String get addManualBody => 'Fill in the details yourself';

  @override
  String get scanHint => 'Point at the barcode on the back cover';

  @override
  String get scanUnavailableTitle => 'Camera scanning isn\'t available here';

  @override
  String get scanUnavailableBody =>
      'You can still add the book by typing its ISBN.';

  @override
  String get isbnFieldLabel => 'ISBN';

  @override
  String get isbnFieldHint => '978…';

  @override
  String get isbnInvalid =>
      'That doesn\'t look like a valid ISBN. Please check the digits.';

  @override
  String get isbnIncomplete => 'An ISBN has 10 or 13 digits.';

  @override
  String get isbnValid => 'Valid ISBN';

  @override
  String get lookUp => 'Look up';

  @override
  String get pasteFromClipboard => 'Paste';

  @override
  String get lookingUp => 'Looking it up…';

  @override
  String get lookupNotFound =>
      'We couldn\'t find that ISBN. You can fill in the details yourself.';

  @override
  String get searchFieldHint => 'Search by title or author';

  @override
  String get searchPrompt => 'Type a title to search the catalogue.';

  @override
  String get searchNoResults =>
      'No matches. Try different words, or enter the book manually.';

  @override
  String get searchOffline =>
      'You\'re offline, so catalogue search isn\'t available. You can still enter the book manually.';

  @override
  String get searchFailed =>
      'Search didn\'t work this time. You can try again or enter the book manually.';

  @override
  String get enterManually => 'Enter manually';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldSubtitle => 'Subtitle';

  @override
  String get fieldAuthors => 'Authors';

  @override
  String get fieldPages => 'Pages';

  @override
  String get fieldGenre => 'Genre';

  @override
  String get fieldLanguage => 'Language';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldOwnership => 'Ownership';

  @override
  String get fieldStatus => 'Reading status';

  @override
  String get fieldLocation => 'Location';

  @override
  String get noLocation => 'No location';

  @override
  String get ownershipOwned => 'Owned';

  @override
  String get ownershipWishlist => 'Wishlist';

  @override
  String get ownershipBorrowed => 'Borrowed';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get pagesInvalid => 'Pages must be a whole number above 0';

  @override
  String get save => 'Save';

  @override
  String get saveAndAddAnother => 'Save and add another';

  @override
  String get coverSection => 'Cover';

  @override
  String get coverTakePhoto => 'Take photo';

  @override
  String get coverChoosePhoto => 'Choose photo';

  @override
  String get coverUseGenerated => 'Use generated cover';

  @override
  String get coverPhotoFailed => 'We couldn\'t use that photo.';

  @override
  String get fromCatalogue =>
      'From the Open Library catalogue. Edit anything before saving.';

  @override
  String get duplicateTitle => 'You may already have this';

  @override
  String duplicateBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'These look like books you already have.',
      one: 'This looks like a book you already have.',
    );
    return '$_temp0';
  }

  @override
  String get openExisting => 'Open existing';

  @override
  String get addAnotherCopy => 'Add another copy';

  @override
  String get cancel => 'Cancel';

  @override
  String addedTo(String location) {
    return 'Added to $location';
  }

  @override
  String get addedToLibrary => 'Added to your library';

  @override
  String get view => 'View';

  @override
  String get saveFailed => 'We couldn\'t save that. Please try again.';

  @override
  String inLocation(String location) {
    return 'In $location';
  }

  @override
  String yearAndPages(int year, int pages) {
    return '$year · $pages pages';
  }

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '$count page',
    );
    return '$_temp0';
  }

  @override
  String get tryAgain => 'Try again';
}

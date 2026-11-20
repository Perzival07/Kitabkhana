import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @coverSemantics.
  ///
  /// In en, this message translates to:
  /// **'Cover of {title} by {author}'**
  String coverSemantics(String title, String author);

  /// No description provided for @coverSemanticsNoAuthor.
  ///
  /// In en, this message translates to:
  /// **'Cover of {title}'**
  String coverSemanticsNoAuthor(String title);

  /// No description provided for @statusWant.
  ///
  /// In en, this message translates to:
  /// **'Want to read'**
  String get statusWant;

  /// No description provided for @statusReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get statusReading;

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// No description provided for @statusDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get statusDropped;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @percentSemantics.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String percentSemantics(int percent);

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Kitabkhana'**
  String get appName;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get navReading;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library'**
  String get libraryTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first book and start building your shelf.'**
  String get libraryEmptyBody;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Never buy it twice'**
  String get scanTitle;

  /// No description provided for @scanEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode to check whether you already own a book.'**
  String get scanEmptyBody;

  /// No description provided for @readingTitle.
  ///
  /// In en, this message translates to:
  /// **'Now reading'**
  String get readingTitle;

  /// No description provided for @readingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress, streaks and pace will show up here.'**
  String get readingEmptyBody;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your reading year'**
  String get statsTitle;

  /// No description provided for @statsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Goals and charts will appear once you log some reading.'**
  String get statsEmptyBody;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @moreEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Loans, quotes, locations and settings live here.'**
  String get moreEmptyBody;

  /// No description provided for @routeAddBook.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get routeAddBook;

  /// No description provided for @routeBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get routeBook;

  /// No description provided for @routeEditBook.
  ///
  /// In en, this message translates to:
  /// **'Edit book'**
  String get routeEditBook;

  /// No description provided for @routeLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get routeLoans;

  /// No description provided for @routeQuotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get routeQuotes;

  /// No description provided for @routeLocations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get routeLocations;

  /// No description provided for @routeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get routeSettings;

  /// No description provided for @routeOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get routeOnboarding;

  /// No description provided for @routeStubBody.
  ///
  /// In en, this message translates to:
  /// **'This screen is on its way.'**
  String get routeStubBody;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'We can\'t find that page'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The link may be old or mistyped.'**
  String get notFoundBody;

  /// No description provided for @goToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Go to your library'**
  String get goToLibrary;

  /// No description provided for @detailPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a book'**
  String get detailPlaceholderTitle;

  /// No description provided for @detailPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a book on the left to see its details here.'**
  String get detailPlaceholderBody;

  /// No description provided for @failureOffline.
  ///
  /// In en, this message translates to:
  /// **'You appear to be offline. Everything else still works.'**
  String get failureOffline;

  /// No description provided for @failureTimeout.
  ///
  /// In en, this message translates to:
  /// **'That took too long. Please try again.'**
  String get failureTimeout;

  /// No description provided for @failureServer.
  ///
  /// In en, this message translates to:
  /// **'The book service is having trouble. Please try again later.'**
  String get failureServer;

  /// No description provided for @failureRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many lookups at once. Give it a moment.'**
  String get failureRateLimited;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that.'**
  String get failureNotFound;

  /// No description provided for @failureValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check what you entered.'**
  String get failureValidation;

  /// No description provided for @failureConflict.
  ///
  /// In en, this message translates to:
  /// **'That conflicts with something already saved.'**
  String get failureConflict;

  /// No description provided for @failureBookAlreadyLent.
  ///
  /// In en, this message translates to:
  /// **'This book is already lent out.'**
  String get failureBookAlreadyLent;

  /// No description provided for @failureStorage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save that on this device.'**
  String get failureStorage;

  /// No description provided for @failurePermissionCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to scan barcodes.'**
  String get failurePermissionCamera;

  /// No description provided for @failurePermissionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications are needed for loan reminders.'**
  String get failurePermissionNotifications;

  /// No description provided for @failurePermissionFiles.
  ///
  /// In en, this message translates to:
  /// **'File access is needed to do that.'**
  String get failurePermissionFiles;

  /// No description provided for @failureUnsupported.
  ///
  /// In en, this message translates to:
  /// **'That isn\'t available on this device.'**
  String get failureUnsupported;

  /// No description provided for @failureUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get failureUnexpected;

  /// No description provided for @errorWidgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong here'**
  String get errorWidgetTitle;

  /// No description provided for @errorWidgetBody.
  ///
  /// In en, this message translates to:
  /// **'Go back and try again. Your library is safe.'**
  String get errorWidgetBody;

  /// No description provided for @addBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get addBookTitle;

  /// No description provided for @addScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get addScanTitle;

  /// No description provided for @addScanBody.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the back cover'**
  String get addScanBody;

  /// No description provided for @addIsbnTitle.
  ///
  /// In en, this message translates to:
  /// **'Type ISBN'**
  String get addIsbnTitle;

  /// No description provided for @addIsbnBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the 10 or 13 digit number'**
  String get addIsbnBody;

  /// No description provided for @addSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by title'**
  String get addSearchTitle;

  /// No description provided for @addSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Find it in the Open Library catalogue'**
  String get addSearchBody;

  /// No description provided for @addManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get addManualTitle;

  /// No description provided for @addManualBody.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details yourself'**
  String get addManualBody;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point at the barcode on the back cover'**
  String get scanHint;

  /// No description provided for @scanUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning isn\'t available here'**
  String get scanUnavailableTitle;

  /// No description provided for @scanUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'You can still add the book by typing its ISBN.'**
  String get scanUnavailableBody;

  /// No description provided for @isbnFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get isbnFieldLabel;

  /// No description provided for @isbnFieldHint.
  ///
  /// In en, this message translates to:
  /// **'978…'**
  String get isbnFieldHint;

  /// No description provided for @isbnInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid ISBN. Please check the digits.'**
  String get isbnInvalid;

  /// No description provided for @isbnIncomplete.
  ///
  /// In en, this message translates to:
  /// **'An ISBN has 10 or 13 digits.'**
  String get isbnIncomplete;

  /// No description provided for @isbnValid.
  ///
  /// In en, this message translates to:
  /// **'Valid ISBN'**
  String get isbnValid;

  /// No description provided for @lookUp.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get lookUp;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get pasteFromClipboard;

  /// No description provided for @lookingUp.
  ///
  /// In en, this message translates to:
  /// **'Looking it up…'**
  String get lookingUp;

  /// No description provided for @lookupNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that ISBN. You can fill in the details yourself.'**
  String get lookupNotFound;

  /// No description provided for @searchFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title or author'**
  String get searchFieldHint;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a title to search the catalogue.'**
  String get searchPrompt;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matches. Try different words, or enter the book manually.'**
  String get searchNoResults;

  /// No description provided for @searchOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline, so catalogue search isn\'t available. You can still enter the book manually.'**
  String get searchOffline;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search didn\'t work this time. You can try again or enter the book manually.'**
  String get searchFailed;

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterManually;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get fieldSubtitle;

  /// No description provided for @fieldAuthors.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get fieldAuthors;

  /// No description provided for @fieldPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get fieldPages;

  /// No description provided for @fieldGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get fieldGenre;

  /// No description provided for @fieldLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get fieldLanguage;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @fieldOwnership.
  ///
  /// In en, this message translates to:
  /// **'Ownership'**
  String get fieldOwnership;

  /// No description provided for @fieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Reading status'**
  String get fieldStatus;

  /// No description provided for @fieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get fieldLocation;

  /// No description provided for @noLocation.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get noLocation;

  /// No description provided for @ownershipOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get ownershipOwned;

  /// No description provided for @ownershipWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get ownershipWishlist;

  /// No description provided for @ownershipBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get ownershipBorrowed;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get titleRequired;

  /// No description provided for @pagesInvalid.
  ///
  /// In en, this message translates to:
  /// **'Pages must be a whole number above 0'**
  String get pagesInvalid;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAndAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Save and add another'**
  String get saveAndAddAnother;

  /// No description provided for @coverSection.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get coverSection;

  /// No description provided for @coverTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get coverTakePhoto;

  /// No description provided for @coverChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get coverChoosePhoto;

  /// No description provided for @coverUseGenerated.
  ///
  /// In en, this message translates to:
  /// **'Use generated cover'**
  String get coverUseGenerated;

  /// No description provided for @coverPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t use that photo.'**
  String get coverPhotoFailed;

  /// No description provided for @fromCatalogue.
  ///
  /// In en, this message translates to:
  /// **'From the Open Library catalogue. Edit anything before saving.'**
  String get fromCatalogue;

  /// No description provided for @duplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'You may already have this'**
  String get duplicateTitle;

  /// No description provided for @duplicateBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{This looks like a book you already have.} other{These look like books you already have.}}'**
  String duplicateBody(int count);

  /// No description provided for @openExisting.
  ///
  /// In en, this message translates to:
  /// **'Open existing'**
  String get openExisting;

  /// No description provided for @addAnotherCopy.
  ///
  /// In en, this message translates to:
  /// **'Add another copy'**
  String get addAnotherCopy;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addedTo.
  ///
  /// In en, this message translates to:
  /// **'Added to {location}'**
  String addedTo(String location);

  /// No description provided for @addedToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Added to your library'**
  String get addedToLibrary;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save that. Please try again.'**
  String get saveFailed;

  /// No description provided for @inLocation.
  ///
  /// In en, this message translates to:
  /// **'In {location}'**
  String inLocation(String location);

  /// No description provided for @yearAndPages.
  ///
  /// In en, this message translates to:
  /// **'{year} · {pages} pages'**
  String yearAndPages(int year, int pages);

  /// No description provided for @pagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} page} other{{count} pages}}'**
  String pagesCount(int count);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @libraryBooksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} book} other{{count} books}}'**
  String libraryBooksCount(int count);

  /// No description provided for @libraryLentOutCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lent out'**
  String libraryLentOutCount(int count);

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title or author'**
  String get librarySearchHint;

  /// No description provided for @libraryScanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode'**
  String get libraryScanTooltip;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get filterWishlist;

  /// No description provided for @filterLentOut.
  ///
  /// In en, this message translates to:
  /// **'Lent out'**
  String get filterLentOut;

  /// No description provided for @filterBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get filterBorrowed;

  /// No description provided for @filterLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filterLocation;

  /// No description provided for @filterTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get filterTag;

  /// No description provided for @filterAnyLocation.
  ///
  /// In en, this message translates to:
  /// **'Any location'**
  String get filterAnyLocation;

  /// No description provided for @filterAnyTag.
  ///
  /// In en, this message translates to:
  /// **'Any tag'**
  String get filterAnyTag;

  /// No description provided for @filterNoTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get filterNoTags;

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @sortRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sortRecentlyAdded;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @sortAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get sortAuthor;

  /// No description provided for @sortRecentlyRead.
  ///
  /// In en, this message translates to:
  /// **'Recently read'**
  String get sortRecentlyRead;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sortRating;

  /// No description provided for @viewAsGrid.
  ///
  /// In en, this message translates to:
  /// **'Show as grid'**
  String get viewAsGrid;

  /// No description provided for @viewAsList.
  ///
  /// In en, this message translates to:
  /// **'Show as list'**
  String get viewAsList;

  /// No description provided for @addBook.
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get addBook;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shelf is empty'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add your first book'**
  String get libraryAddFirst;

  /// No description provided for @libraryScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode'**
  String get libraryScanBarcode;

  /// No description provided for @libraryNoResultsQuery.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”'**
  String libraryNoResultsQuery(String query);

  /// No description provided for @libraryNoResultsFilters.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters'**
  String get libraryNoResultsFilters;

  /// No description provided for @libraryClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get libraryClearFilters;

  /// No description provided for @lentRibbon.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get lentRibbon;

  /// No description provided for @quickChangeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get quickChangeStatus;

  /// No description provided for @quickMove.
  ///
  /// In en, this message translates to:
  /// **'Move to a location'**
  String get quickMove;

  /// No description provided for @quickDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get quickDelete;

  /// No description provided for @bookDeleted.
  ///
  /// In en, this message translates to:
  /// **'“{title}” deleted'**
  String bookDeleted(String title);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @bookMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved “{title}”'**
  String bookMoved(String title);

  /// No description provided for @bookStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'Marked “{title}” {status}'**
  String bookStatusChanged(String title, String status);

  /// No description provided for @seedDemoData.
  ///
  /// In en, this message translates to:
  /// **'Add 300 demo books'**
  String get seedDemoData;

  /// No description provided for @seedDemoDone.
  ///
  /// In en, this message translates to:
  /// **'{count} demo books added'**
  String seedDemoDone(int count);

  /// No description provided for @libraryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your books'**
  String get libraryLoadFailed;

  /// No description provided for @locationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get locationsTitle;

  /// No description provided for @locationsBookCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No books} =1{1 book} other{{count} books}}'**
  String locationsBookCount(int count);

  /// No description provided for @locationAdd.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get locationAdd;

  /// No description provided for @locationRename.
  ///
  /// In en, this message translates to:
  /// **'Rename location'**
  String get locationRename;

  /// No description provided for @locationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get locationNameLabel;

  /// No description provided for @locationNameExists.
  ///
  /// In en, this message translates to:
  /// **'You already have a location with that name.'**
  String get locationNameExists;

  /// No description provided for @locationNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Give the location a name.'**
  String get locationNameEmpty;

  /// No description provided for @locationIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get locationIconLabel;

  /// No description provided for @locationIconShelf.
  ///
  /// In en, this message translates to:
  /// **'Shelf'**
  String get locationIconShelf;

  /// No description provided for @locationIconBox.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get locationIconBox;

  /// No description provided for @locationIconRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get locationIconRoom;

  /// No description provided for @locationIconBag.
  ///
  /// In en, this message translates to:
  /// **'Bag'**
  String get locationIconBag;

  /// No description provided for @locationIconOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get locationIconOffice;

  /// No description provided for @locationIconOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get locationIconOther;

  /// No description provided for @locationParentLabel.
  ///
  /// In en, this message translates to:
  /// **'Inside (optional)'**
  String get locationParentLabel;

  /// No description provided for @locationNoParent.
  ///
  /// In en, this message translates to:
  /// **'Nothing — top level'**
  String get locationNoParent;

  /// No description provided for @locationEdit.
  ///
  /// In en, this message translates to:
  /// **'Rename or change icon'**
  String get locationEdit;

  /// No description provided for @locationDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete location'**
  String get locationDelete;

  /// No description provided for @locationDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String locationDeleteTitle(String name);

  /// No description provided for @locationDeleteEmpty.
  ///
  /// In en, this message translates to:
  /// **'No books are in this location.'**
  String get locationDeleteEmpty;

  /// No description provided for @locationMoveBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move 1 book to…} other{Move {count} books to…}}'**
  String locationMoveBooksTitle(int count);

  /// No description provided for @locationDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete and move'**
  String get locationDeleteConfirm;

  /// No description provided for @locationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Location deleted'**
  String get locationDeleted;

  /// No description provided for @locationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do your books live?'**
  String get locationsEmptyTitle;

  /// No description provided for @locationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add shelves, boxes or rooms so you can find any book fast.'**
  String get locationsEmptyBody;

  /// No description provided for @locationsStarterTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with these?'**
  String get locationsStarterTitle;

  /// No description provided for @locationsStarterAccept.
  ///
  /// In en, this message translates to:
  /// **'Add all three'**
  String get locationsStarterAccept;

  /// No description provided for @locationsStarterSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get locationsStarterSkip;

  /// No description provided for @starterLivingRoom.
  ///
  /// In en, this message translates to:
  /// **'Living room shelf'**
  String get starterLivingRoom;

  /// No description provided for @starterBedroom.
  ///
  /// In en, this message translates to:
  /// **'Bedroom shelf'**
  String get starterBedroom;

  /// No description provided for @starterStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage box'**
  String get starterStorage;

  /// No description provided for @locationReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get locationReorderHint;

  /// No description provided for @locationPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a location'**
  String get locationPickerTitle;

  /// No description provided for @locationPickerSearch.
  ///
  /// In en, this message translates to:
  /// **'Search or create'**
  String get locationPickerSearch;

  /// No description provided for @locationPickerRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get locationPickerRecent;

  /// No description provided for @locationPickerAll.
  ///
  /// In en, this message translates to:
  /// **'All locations'**
  String get locationPickerAll;

  /// No description provided for @locationCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create \"{name}\"'**
  String locationCreateNew(String name);

  /// No description provided for @locationCreateNewPlain.
  ///
  /// In en, this message translates to:
  /// **'Create new location'**
  String get locationCreateNewPlain;

  /// No description provided for @locationsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage locations'**
  String get locationsManage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

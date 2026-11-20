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

  /// No description provided for @bookNotFound.
  ///
  /// In en, this message translates to:
  /// **'This book is no longer in your library.'**
  String get bookNotFound;

  /// No description provided for @detailPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String detailPageOf(int current, int total);

  /// No description provided for @detailPercentRead.
  ///
  /// In en, this message translates to:
  /// **'{percent}% read'**
  String detailPercentRead(int percent);

  /// No description provided for @detailUpdatePage.
  ///
  /// In en, this message translates to:
  /// **'Update page'**
  String get detailUpdatePage;

  /// No description provided for @detailUpdatePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you now?'**
  String get detailUpdatePageTitle;

  /// No description provided for @detailPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get detailPageLabel;

  /// No description provided for @detailPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Percent read'**
  String get detailPercentLabel;

  /// No description provided for @detailPageDecrease.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get detailPageDecrease;

  /// No description provided for @detailPageIncrease.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get detailPageIncrease;

  /// No description provided for @paceDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{About 1 day left at your pace} other{About {count} days left at your pace}}'**
  String paceDaysLeft(int count);

  /// No description provided for @paceFinishBy.
  ///
  /// In en, this message translates to:
  /// **'Finish by {date}'**
  String paceFinishBy(String date);

  /// No description provided for @progressReachedEnd.
  ///
  /// In en, this message translates to:
  /// **'That\'s the last page!'**
  String get progressReachedEnd;

  /// No description provided for @progressMarkFinished.
  ///
  /// In en, this message translates to:
  /// **'Mark as finished'**
  String get progressMarkFinished;

  /// No description provided for @detailPageInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 0 to {max}'**
  String detailPageInvalid(int max);

  /// No description provided for @detailRateIt.
  ///
  /// In en, this message translates to:
  /// **'Rate it?'**
  String get detailRateIt;

  /// No description provided for @detailRateStar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Rate 1 star} other{Rate {count} stars}}'**
  String detailRateStar(int count);

  /// No description provided for @detailFinishedCelebration.
  ///
  /// In en, this message translates to:
  /// **'Finished! Nice one.'**
  String get detailFinishedCelebration;

  /// No description provided for @detailChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get detailChange;

  /// No description provided for @detailLentTo.
  ///
  /// In en, this message translates to:
  /// **'Lent to {name} since {since}'**
  String detailLentTo(String name, String since);

  /// No description provided for @detailBorrowedFrom.
  ///
  /// In en, this message translates to:
  /// **'Borrowed from {name} since {since}'**
  String detailBorrowedFrom(String name, String since);

  /// No description provided for @detailDue.
  ///
  /// In en, this message translates to:
  /// **'due {date}'**
  String detailDue(String date);

  /// No description provided for @detailReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get detailReturn;

  /// No description provided for @detailReturned.
  ///
  /// In en, this message translates to:
  /// **'Marked as returned'**
  String get detailReturned;

  /// No description provided for @detailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get detailEdit;

  /// No description provided for @detailShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get detailShare;

  /// No description provided for @detailMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get detailMore;

  /// No description provided for @detailShareText.
  ///
  /// In en, this message translates to:
  /// **'{title} by {authors}'**
  String detailShareText(String title, String authors);

  /// No description provided for @detailShareTextNoAuthor.
  ///
  /// In en, this message translates to:
  /// **'{title}'**
  String detailShareTextNoAuthor(String title);

  /// No description provided for @detailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this book?'**
  String get detailDeleteTitle;

  /// No description provided for @detailDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It leaves your library. You can undo right after.'**
  String get detailDeleteBody;

  /// No description provided for @detailSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get detailSectionNotes;

  /// No description provided for @detailNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get detailNotesHint;

  /// No description provided for @detailNotesSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get detailNotesSaved;

  /// No description provided for @detailSectionTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get detailSectionTags;

  /// No description provided for @detailAddTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get detailAddTag;

  /// No description provided for @detailTagHint.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get detailTagHint;

  /// No description provided for @detailRemoveTag.
  ///
  /// In en, this message translates to:
  /// **'Remove tag {name}'**
  String detailRemoveTag(String name);

  /// No description provided for @detailSectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailSectionDetails;

  /// No description provided for @detailIsbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get detailIsbn;

  /// No description provided for @detailOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get detailOwner;

  /// No description provided for @detailAddedOn.
  ///
  /// In en, this message translates to:
  /// **'Added on'**
  String get detailAddedOn;

  /// No description provided for @detailStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get detailStarted;

  /// No description provided for @detailFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get detailFinished;

  /// No description provided for @detailBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get detailBack;

  /// No description provided for @detailPagesYear.
  ///
  /// In en, this message translates to:
  /// **'{pages} pages'**
  String detailPagesYear(int pages);

  /// No description provided for @editBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit book'**
  String get editBookTitle;

  /// No description provided for @bookSavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get bookSavedChanges;

  /// No description provided for @detailMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get detailMove;

  /// No description provided for @scanSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title'**
  String get scanSearchHint;

  /// No description provided for @scanTypeIsbn.
  ///
  /// In en, this message translates to:
  /// **'Type ISBN'**
  String get scanTypeIsbn;

  /// No description provided for @scanTorch.
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get scanTorch;

  /// No description provided for @scanSwitchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get scanSwitchCamera;

  /// No description provided for @scanPermTitle.
  ///
  /// In en, this message translates to:
  /// **'Let Kitabkhana use the camera'**
  String get scanPermTitle;

  /// No description provided for @scanPermBody.
  ///
  /// In en, this message translates to:
  /// **'The camera only reads barcodes on this device. Nothing is recorded or uploaded.'**
  String get scanPermBody;

  /// No description provided for @scanPermAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get scanPermAllow;

  /// No description provided for @scanDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'The camera is off'**
  String get scanDeniedTitle;

  /// No description provided for @scanDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Without the camera you can still search by title or type the ISBN.'**
  String get scanDeniedBody;

  /// No description provided for @scanTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get scanTryAgain;

  /// No description provided for @scanBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access is blocked'**
  String get scanBlockedTitle;

  /// No description provided for @scanBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Turn it on in Settings to scan barcodes. You can still search by title meanwhile.'**
  String get scanBlockedBody;

  /// No description provided for @scanOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get scanOpenSettings;

  /// No description provided for @scanNoCameraNote.
  ///
  /// In en, this message translates to:
  /// **'No camera here, so search by title or type the ISBN.'**
  String get scanNoCameraNote;

  /// No description provided for @scanWebHttpsNote.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning on the web needs a secure (HTTPS) page.'**
  String get scanWebHttpsNote;

  /// No description provided for @scanChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking your library…'**
  String get scanChecking;

  /// No description provided for @verdictOwned.
  ///
  /// In en, this message translates to:
  /// **'You own this'**
  String get verdictOwned;

  /// No description provided for @verdictOwnedWhere.
  ///
  /// In en, this message translates to:
  /// **'On {place}'**
  String verdictOwnedWhere(String place);

  /// No description provided for @verdictNoPlace.
  ///
  /// In en, this message translates to:
  /// **'No location set'**
  String get verdictNoPlace;

  /// No description provided for @verdictOtherEdition.
  ///
  /// In en, this message translates to:
  /// **'You own another edition'**
  String get verdictOtherEdition;

  /// No description provided for @verdictWishlist.
  ///
  /// In en, this message translates to:
  /// **'On your wishlist'**
  String get verdictWishlist;

  /// No description provided for @verdictMarkBought.
  ///
  /// In en, this message translates to:
  /// **'Mark as bought'**
  String get verdictMarkBought;

  /// No description provided for @verdictLentTo.
  ///
  /// In en, this message translates to:
  /// **'Lent to {name}'**
  String verdictLentTo(String name);

  /// No description provided for @verdictSince.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String verdictSince(String date);

  /// No description provided for @verdictBorrowedFrom.
  ///
  /// In en, this message translates to:
  /// **'Borrowed from {name}'**
  String verdictBorrowedFrom(String name);

  /// No description provided for @verdictBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get verdictBorrowed;

  /// No description provided for @verdictDidYouMean.
  ///
  /// In en, this message translates to:
  /// **'Did you mean…?'**
  String get verdictDidYouMean;

  /// No description provided for @verdictNoneOfThese.
  ///
  /// In en, this message translates to:
  /// **'None of these'**
  String get verdictNoneOfThese;

  /// No description provided for @verdictNotInLibrary.
  ///
  /// In en, this message translates to:
  /// **'Not in your library'**
  String get verdictNotInLibrary;

  /// No description provided for @verdictAddWishlist.
  ///
  /// In en, this message translates to:
  /// **'Add to wishlist'**
  String get verdictAddWishlist;

  /// No description provided for @verdictBoughtIt.
  ///
  /// In en, this message translates to:
  /// **'I bought it — add to library'**
  String get verdictBoughtIt;

  /// No description provided for @verdictOpenBook.
  ///
  /// In en, this message translates to:
  /// **'Open book'**
  String get verdictOpenBook;

  /// No description provided for @verdictScanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan another'**
  String get verdictScanAnother;

  /// No description provided for @verdictWishlistAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your wishlist'**
  String get verdictWishlistAdded;

  /// No description provided for @verdictBoughtDone.
  ///
  /// In en, this message translates to:
  /// **'Marked as bought'**
  String get verdictBoughtDone;

  /// No description provided for @verdictMatch.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String verdictMatch(int percent);

  /// No description provided for @verdictUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown title'**
  String get verdictUnknownTitle;

  /// No description provided for @scanSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'No barcode?'**
  String get scanSearchLabel;

  /// No description provided for @lendAction.
  ///
  /// In en, this message translates to:
  /// **'Lend'**
  String get lendAction;

  /// No description provided for @lendSheetTitleLend.
  ///
  /// In en, this message translates to:
  /// **'Lend this book'**
  String get lendSheetTitleLend;

  /// No description provided for @lendSheetTitleBorrow.
  ///
  /// In en, this message translates to:
  /// **'Borrowed this book'**
  String get lendSheetTitleBorrow;

  /// No description provided for @lendToggleLend.
  ///
  /// In en, this message translates to:
  /// **'Lend'**
  String get lendToggleLend;

  /// No description provided for @lendToggleBorrow.
  ///
  /// In en, this message translates to:
  /// **'Borrow'**
  String get lendToggleBorrow;

  /// No description provided for @lendPersonLent.
  ///
  /// In en, this message translates to:
  /// **'Lent to'**
  String get lendPersonLent;

  /// No description provided for @lendPersonBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed from'**
  String get lendPersonBorrowed;

  /// No description provided for @lendPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get lendPhone;

  /// No description provided for @lendPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Number, with country code if different'**
  String get lendPhoneHint;

  /// No description provided for @lendPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a phone number.'**
  String get lendPhoneInvalid;

  /// No description provided for @lendStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get lendStarted;

  /// No description provided for @lendDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get lendDue;

  /// No description provided for @lendDueNone.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get lendDueNone;

  /// No description provided for @lendDue1w.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get lendDue1w;

  /// No description provided for @lendDue2w.
  ///
  /// In en, this message translates to:
  /// **'2 weeks'**
  String get lendDue2w;

  /// No description provided for @lendDue1m.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get lendDue1m;

  /// No description provided for @lendDueCustom.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get lendDueCustom;

  /// No description provided for @lendNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get lendNote;

  /// No description provided for @lendSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get lendSave;

  /// No description provided for @lendNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Who has it?'**
  String get lendNameRequired;

  /// No description provided for @lendSaved.
  ///
  /// In en, this message translates to:
  /// **'Lent to {name}'**
  String lendSaved(String name);

  /// No description provided for @lendSavedBorrow.
  ///
  /// In en, this message translates to:
  /// **'Borrowed from {name}'**
  String lendSavedBorrow(String name);

  /// No description provided for @returnPickLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where does it go back?'**
  String get returnPickLocationTitle;

  /// No description provided for @returnPickLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Its old spot was deleted. Choose a new one.'**
  String get returnPickLocationBody;

  /// No description provided for @returnBorrowedTitle.
  ///
  /// In en, this message translates to:
  /// **'Returned to {name}'**
  String returnBorrowedTitle(String name);

  /// No description provided for @returnBorrowedRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from my library'**
  String get returnBorrowedRemove;

  /// No description provided for @returnBorrowedKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep it on my wishlist'**
  String get returnBorrowedKeep;

  /// No description provided for @failureNeedsName.
  ///
  /// In en, this message translates to:
  /// **'Add the person\'s name.'**
  String get failureNeedsName;

  /// No description provided for @reminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Loan reminders'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders when a lent or borrowed book is due'**
  String get reminderChannelDesc;

  /// No description provided for @reminderDueTitle.
  ///
  /// In en, this message translates to:
  /// **'“{book}” is due today'**
  String reminderDueTitle(String book);

  /// No description provided for @reminderLentDueBody.
  ///
  /// In en, this message translates to:
  /// **'{name} has it. A friendly nudge?'**
  String reminderLentDueBody(String name);

  /// No description provided for @reminderBorrowedDueBody.
  ///
  /// In en, this message translates to:
  /// **'Time to return it to {name}.'**
  String reminderBorrowedDueBody(String name);

  /// No description provided for @reminderOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'“{book}” is overdue'**
  String reminderOverdueTitle(String book);

  /// No description provided for @reminderLentOverdueBody.
  ///
  /// In en, this message translates to:
  /// **'{name} still has it. Send a reminder?'**
  String reminderLentOverdueBody(String name);

  /// No description provided for @reminderBorrowedOverdueBody.
  ///
  /// In en, this message translates to:
  /// **'Return it to {name} soon.'**
  String reminderBorrowedOverdueBody(String name);

  /// No description provided for @reminderPermTitle.
  ///
  /// In en, this message translates to:
  /// **'Get a nudge when it\'s due?'**
  String get reminderPermTitle;

  /// No description provided for @reminderPermBody.
  ///
  /// In en, this message translates to:
  /// **'Kitabkhana can remind you on the day a book is due. Reminders stay on this device.'**
  String get reminderPermBody;

  /// No description provided for @reminderPermAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get reminderPermAllow;

  /// No description provided for @reminderPermLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get reminderPermLater;

  /// No description provided for @nudgeMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}! 📚 Could you return “{book}” when you\'re done? Thanks!'**
  String nudgeMessage(String name, String book);

  /// No description provided for @nudgeWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Remind on WhatsApp'**
  String get nudgeWhatsApp;

  /// No description provided for @nudgeSms.
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get nudgeSms;

  /// No description provided for @nudgeNoPhone.
  ///
  /// In en, this message translates to:
  /// **'Add a phone number to send a reminder.'**
  String get nudgeNoPhone;

  /// No description provided for @nudgeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open a messaging app.'**
  String get nudgeFailed;

  /// No description provided for @overdueBannerOne.
  ///
  /// In en, this message translates to:
  /// **'1 book is overdue'**
  String get overdueBannerOne;

  /// No description provided for @overdueBannerMany.
  ///
  /// In en, this message translates to:
  /// **'{count} books are overdue'**
  String overdueBannerMany(int count);

  /// No description provided for @devTestReminder.
  ///
  /// In en, this message translates to:
  /// **'Schedule test reminder (2 min)'**
  String get devTestReminder;

  /// No description provided for @devTestReminderSet.
  ///
  /// In en, this message translates to:
  /// **'Test reminder set for 2 minutes from now'**
  String get devTestReminderSet;

  /// No description provided for @detailRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get detailRemind;

  /// No description provided for @loansTitle.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loansTitle;

  /// No description provided for @loansTabLent.
  ///
  /// In en, this message translates to:
  /// **'Lent out'**
  String get loansTabLent;

  /// No description provided for @loansTabBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get loansTabBorrowed;

  /// No description provided for @loansTabOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get loansTabOverdue;

  /// No description provided for @loansTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get loansTabHistory;

  /// No description provided for @loansEmptyLent.
  ///
  /// In en, this message translates to:
  /// **'Everyone has returned your books. Nice.'**
  String get loansEmptyLent;

  /// No description provided for @loansEmptyBorrowed.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t borrowed any books right now.'**
  String get loansEmptyBorrowed;

  /// No description provided for @loansEmptyOverdue.
  ///
  /// In en, this message translates to:
  /// **'Nothing is overdue. Lovely.'**
  String get loansEmptyOverdue;

  /// No description provided for @loansEmptyHistory.
  ///
  /// In en, this message translates to:
  /// **'Returned books will show up here.'**
  String get loansEmptyHistory;

  /// No description provided for @loanSince.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String loanSince(String date);

  /// No description provided for @loanDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String loanDueOn(String date);

  /// No description provided for @loanDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get loanDueToday;

  /// No description provided for @loanDueInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Due tomorrow} other{Due in {count} days}}'**
  String loanDueInDays(int count);

  /// No description provided for @loanOverdueDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day overdue} other{{count} days overdue}}'**
  String loanOverdueDays(int count);

  /// No description provided for @loanNoDue.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get loanNoDue;

  /// No description provided for @loanReturnedOn.
  ///
  /// In en, this message translates to:
  /// **'Returned {date}'**
  String loanReturnedOn(String date);

  /// No description provided for @loanActionReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get loanActionReturn;

  /// No description provided for @loanActionExtend.
  ///
  /// In en, this message translates to:
  /// **'Extend'**
  String get loanActionExtend;

  /// No description provided for @loanReturnedToast.
  ///
  /// In en, this message translates to:
  /// **'Marked as returned'**
  String get loanReturnedToast;

  /// No description provided for @extendTitle.
  ///
  /// In en, this message translates to:
  /// **'Extend the due date'**
  String get extendTitle;

  /// No description provided for @extend1w.
  ///
  /// In en, this message translates to:
  /// **'+1 week'**
  String get extend1w;

  /// No description provided for @extend2w.
  ///
  /// In en, this message translates to:
  /// **'+2 weeks'**
  String get extend2w;

  /// No description provided for @extend1m.
  ///
  /// In en, this message translates to:
  /// **'+1 month'**
  String get extend1m;

  /// No description provided for @extendDone.
  ///
  /// In en, this message translates to:
  /// **'Now due {date}'**
  String extendDone(String date);

  /// No description provided for @loansOpenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loansOpenTooltip;
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

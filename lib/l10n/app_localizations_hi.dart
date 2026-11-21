// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

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
      'Add your first book and start building your shelf.';

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

  @override
  String libraryBooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '$count book',
    );
    return '$_temp0';
  }

  @override
  String libraryLentOutCount(int count) {
    return '$count lent out';
  }

  @override
  String get librarySearchHint => 'Search title or author';

  @override
  String get libraryScanTooltip => 'Scan a barcode';

  @override
  String get filterAll => 'All';

  @override
  String get filterWishlist => 'Wishlist';

  @override
  String get filterLentOut => 'Lent out';

  @override
  String get filterBorrowed => 'Borrowed';

  @override
  String get filterLocation => 'Location';

  @override
  String get filterTag => 'Tag';

  @override
  String get filterAnyLocation => 'Any location';

  @override
  String get filterAnyTag => 'Any tag';

  @override
  String get filterNoTags => 'No tags yet';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortRecentlyAdded => 'Recently added';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortAuthor => 'Author';

  @override
  String get sortRecentlyRead => 'Recently read';

  @override
  String get sortRating => 'Rating';

  @override
  String get viewAsGrid => 'Show as grid';

  @override
  String get viewAsList => 'Show as list';

  @override
  String get addBook => 'Add book';

  @override
  String get libraryEmptyTitle => 'Your shelf is empty';

  @override
  String get libraryAddFirst => 'Add your first book';

  @override
  String get libraryScanBarcode => 'Scan a barcode';

  @override
  String libraryNoResultsQuery(String query) {
    return 'Nothing matches “$query”';
  }

  @override
  String get libraryNoResultsFilters => 'Nothing matches these filters';

  @override
  String get libraryClearFilters => 'Clear filters';

  @override
  String get lentRibbon => 'Lent';

  @override
  String get quickChangeStatus => 'Change status';

  @override
  String get quickMove => 'Move to a location';

  @override
  String get quickDelete => 'Delete';

  @override
  String bookDeleted(String title) {
    return '“$title” deleted';
  }

  @override
  String get undo => 'Undo';

  @override
  String bookMoved(String title) {
    return 'Moved “$title”';
  }

  @override
  String bookStatusChanged(String title, String status) {
    return 'Marked “$title” $status';
  }

  @override
  String get seedDemoData => 'Add 300 demo books';

  @override
  String seedDemoDone(int count) {
    return '$count demo books added';
  }

  @override
  String get libraryLoadFailed => 'Couldn\'t load your books';

  @override
  String get locationsTitle => 'Locations';

  @override
  String locationsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '1 book',
      zero: 'No books',
    );
    return '$_temp0';
  }

  @override
  String get locationAdd => 'Add location';

  @override
  String get locationRename => 'Rename location';

  @override
  String get locationNameLabel => 'Name';

  @override
  String get locationNameExists =>
      'You already have a location with that name.';

  @override
  String get locationNameEmpty => 'Give the location a name.';

  @override
  String get locationIconLabel => 'Icon';

  @override
  String get locationIconShelf => 'Shelf';

  @override
  String get locationIconBox => 'Box';

  @override
  String get locationIconRoom => 'Room';

  @override
  String get locationIconBag => 'Bag';

  @override
  String get locationIconOffice => 'Office';

  @override
  String get locationIconOther => 'Other';

  @override
  String get locationParentLabel => 'Inside (optional)';

  @override
  String get locationNoParent => 'Nothing — top level';

  @override
  String get locationEdit => 'Rename or change icon';

  @override
  String get locationDelete => 'Delete location';

  @override
  String locationDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get locationDeleteEmpty => 'No books are in this location.';

  @override
  String locationMoveBooksTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count books to…',
      one: 'Move 1 book to…',
    );
    return '$_temp0';
  }

  @override
  String get locationDeleteConfirm => 'Delete and move';

  @override
  String get locationDeleted => 'Location deleted';

  @override
  String get locationsEmptyTitle => 'Where do your books live?';

  @override
  String get locationsEmptyBody =>
      'Add shelves, boxes or rooms so you can find any book fast.';

  @override
  String get locationsStarterTitle => 'Start with these?';

  @override
  String get locationsStarterAccept => 'Add all three';

  @override
  String get locationsStarterSkip => 'Skip';

  @override
  String get starterLivingRoom => 'Living room shelf';

  @override
  String get starterBedroom => 'Bedroom shelf';

  @override
  String get starterStorage => 'Storage box';

  @override
  String get locationReorderHint => 'Drag to reorder';

  @override
  String get locationPickerTitle => 'Choose a location';

  @override
  String get locationPickerSearch => 'Search or create';

  @override
  String get locationPickerRecent => 'Recent';

  @override
  String get locationPickerAll => 'All locations';

  @override
  String locationCreateNew(String name) {
    return 'Create \"$name\"';
  }

  @override
  String get locationCreateNewPlain => 'Create new location';

  @override
  String get locationsManage => 'Manage locations';

  @override
  String get bookNotFound => 'This book is no longer in your library.';

  @override
  String detailPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String detailPercentRead(int percent) {
    return '$percent% read';
  }

  @override
  String get detailUpdatePage => 'Update page';

  @override
  String get detailUpdatePageTitle => 'Where are you now?';

  @override
  String get detailPageLabel => 'Page';

  @override
  String get detailPercentLabel => 'Percent read';

  @override
  String get detailPageDecrease => 'Previous page';

  @override
  String get detailPageIncrease => 'Next page';

  @override
  String detailPageAddPages(int count) {
    return 'Add $count pages';
  }

  @override
  String get readingGreetingMorning => 'Good morning';

  @override
  String get readingGreetingAfternoon => 'Good afternoon';

  @override
  String get readingGreetingEvening => 'Good evening';

  @override
  String readingStreakDays(int count) {
    return '$count-day streak';
  }

  @override
  String readingStreakLongest(int count) {
    return 'Longest: $count';
  }

  @override
  String get readingCurrentlyReading => 'Currently reading';

  @override
  String readingPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get readingToday => 'Today';

  @override
  String readingPagesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages today',
      one: '1 page today',
      zero: 'No pages yet today',
    );
    return '$_temp0';
  }

  @override
  String readingLast7Days(int count) {
    return 'Last 7 days: $count pages';
  }

  @override
  String readingOverdueTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books are out past their date',
      one: '1 book is out past its date',
    );
    return '$_temp0';
  }

  @override
  String get readingOverdueBody => 'See who has them';

  @override
  String get readingUpNext => 'Up next';

  @override
  String get readingPickNext => 'Pick your next read';

  @override
  String get readingPickNextBody =>
      'Choose something from your want-to-read shelf, or add a new book.';

  @override
  String get readingPickNextEmptyBody =>
      'Add a book you want to read and it will wait for you here.';

  @override
  String get readingAddBook => 'Add a book';

  @override
  String paceDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'About $count days left at your pace',
      one: 'About 1 day left at your pace',
    );
    return '$_temp0';
  }

  @override
  String paceFinishBy(String date) {
    return 'Finish by $date';
  }

  @override
  String get progressReachedEnd => 'That\'s the last page!';

  @override
  String get progressMarkFinished => 'Mark as finished';

  @override
  String detailPageInvalid(int max) {
    return 'Enter a number from 0 to $max';
  }

  @override
  String get detailRateIt => 'Rate it?';

  @override
  String detailRateStar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rate $count stars',
      one: 'Rate 1 star',
    );
    return '$_temp0';
  }

  @override
  String get detailFinishedCelebration => 'Finished! Nice one.';

  @override
  String get detailChange => 'Change';

  @override
  String detailLentTo(String name, String since) {
    return 'Lent to $name since $since';
  }

  @override
  String detailBorrowedFrom(String name, String since) {
    return 'Borrowed from $name since $since';
  }

  @override
  String detailDue(String date) {
    return 'due $date';
  }

  @override
  String get detailReturn => 'Return';

  @override
  String get detailReturned => 'Marked as returned';

  @override
  String get detailEdit => 'Edit';

  @override
  String get detailShare => 'Share';

  @override
  String get detailMore => 'More';

  @override
  String detailShareText(String title, String authors) {
    return '$title by $authors';
  }

  @override
  String detailShareTextNoAuthor(String title) {
    return '$title';
  }

  @override
  String get detailDeleteTitle => 'Delete this book?';

  @override
  String get detailDeleteBody =>
      'It leaves your library. You can undo right after.';

  @override
  String get detailSectionNotes => 'Notes';

  @override
  String get detailNotesHint => 'Add a note';

  @override
  String get detailNotesSaved => 'Note saved';

  @override
  String get detailSectionTags => 'Tags';

  @override
  String get detailAddTag => 'Add tag';

  @override
  String get detailTagHint => 'Tag name';

  @override
  String detailRemoveTag(String name) {
    return 'Remove tag $name';
  }

  @override
  String get detailSectionDetails => 'Details';

  @override
  String get detailIsbn => 'ISBN';

  @override
  String get detailOwner => 'Owner';

  @override
  String get detailAddedOn => 'Added on';

  @override
  String get detailStarted => 'Started';

  @override
  String get detailFinished => 'Finished';

  @override
  String get detailBack => 'Back';

  @override
  String detailPagesYear(int pages) {
    return '$pages pages';
  }

  @override
  String get editBookTitle => 'Edit book';

  @override
  String get bookSavedChanges => 'Changes saved';

  @override
  String get detailMove => 'Move';

  @override
  String get scanSearchHint => 'Search by title';

  @override
  String get scanTypeIsbn => 'Type ISBN';

  @override
  String get scanTorch => 'Torch';

  @override
  String get scanSwitchCamera => 'Switch camera';

  @override
  String get scanPermTitle => 'Let Kitabkhana use the camera';

  @override
  String get scanPermBody =>
      'The camera only reads barcodes on this device. Nothing is recorded or uploaded.';

  @override
  String get scanPermAllow => 'Allow camera';

  @override
  String get scanDeniedTitle => 'The camera is off';

  @override
  String get scanDeniedBody =>
      'Without the camera you can still search by title or type the ISBN.';

  @override
  String get scanTryAgain => 'Try again';

  @override
  String get scanBlockedTitle => 'Camera access is blocked';

  @override
  String get scanBlockedBody =>
      'Turn it on in Settings to scan barcodes. You can still search by title meanwhile.';

  @override
  String get scanOpenSettings => 'Open settings';

  @override
  String get scanNoCameraNote =>
      'No camera here, so search by title or type the ISBN.';

  @override
  String get scanWebHttpsNote =>
      'Camera scanning on the web needs a secure (HTTPS) page.';

  @override
  String get scanChecking => 'Checking your library…';

  @override
  String get verdictOwned => 'You own this';

  @override
  String verdictOwnedWhere(String place) {
    return 'On $place';
  }

  @override
  String get verdictNoPlace => 'No location set';

  @override
  String get verdictOtherEdition => 'You own another edition';

  @override
  String get verdictWishlist => 'On your wishlist';

  @override
  String get verdictMarkBought => 'Mark as bought';

  @override
  String verdictLentTo(String name) {
    return 'Lent to $name';
  }

  @override
  String verdictSince(String date) {
    return 'Since $date';
  }

  @override
  String verdictBorrowedFrom(String name) {
    return 'Borrowed from $name';
  }

  @override
  String get verdictBorrowed => 'Borrowed';

  @override
  String get verdictDidYouMean => 'Did you mean…?';

  @override
  String get verdictNoneOfThese => 'None of these';

  @override
  String get verdictNotInLibrary => 'Not in your library';

  @override
  String get verdictAddWishlist => 'Add to wishlist';

  @override
  String get verdictBoughtIt => 'I bought it — add to library';

  @override
  String get verdictOpenBook => 'Open book';

  @override
  String get verdictScanAnother => 'Scan another';

  @override
  String get verdictWishlistAdded => 'Added to your wishlist';

  @override
  String get verdictBoughtDone => 'Marked as bought';

  @override
  String verdictMatch(int percent) {
    return '$percent% match';
  }

  @override
  String get verdictUnknownTitle => 'Unknown title';

  @override
  String get scanSearchLabel => 'No barcode?';

  @override
  String get lendAction => 'Lend';

  @override
  String get lendSheetTitleLend => 'Lend this book';

  @override
  String get lendSheetTitleBorrow => 'Borrowed this book';

  @override
  String get lendToggleLend => 'Lend';

  @override
  String get lendToggleBorrow => 'Borrow';

  @override
  String get lendPersonLent => 'Lent to';

  @override
  String get lendPersonBorrowed => 'Borrowed from';

  @override
  String get lendPhone => 'Phone (optional)';

  @override
  String get lendPhoneHint => 'Number, with country code if different';

  @override
  String get lendPhoneInvalid => 'That doesn\'t look like a phone number.';

  @override
  String get lendStarted => 'Started';

  @override
  String get lendDue => 'Due';

  @override
  String get lendDueNone => 'No due date';

  @override
  String get lendDue1w => '1 week';

  @override
  String get lendDue2w => '2 weeks';

  @override
  String get lendDue1m => '1 month';

  @override
  String get lendDueCustom => 'Pick a date';

  @override
  String get lendNote => 'Note (optional)';

  @override
  String get lendSave => 'Save';

  @override
  String get lendNameRequired => 'Who has it?';

  @override
  String lendSaved(String name) {
    return 'Lent to $name';
  }

  @override
  String lendSavedBorrow(String name) {
    return 'Borrowed from $name';
  }

  @override
  String get returnPickLocationTitle => 'Where does it go back?';

  @override
  String get returnPickLocationBody =>
      'Its old spot was deleted. Choose a new one.';

  @override
  String returnBorrowedTitle(String name) {
    return 'Returned to $name';
  }

  @override
  String get returnBorrowedRemove => 'Remove from my library';

  @override
  String get returnBorrowedKeep => 'Keep it on my wishlist';

  @override
  String get failureNeedsName => 'Add the person\'s name.';

  @override
  String get reminderChannelName => 'Loan reminders';

  @override
  String get reminderChannelDesc =>
      'Reminders when a lent or borrowed book is due';

  @override
  String reminderDueTitle(String book) {
    return '“$book” is due today';
  }

  @override
  String reminderLentDueBody(String name) {
    return '$name has it. A friendly nudge?';
  }

  @override
  String reminderBorrowedDueBody(String name) {
    return 'Time to return it to $name.';
  }

  @override
  String reminderOverdueTitle(String book) {
    return '“$book” is overdue';
  }

  @override
  String reminderLentOverdueBody(String name) {
    return '$name still has it. Send a reminder?';
  }

  @override
  String reminderBorrowedOverdueBody(String name) {
    return 'Return it to $name soon.';
  }

  @override
  String get reminderPermTitle => 'Get a nudge when it\'s due?';

  @override
  String get reminderPermBody =>
      'Kitabkhana can remind you on the day a book is due. Reminders stay on this device.';

  @override
  String get reminderPermAllow => 'Allow notifications';

  @override
  String get reminderPermLater => 'Not now';

  @override
  String nudgeMessage(String name, String book) {
    return 'Hi $name! 📚 Could you return “$book” when you\'re done? Thanks!';
  }

  @override
  String get nudgeWhatsApp => 'Remind on WhatsApp';

  @override
  String get nudgeSms => 'Send SMS';

  @override
  String get nudgeNoPhone => 'Add a phone number to send a reminder.';

  @override
  String get nudgeFailed => 'Couldn\'t open a messaging app.';

  @override
  String get overdueBannerOne => '1 book is overdue';

  @override
  String overdueBannerMany(int count) {
    return '$count books are overdue';
  }

  @override
  String get devTestReminder => 'Schedule test reminder (2 min)';

  @override
  String get devTestReminderSet => 'Test reminder set for 2 minutes from now';

  @override
  String get detailRemind => 'Remind';

  @override
  String get loansTitle => 'Loans';

  @override
  String get loansTabLent => 'Lent out';

  @override
  String get loansTabBorrowed => 'Borrowed';

  @override
  String get loansTabOverdue => 'Overdue';

  @override
  String get loansTabHistory => 'History';

  @override
  String get loansEmptyLent => 'Everyone has returned your books. Nice.';

  @override
  String get loansEmptyBorrowed => 'You haven\'t borrowed any books right now.';

  @override
  String get loansEmptyOverdue => 'Nothing is overdue. Lovely.';

  @override
  String get loansEmptyHistory => 'Returned books will show up here.';

  @override
  String loanSince(String date) {
    return 'Since $date';
  }

  @override
  String loanDueOn(String date) {
    return 'Due $date';
  }

  @override
  String get loanDueToday => 'Due today';

  @override
  String loanDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Due in $count days',
      one: 'Due tomorrow',
    );
    return '$_temp0';
  }

  @override
  String loanOverdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String get loanNoDue => 'No due date';

  @override
  String loanReturnedOn(String date) {
    return 'Returned $date';
  }

  @override
  String get loanActionReturn => 'Return';

  @override
  String get loanActionExtend => 'Extend';

  @override
  String get loanReturnedToast => 'Marked as returned';

  @override
  String get extendTitle => 'Extend the due date';

  @override
  String get extend1w => '+1 week';

  @override
  String get extend2w => '+2 weeks';

  @override
  String get extend1m => '+1 month';

  @override
  String extendDone(String date) {
    return 'Now due $date';
  }

  @override
  String get loansOpenTooltip => 'Loans';
}

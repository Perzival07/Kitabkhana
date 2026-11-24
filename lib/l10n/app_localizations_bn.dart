// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String coverSemantics(String title, String author) {
    return '$title-এর প্রচ্ছদ, লেখক $author';
  }

  @override
  String coverSemanticsNoAuthor(String title) {
    return '$title-এর প্রচ্ছদ';
  }

  @override
  String get statusWant => 'পড়তে চাই';

  @override
  String get statusReading => 'পড়ছি';

  @override
  String get statusFinished => 'পড়া শেষ';

  @override
  String get statusDropped => 'ছেড়ে দিয়েছি';

  @override
  String get seeAll => 'সব দেখুন';

  @override
  String get loading => 'লোড হচ্ছে';

  @override
  String percentSemantics(int percent) {
    return '$percent শতাংশ';
  }

  @override
  String get appName => 'Kitabkhana';

  @override
  String get navLibrary => 'লাইব্রেরি';

  @override
  String get navScan => 'স্ক্যান';

  @override
  String get navReading => 'পড়া';

  @override
  String get navStats => 'পরিসংখ্যান';

  @override
  String get navMore => 'আরও';

  @override
  String get libraryTitle => 'আপনার লাইব্রেরি';

  @override
  String get libraryEmptyBody =>
      'প্রথম বইটি যোগ করুন, আর নিজের তাক সাজানো শুরু করুন।';

  @override
  String get scanTitle => 'একই বই দু\'বার কিনবেন না';

  @override
  String get scanEmptyBody =>
      'বারকোড স্ক্যান করে দেখুন বইটি আপনার কাছে আগে থেকেই আছে কি না।';

  @override
  String get readingTitle => 'এখন পড়ছি';

  @override
  String get readingEmptyBody =>
      'আপনার অগ্রগতি, টানা পড়ার দিন আর গতি এখানে দেখা যাবে।';

  @override
  String get statsTitle => 'আপনার পড়ার বছর';

  @override
  String get statsEmptyBody =>
      'কিছু পড়া লিখে রাখলেই লক্ষ্য আর চার্ট এখানে দেখা যাবে।';

  @override
  String get moreTitle => 'আরও';

  @override
  String get moreEmptyBody => 'ধার, উদ্ধৃতি, জায়গা আর সেটিংস এখানে।';

  @override
  String get routeAddBook => 'বই যোগ করুন';

  @override
  String get routeBook => 'বই';

  @override
  String get routeEditBook => 'বই সম্পাদনা';

  @override
  String get routeLoans => 'ধার';

  @override
  String get routeQuotes => 'উদ্ধৃতি';

  @override
  String get routeLocations => 'জায়গা';

  @override
  String get routeSettings => 'সেটিংস';

  @override
  String get routeOnboarding => 'স্বাগতম';

  @override
  String get routeStubBody => 'এই স্ক্রিনটি শিগগিরই আসছে।';

  @override
  String get notFoundTitle => 'পাতাটি খুঁজে পাওয়া গেল না';

  @override
  String get notFoundBody => 'লিংকটি পুরোনো বা ভুল লেখা হতে পারে।';

  @override
  String get goToLibrary => 'লাইব্রেরিতে যান';

  @override
  String get detailPlaceholderTitle => 'একটি বই বাছুন';

  @override
  String get detailPlaceholderBody =>
      'বাঁ দিক থেকে একটি বই বাছুন, তার বিবরণ এখানে দেখা যাবে।';

  @override
  String get failureOffline =>
      'মনে হচ্ছে আপনি অফলাইন। বাকি সব কিছু ঠিকমতোই চলবে।';

  @override
  String get failureTimeout => 'অনেক সময় লেগে গেল। আবার চেষ্টা করুন।';

  @override
  String get failureServer =>
      'বইয়ের পরিষেবায় সমস্যা হচ্ছে। একটু পরে আবার চেষ্টা করুন।';

  @override
  String get failureRateLimited =>
      'একসঙ্গে অনেক খোঁজ হয়ে গেছে। একটু অপেক্ষা করুন।';

  @override
  String get failureNotFound => 'এটি খুঁজে পাওয়া গেল না।';

  @override
  String get failureValidation => 'যা লিখেছেন তা একবার দেখে নিন।';

  @override
  String get failureConflict => 'আগে থেকে সংরক্ষিত কিছুর সঙ্গে এটি মিলছে না।';

  @override
  String get failureBookAlreadyLent => 'এই বইটি আগেই ধার দেওয়া আছে।';

  @override
  String get failureStorage => 'এই ডিভাইসে এটি সংরক্ষণ করা গেল না।';

  @override
  String get failurePermissionCamera =>
      'বারকোড স্ক্যান করতে ক্যামেরার অনুমতি দরকার।';

  @override
  String get failurePermissionNotifications =>
      'ধারের কথা মনে করাতে নোটিফিকেশনের অনুমতি দরকার।';

  @override
  String get failurePermissionFiles => 'এর জন্য ফাইলে প্রবেশের অনুমতি দরকার।';

  @override
  String get failureUnsupported => 'এই ডিভাইসে এটি পাওয়া যায় না।';

  @override
  String get failureUnexpected => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get errorWidgetTitle => 'এখানে কিছু একটা ভুল হয়েছে';

  @override
  String get errorWidgetBody =>
      'ফিরে গিয়ে আবার চেষ্টা করুন। আপনার লাইব্রেরি নিরাপদ আছে।';

  @override
  String get addBookTitle => 'বই যোগ করুন';

  @override
  String get addScanTitle => 'বারকোড স্ক্যান';

  @override
  String get addScanBody => 'বইয়ের পেছনের মলাটে ক্যামেরা ধরুন';

  @override
  String get addIsbnTitle => 'ISBN লিখুন';

  @override
  String get addIsbnBody => '10 বা 13 অঙ্কের নম্বরটি দিন';

  @override
  String get addSearchTitle => 'নাম দিয়ে খুঁজুন';

  @override
  String get addSearchBody => 'Open Library-র ক্যাটালগে খুঁজুন';

  @override
  String get addManualTitle => 'নিজে লিখুন';

  @override
  String get addManualBody => 'বিবরণ নিজেই পূরণ করুন';

  @override
  String get scanHint => 'পেছনের মলাটের বারকোডে ক্যামেরা ধরুন';

  @override
  String get scanUnavailableTitle => 'এখানে ক্যামেরা দিয়ে স্ক্যান করা যাবে না';

  @override
  String get scanUnavailableBody => 'ISBN লিখেও বইটি যোগ করতে পারেন।';

  @override
  String get isbnFieldLabel => 'ISBN';

  @override
  String get isbnFieldHint => '978…';

  @override
  String get isbnInvalid => 'এটি সঠিক ISBN মনে হচ্ছে না। অঙ্কগুলো দেখে নিন।';

  @override
  String get isbnIncomplete => 'ISBN-এ 10 বা 13টি অঙ্ক থাকে।';

  @override
  String get isbnValid => 'সঠিক ISBN';

  @override
  String get lookUp => 'খুঁজুন';

  @override
  String get pasteFromClipboard => 'পেস্ট';

  @override
  String get lookingUp => 'খোঁজা হচ্ছে…';

  @override
  String get lookupNotFound =>
      'এই ISBN পাওয়া গেল না। বিবরণ নিজেই পূরণ করতে পারেন।';

  @override
  String get searchFieldHint => 'নাম বা লেখক দিয়ে খুঁজুন';

  @override
  String get searchPrompt => 'ক্যাটালগে খুঁজতে বইয়ের নাম লিখুন।';

  @override
  String get searchNoResults =>
      'কিছু পাওয়া গেল না। অন্য শব্দ দিয়ে চেষ্টা করুন, বা বইটি নিজে লিখুন।';

  @override
  String get searchOffline =>
      'আপনি অফলাইন, তাই ক্যাটালগে খোঁজা যাবে না। বইটি নিজে লিখে যোগ করতে পারেন।';

  @override
  String get searchFailed =>
      'এবার খোঁজা গেল না। আবার চেষ্টা করুন বা বইটি নিজে লিখুন।';

  @override
  String get enterManually => 'নিজে লিখুন';

  @override
  String get fieldTitle => 'নাম';

  @override
  String get fieldSubtitle => 'উপশিরোনাম';

  @override
  String get fieldAuthors => 'লেখক';

  @override
  String get fieldPages => 'পৃষ্ঠা';

  @override
  String get fieldGenre => 'ধরন';

  @override
  String get fieldLanguage => 'ভাষা';

  @override
  String get fieldNotes => 'নোট';

  @override
  String get fieldOwnership => 'কার বই';

  @override
  String get fieldStatus => 'পড়ার অবস্থা';

  @override
  String get fieldLocation => 'জায়গা';

  @override
  String get noLocation => 'কোনো জায়গা নেই';

  @override
  String get ownershipOwned => 'নিজের';

  @override
  String get ownershipWishlist => 'ইচ্ছেতালিকা';

  @override
  String get ownershipBorrowed => 'ধার করা';

  @override
  String get titleRequired => 'বইয়ের নাম লিখুন';

  @override
  String get pagesInvalid => 'পৃষ্ঠার সংখ্যা 0-এর বেশি পূর্ণসংখ্যা হতে হবে';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get saveAndAddAnother => 'সংরক্ষণ করে আরেকটি যোগ করুন';

  @override
  String get coverSection => 'প্রচ্ছদ';

  @override
  String get coverTakePhoto => 'ছবি তুলুন';

  @override
  String get coverChoosePhoto => 'ছবি বাছুন';

  @override
  String get coverUseGenerated => 'তৈরি প্রচ্ছদ ব্যবহার করুন';

  @override
  String get coverPhotoFailed => 'এই ছবিটি ব্যবহার করা গেল না।';

  @override
  String get fromCatalogue =>
      'Open Library ক্যাটালগ থেকে। সংরক্ষণের আগে যা খুশি বদলাতে পারেন।';

  @override
  String get duplicateTitle => 'সম্ভবত এটি আপনার কাছে আছে';

  @override
  String duplicateBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'মনে হচ্ছে এই বইগুলো আপনার কাছে আগে থেকেই আছে।',
      one: 'মনে হচ্ছে এই বইটি আপনার কাছে আগে থেকেই আছে।',
    );
    return '$_temp0';
  }

  @override
  String get openExisting => 'আগেরটি খুলুন';

  @override
  String get addAnotherCopy => 'আরেকটি কপি যোগ করুন';

  @override
  String get cancel => 'বাতিল';

  @override
  String addedTo(String location) {
    return '$location-এ যোগ হল';
  }

  @override
  String get addedToLibrary => 'আপনার লাইব্রেরিতে যোগ হল';

  @override
  String get view => 'দেখুন';

  @override
  String get saveFailed => 'সংরক্ষণ করা গেল না। আবার চেষ্টা করুন।';

  @override
  String inLocation(String location) {
    return '$location-এ';
  }

  @override
  String yearAndPages(int year, int pages) {
    return '$year · $pages পৃষ্ঠা';
  }

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count পৃষ্ঠা',
      one: '$count পৃষ্ঠা',
    );
    return '$_temp0';
  }

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String libraryBooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই',
      one: '$countটি বই',
    );
    return '$_temp0';
  }

  @override
  String libraryLentOutCount(int count) {
    return '$countটি ধার দেওয়া';
  }

  @override
  String get librarySearchHint => 'নাম বা লেখক খুঁজুন';

  @override
  String get libraryScanTooltip => 'বারকোড স্ক্যান করুন';

  @override
  String get filterAll => 'সব';

  @override
  String get filterWishlist => 'ইচ্ছেতালিকা';

  @override
  String get filterLentOut => 'ধার দেওয়া';

  @override
  String get filterBorrowed => 'ধার করা';

  @override
  String get filterLocation => 'জায়গা';

  @override
  String get filterTag => 'ট্যাগ';

  @override
  String get filterAnyLocation => 'যেকোনো জায়গা';

  @override
  String get filterAnyTag => 'যেকোনো ট্যাগ';

  @override
  String get filterNoTags => 'এখনও কোনো ট্যাগ নেই';

  @override
  String get sortTooltip => 'সাজান';

  @override
  String get sortRecentlyAdded => 'সম্প্রতি যোগ করা';

  @override
  String get sortTitle => 'নাম';

  @override
  String get sortAuthor => 'লেখক';

  @override
  String get sortRecentlyRead => 'সম্প্রতি পড়া';

  @override
  String get sortRating => 'রেটিং';

  @override
  String get viewAsGrid => 'গ্রিডে দেখুন';

  @override
  String get viewAsList => 'তালিকায় দেখুন';

  @override
  String get addBook => 'বই যোগ করুন';

  @override
  String get libraryEmptyTitle => 'আপনার তাক খালি';

  @override
  String get libraryAddFirst => 'প্রথম বইটি যোগ করুন';

  @override
  String get libraryScanBarcode => 'বারকোড স্ক্যান করুন';

  @override
  String libraryNoResultsQuery(String query) {
    return '“$query”-এর সঙ্গে কিছু মিলল না';
  }

  @override
  String get libraryNoResultsFilters => 'এই ফিল্টারে কিছু মিলল না';

  @override
  String get libraryClearFilters => 'ফিল্টার সরান';

  @override
  String get lentRibbon => 'ধারে';

  @override
  String get quickChangeStatus => 'অবস্থা বদলান';

  @override
  String get quickMove => 'অন্য জায়গায় রাখুন';

  @override
  String get quickDelete => 'মুছুন';

  @override
  String bookDeleted(String title) {
    return '“$title” মুছে ফেলা হল';
  }

  @override
  String get undo => 'ফিরিয়ে আনুন';

  @override
  String bookMoved(String title) {
    return '“$title”-এর জায়গা বদলানো হল';
  }

  @override
  String bookStatusChanged(String title, String status) {
    return '“$title” এখন “$status”';
  }

  @override
  String get seedDemoData => '300টি নমুনা বই যোগ করুন';

  @override
  String seedDemoDone(int count) {
    return '$countটি নমুনা বই যোগ হল';
  }

  @override
  String get libraryLoadFailed => 'আপনার বইগুলো লোড করা গেল না';

  @override
  String get locationsTitle => 'জায়গা';

  @override
  String locationsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই',
      one: '1টি বই',
      zero: 'কোনো বই নেই',
    );
    return '$_temp0';
  }

  @override
  String get locationAdd => 'জায়গা যোগ করুন';

  @override
  String get locationRename => 'জায়গার নাম বদলান';

  @override
  String get locationNameLabel => 'নাম';

  @override
  String get locationNameExists => 'এই নামে একটি জায়গা আগে থেকেই আছে।';

  @override
  String get locationNameEmpty => 'জায়গাটির একটি নাম দিন।';

  @override
  String get locationIconLabel => 'আইকন';

  @override
  String get locationIconShelf => 'তাক';

  @override
  String get locationIconBox => 'বাক্স';

  @override
  String get locationIconRoom => 'ঘর';

  @override
  String get locationIconBag => 'ব্যাগ';

  @override
  String get locationIconOffice => 'অফিস';

  @override
  String get locationIconOther => 'অন্য';

  @override
  String get locationParentLabel => 'কোনটির ভেতরে (ঐচ্ছিক)';

  @override
  String get locationNoParent => 'কিছুর ভেতরে নয়';

  @override
  String get locationEdit => 'নাম বা আইকন বদলান';

  @override
  String get locationDelete => 'জায়গা মুছুন';

  @override
  String locationDeleteTitle(String name) {
    return '\"$name\" মুছবেন?';
  }

  @override
  String get locationDeleteEmpty => 'এই জায়গায় কোনো বই নেই।';

  @override
  String locationMoveBooksTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই কোথায় রাখবেন…',
      one: '1টি বই কোথায় রাখবেন…',
    );
    return '$_temp0';
  }

  @override
  String get locationDeleteConfirm => 'মুছে বইগুলো সরান';

  @override
  String get locationDeleted => 'জায়গা মুছে ফেলা হল';

  @override
  String get locationsEmptyTitle => 'আপনার বইগুলো কোথায় থাকে?';

  @override
  String get locationsEmptyBody =>
      'তাক, বাক্স বা ঘর যোগ করুন, যাতে যেকোনো বই চটপট খুঁজে পান।';

  @override
  String get locationsStarterTitle => 'এগুলো দিয়ে শুরু করবেন?';

  @override
  String get locationsStarterAccept => 'তিনটিই যোগ করুন';

  @override
  String get locationsStarterSkip => 'এড়িয়ে যান';

  @override
  String get starterLivingRoom => 'বসার ঘরের তাক';

  @override
  String get starterBedroom => 'শোবার ঘরের তাক';

  @override
  String get starterStorage => 'রাখার বাক্স';

  @override
  String get locationReorderHint => 'ক্রম বদলাতে টেনে আনুন';

  @override
  String get locationPickerTitle => 'জায়গা বাছুন';

  @override
  String get locationPickerSearch => 'খুঁজুন বা নতুন বানান';

  @override
  String get locationPickerRecent => 'সাম্প্রতিক';

  @override
  String get locationPickerAll => 'সব জায়গা';

  @override
  String locationCreateNew(String name) {
    return '\"$name\" বানান';
  }

  @override
  String get locationCreateNewPlain => 'নতুন জায়গা বানান';

  @override
  String get locationsManage => 'জায়গা সামলান';

  @override
  String get bookNotFound => 'এই বইটি আর আপনার লাইব্রেরিতে নেই।';

  @override
  String detailPageOf(int current, int total) {
    return 'পৃষ্ঠা $current / $total';
  }

  @override
  String detailPercentRead(int percent) {
    return '$percent% পড়া হয়েছে';
  }

  @override
  String get detailUpdatePage => 'পৃষ্ঠা আপডেট';

  @override
  String get detailUpdatePageTitle => 'এখন কোথায় আছেন?';

  @override
  String get detailPageLabel => 'পৃষ্ঠা';

  @override
  String get detailPercentLabel => 'কত শতাংশ পড়া';

  @override
  String get detailPageDecrease => 'আগের পৃষ্ঠা';

  @override
  String get detailPageIncrease => 'পরের পৃষ্ঠা';

  @override
  String detailPageAddPages(int count) {
    return '$count পৃষ্ঠা যোগ করুন';
  }

  @override
  String get readingGreetingMorning => 'সুপ্রভাত';

  @override
  String get readingGreetingAfternoon => 'শুভ দুপুর';

  @override
  String get readingGreetingEvening => 'শুভ সন্ধ্যা';

  @override
  String readingStreakDays(int count) {
    return 'টানা $count দিন';
  }

  @override
  String readingStreakLongest(int count) {
    return 'সবচেয়ে বেশি: $count';
  }

  @override
  String get readingCurrentlyReading => 'এখন পড়ছি';

  @override
  String readingPageOf(int current, int total) {
    return 'পৃষ্ঠা $current / $total';
  }

  @override
  String get readingToday => 'আজ';

  @override
  String readingPagesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আজ $count পৃষ্ঠা',
      one: 'আজ 1 পৃষ্ঠা',
      zero: 'আজ এখনও কোনো পৃষ্ঠা নয়',
    );
    return '$_temp0';
  }

  @override
  String readingLast7Days(int count) {
    return 'গত 7 দিন: $count পৃষ্ঠা';
  }

  @override
  String readingOverdueTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই ফেরতের তারিখ পেরিয়ে গেছে',
      one: '1টি বই ফেরতের তারিখ পেরিয়ে গেছে',
    );
    return '$_temp0';
  }

  @override
  String get readingOverdueBody => 'দেখুন কার কাছে আছে';

  @override
  String get readingUpNext => 'এরপর';

  @override
  String get readingPickNext => 'পরের বই বাছুন';

  @override
  String get readingPickNextBody =>
      '\'পড়তে চাই\' তালিকা থেকে কিছু বাছুন, বা নতুন বই যোগ করুন।';

  @override
  String get readingPickNextEmptyBody =>
      'যে বই পড়তে চান সেটি যোগ করুন, এখানে আপনার জন্য অপেক্ষা করবে।';

  @override
  String get readingAddBook => 'বই যোগ করুন';

  @override
  String get statsYearPrevious => 'আগের বছর';

  @override
  String get statsYearNext => 'পরের বছর';

  @override
  String get statsGoalTitle => 'পড়ার লক্ষ্য';

  @override
  String statsGoalOf(int finished, int target) {
    return '$targetটির মধ্যে $finishedটি বই';
  }

  @override
  String get statsGoalReached => 'লক্ষ্য পূরণ। দারুণ পড়েছেন!';

  @override
  String statsGoalAhead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'গতির চেয়ে $countটি বই এগিয়ে',
      one: 'গতির চেয়ে 1টি বই এগিয়ে',
    );
    return '$_temp0';
  }

  @override
  String statsGoalBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'গতির চেয়ে $countটি বই পিছিয়ে',
      one: 'গতির চেয়ে 1টি বই পিছিয়ে',
    );
    return '$_temp0';
  }

  @override
  String get statsGoalOnPace => 'ঠিক গতিতে চলছেন';

  @override
  String statsGoalMissed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই কম হল',
      one: '1টি বই কম হল',
    );
    return '$_temp0';
  }

  @override
  String get statsGoalUpcoming => 'সামনে নতুন বছর';

  @override
  String get statsGoalSetTitle => 'পড়ার লক্ষ্য ঠিক করুন';

  @override
  String statsGoalSetBody(int year) {
    return '$year-এ কতগুলো বই শেষ করতে চান, বেছে নিন।';
  }

  @override
  String get statsGoalCta => 'লক্ষ্য ঠিক করুন';

  @override
  String get statsGoalEdit => 'লক্ষ্য বদলান';

  @override
  String statsGoalSheetTitle(int year) {
    return '$year-এ যতগুলো বই শেষ করবেন';
  }

  @override
  String get statsGoalFewer => 'কম বই';

  @override
  String get statsGoalMore => 'বেশি বই';

  @override
  String get statsGoalRemove => 'লক্ষ্য সরান';

  @override
  String get statsGoalInvalid => '1 থেকে 999-এর মধ্যে একটি সংখ্যা দিন';

  @override
  String get statsMonthlyTitle => 'মাসে শেষ করা বই';

  @override
  String get statsMonthlyEmpty =>
      'একটি বই শেষ করুন, তার মাসটি এখানে জ্বলে উঠবে।';

  @override
  String statsMonthBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই',
      one: '1টি বই',
    );
    return '$_temp0';
  }

  @override
  String statsMonthSheetTitle(String month) {
    return '$month-এ শেষ করা';
  }

  @override
  String get statsWeeklyTitle => 'সপ্তাহে পৃষ্ঠা';

  @override
  String get statsWeeklyEmpty =>
      'পড়তে পড়তে পৃষ্ঠা আপডেট করুন, আপনার সপ্তাহগুলো এখানে দেখা যাবে।';

  @override
  String statsWeeklyTotal(int count) {
    return '12 সপ্তাহে $count পৃষ্ঠা';
  }

  @override
  String get statsGenresTitle => 'সেরা ধরন';

  @override
  String get statsAuthorsTitle => 'সেরা লেখক';

  @override
  String get statsTopEmpty => 'এই বছরের জন্য এখনও কিছু নেই।';

  @override
  String get statsFactsTitle => 'আপনার লাইব্রেরি';

  @override
  String get statsFactTotal => 'বই';

  @override
  String get statsFactOwned => 'নিজের';

  @override
  String get statsFactWishlist => 'ইচ্ছেতালিকা';

  @override
  String get statsFactLent => 'ধার দেওয়া';

  @override
  String get statsFactRating => 'গড় রেটিং';

  @override
  String get statsFactLongest => 'সবচেয়ে বড় বই';

  @override
  String statsFactPages(int count) {
    return '$count পৃষ্ঠা';
  }

  @override
  String get statsFactNone => 'এখনও নেই';

  @override
  String get statsEmptyAdd => 'বই যোগ করুন';

  @override
  String get statsEmptyTitle => 'আপনার পড়ার বছর এখান থেকে শুরু';

  @override
  String get quoteCaptureTitle => 'উদ্ধৃতি তুলুন';

  @override
  String get quoteSourceBody =>
      'একটি পৃষ্ঠার ছবি তুলে প্রিয় লাইনগুলো ছুঁয়ে দিন, বা নিজে লিখুন। শুধু লেখাটুকু রাখা হয়; ছবি কখনো সংরক্ষিত হয় না।';

  @override
  String get quoteTakePhoto => 'ছবি তুলুন';

  @override
  String get quoteChoosePhoto => 'ছবি বাছুন';

  @override
  String get quoteTypeIt => 'বরং লিখে দিন';

  @override
  String get quoteRotateLeft => 'বাঁ দিকে ঘোরান';

  @override
  String get quoteRotateRight => 'ডান দিকে ঘোরান';

  @override
  String get quoteReadText => 'লেখা পড়ুন';

  @override
  String get quoteReading => 'পৃষ্ঠা পড়া হচ্ছে…';

  @override
  String get quotePickLines => 'যে লাইনগুলো রাখতে চান সেগুলো ছুঁয়ে দিন।';

  @override
  String get quoteSelectAll => 'সব বাছুন';

  @override
  String get quoteUseSelected => 'বাছাই করা লাইন নিন';

  @override
  String get quoteNoText =>
      'কোনো লেখা পাওয়া গেল না। উদ্ধৃতিটি লিখে দিতে পারেন।';

  @override
  String get quoteReadFailed => 'ছবিটি পড়া গেল না। অন্য ছবি দিন, বা লিখে দিন।';

  @override
  String get quoteBodyLabel => 'উদ্ধৃতি';

  @override
  String get quotePageLabel => 'পৃষ্ঠা (ঐচ্ছিক)';

  @override
  String get quotePageInvalid => 'বইয়ের ভেতরের একটি পৃষ্ঠা দিন';

  @override
  String get quoteBodyRequired => 'আগে উদ্ধৃতিটি লিখুন';

  @override
  String get quotePickAgain => 'আবার লাইন বাছুন';

  @override
  String get quoteSave => 'উদ্ধৃতি সংরক্ষণ';

  @override
  String get quoteSaved => 'উদ্ধৃতি সংরক্ষিত হল';

  @override
  String get quotesSectionTitle => 'উদ্ধৃতি';

  @override
  String get quotesSectionEmpty => 'এই বইয়ের প্রিয় লাইনগুলো রেখে দিন।';

  @override
  String get quoteSnap => 'উদ্ধৃতি তুলুন';

  @override
  String quotePageShort(int page) {
    return 'পৃ. $page';
  }

  @override
  String get quotesTitle => 'উদ্ধৃতি';

  @override
  String get quotesSearchHint => 'আপনার উদ্ধৃতি খুঁজুন';

  @override
  String get quotesFavourites => 'প্রিয়';

  @override
  String get quotesAllBooks => 'সব বই';

  @override
  String get quotesPickBook => 'এটি কোন বই থেকে?';

  @override
  String get quotesBookFilterTitle => 'যে বইয়ের উদ্ধৃতি দেখাবেন';

  @override
  String get quotesEmptyTitle => 'এখনও কোনো উদ্ধৃতি নেই';

  @override
  String get quotesEmptyBody =>
      'পৃষ্ঠার ছবি তুলুন বা একটি লাইন লিখুন, প্রিয় অংশগুলো এখানে থাকবে।';

  @override
  String get quotesNoMatch => 'কোনো উদ্ধৃতি মিলল না।';

  @override
  String get quotesNoBooksYet =>
      'আগে একটি বই যোগ করুন, তারপর তার উদ্ধৃতি রাখুন।';

  @override
  String quoteAttribution(String title) {
    return '$title';
  }

  @override
  String quoteAttributionPage(String title, int page) {
    return '$title, পৃ. $page';
  }

  @override
  String get quoteFavourite => 'প্রিয় করুন';

  @override
  String get quoteUnfavourite => 'প্রিয় থেকে সরান';

  @override
  String get quoteEdit => 'সম্পাদনা';

  @override
  String get quoteEditTitle => 'উদ্ধৃতি সম্পাদনা';

  @override
  String get quoteShareImage => 'ছবি হিসেবে পাঠান';

  @override
  String get quoteShareText => 'লেখা হিসেবে পাঠান';

  @override
  String get quoteDelete => 'মুছুন';

  @override
  String get quoteDeleted => 'উদ্ধৃতি মুছে ফেলা হল';

  @override
  String quoteShareTextBody(String body, String attribution) {
    return '“$body”\n— $attribution';
  }

  @override
  String get quoteMore => 'আরও';

  @override
  String get quoteOfWeekTitle => 'সপ্তাহের উদ্ধৃতি';

  @override
  String get failureBackupNotABackup => 'এটি Kitabkhana-র ব্যাকআপ নয়।';

  @override
  String get failureBackupDamaged =>
      'ব্যাকআপটি নষ্ট মনে হচ্ছে, তাই কিছুই বদলানো হয়নি।';

  @override
  String get failureBackupNewer =>
      'এই ব্যাকআপ নতুন সংস্করণে তৈরি। আগে অ্যাপটি আপডেট করুন।';

  @override
  String get backupExportTitle => 'লাইব্রেরির ব্যাকআপ নিন';

  @override
  String get backupExportWarning =>
      'ব্যাকআপ ফাইলে আপনার পুরো লাইব্রেরি থাকে, যাঁদের বই ধার দিয়েছেন তাঁদের নাম ও ফোন নম্বরও। এটি কোনো নিরাপদ জায়গায় রাখুন।';

  @override
  String get backupExportAction => 'ব্যাকআপ তৈরি করুন';

  @override
  String get backupPreparing => 'আপনার ব্যাকআপ তৈরি হচ্ছে…';

  @override
  String get backupOpening => 'ফাইলটি দেখা হচ্ছে…';

  @override
  String get backupRestoring => 'আপনার লাইব্রেরি ফিরিয়ে আনা হচ্ছে…';

  @override
  String get backupRestoreTitle => 'ব্যাকআপ থেকে ফিরিয়ে আনুন';

  @override
  String backupFound(String date, int books, int loans, int quotes) {
    String _temp0 = intl.Intl.pluralLogic(
      books,
      locale: localeName,
      other: '$booksটি বই',
      one: '1টি বই',
    );
    String _temp1 = intl.Intl.pluralLogic(
      loans,
      locale: localeName,
      other: '$loansটি ধার',
      one: '1টি ধার',
    );
    String _temp2 = intl.Intl.pluralLogic(
      quotes,
      locale: localeName,
      other: '$quotesটি উদ্ধৃতি',
      one: '1টি উদ্ধৃতি',
    );
    return '$date-এ তৈরি: $_temp0, $_temp1, $_temp2।';
  }

  @override
  String get backupModeMerge => 'আমার লাইব্রেরির সঙ্গে মেলান';

  @override
  String get backupModeMergeBody =>
      'যা নেই তা যোগ করুন, আর যা দুটোতেই আছে তার নতুনটি রাখুন।';

  @override
  String get backupModeReplace => 'আমার লাইব্রেরি বদলে দিন';

  @override
  String get backupModeReplaceBody =>
      'এই লাইব্রেরি মুছে ব্যাকআপটি ব্যবহার করুন।';

  @override
  String get backupReplaceConfirmTitle => 'লাইব্রেরি বদলে দেবেন?';

  @override
  String get backupReplaceConfirmBody =>
      'এখানকার সব কিছু ব্যাকআপ দিয়ে বদলে যাবে। আগে বর্তমান লাইব্রেরির একটি নিরাপত্তা-কপি রাখা হবে।';

  @override
  String get backupReplaceConfirm => 'বদলে দিন';

  @override
  String get backupDoneTitle => 'ব্যাকআপ ফিরে এসেছে';

  @override
  String backupImported(int books, int loans, int quotes) {
    String _temp0 = intl.Intl.pluralLogic(
      books,
      locale: localeName,
      other: '$booksটি বই',
      one: '1টি বই',
    );
    String _temp1 = intl.Intl.pluralLogic(
      loans,
      locale: localeName,
      other: '$loansটি ধার',
      one: '1টি ধার',
    );
    String _temp2 = intl.Intl.pluralLogic(
      quotes,
      locale: localeName,
      other: '$quotesটি উদ্ধৃতি',
      one: '1টি উদ্ধৃতি',
    );
    return 'আনা হল: $_temp0, $_temp1, $_temp2।';
  }

  @override
  String backupCoversSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্রচ্ছদ কপি করা গেল না।',
      one: '1টি প্রচ্ছদ কপি করা গেল না।',
    );
    return '$_temp0';
  }

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get csvPreparing => 'আপনার স্প্রেডশিট তৈরি হচ্ছে…';

  @override
  String get csvExportTitle => 'স্প্রেডশিট হিসেবে রপ্তানি';

  @override
  String get csvExportWarning =>
      'books.csv আর loans.csv Excel, Numbers বা Google Sheets-এ খোলে। ধারের তালিকায় যাঁদের বই দিয়েছেন বা যাঁদের থেকে নিয়েছেন তাঁদের নাম ও ফোন নম্বর থাকে।';

  @override
  String get csvExportAction => 'রপ্তানি';

  @override
  String get eraseTitle => 'সব ডেটা মুছবেন?';

  @override
  String get eraseBody =>
      'এতে প্রতিটি বই, ধার, উদ্ধৃতি ও পড়ার রেকর্ড, আপনার প্রচ্ছদ, সেটিংস আর এই ডিভাইসে রাখা ব্যাকআপ চিরকালের মতো মুছে যাবে। এটি ফেরানো যাবে না। লাইব্রেরি আবার দরকার হতে পারলে আগে একটি ব্যাকআপ পাঠিয়ে রাখুন।';

  @override
  String get eraseContinue => 'এগিয়ে যান';

  @override
  String eraseTypeTitle(String word) {
    return 'নিশ্চিত করতে $word লিখুন';
  }

  @override
  String get eraseTypeHint => 'শব্দটি হুবহু, বড় হাতের অক্ষরে লিখুন।';

  @override
  String get eraseAction => 'সব মুছে দিন';

  @override
  String get eraseWorking => 'মোছা হচ্ছে…';

  @override
  String get eraseDone => 'সব ডেটা মুছে গেছে। নতুন করে শুরু।';

  @override
  String get readingReminderTitle => 'কয়েক পৃষ্ঠা পড়ার সময় হল?';

  @override
  String get readingReminderBody => 'টানা পড়ার ধারা বজায় রাখুন।';

  @override
  String get moreGroupLibrary => 'আপনার লাইব্রেরি';

  @override
  String get moreGroupApp => 'অ্যাপ';

  @override
  String get moreLoans => 'ধার';

  @override
  String get moreQuotes => 'উদ্ধৃতি';

  @override
  String get moreLocations => 'জায়গা';

  @override
  String get moreTags => 'ট্যাগ';

  @override
  String get moreSettings => 'সেটিংস';

  @override
  String get moreAbout => 'পরিচিতি';

  @override
  String moreCountOut(int count) {
    return '$countটি বাইরে';
  }

  @override
  String get tagsTitle => 'ট্যাগ';

  @override
  String get tagsEmptyTitle => 'এখনও কোনো ট্যাগ নেই';

  @override
  String get tagsEmptyBody =>
      'বইয়ের পাতা থেকে ট্যাগ যোগ করুন, সেগুলো এখানে দেখা যাবে।';

  @override
  String tagsBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই',
      one: '1টি বই',
      zero: 'কোনো বই নেই',
    );
    return '$_temp0';
  }

  @override
  String get tagsRename => 'নাম বদলান';

  @override
  String get tagsRenameTitle => 'ট্যাগের নাম বদলান';

  @override
  String get tagsNameLabel => 'ট্যাগের নাম';

  @override
  String get tagsNameTaken => 'এই নামে একটি ট্যাগ আগে থেকেই আছে।';

  @override
  String get tagsDelete => 'মুছুন';

  @override
  String get tagsDeleteTitle => 'ট্যাগটি মুছবেন?';

  @override
  String get tagsDeleteBody =>
      'এটি প্রতিটি বই থেকে সরে যাবে। বইগুলো থেকে যাবে।';

  @override
  String get tagsDeleted => 'ট্যাগ মুছে ফেলা হল';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsAppearance => 'চেহারা';

  @override
  String get settingsTheme => 'থিম';

  @override
  String get settingsThemeSystem => 'সিস্টেম';

  @override
  String get settingsThemeLight => 'হালকা';

  @override
  String get settingsThemeDark => 'গাঢ়';

  @override
  String get settingsDefaultView => 'লাইব্রেরি কীভাবে দেখাবে';

  @override
  String get settingsViewGrid => 'গ্রিড';

  @override
  String get settingsViewList => 'তালিকা';

  @override
  String get settingsDensity => 'গ্রিডের ঘনত্ব';

  @override
  String get settingsDensityComfortable => 'আরামদায়ক';

  @override
  String get settingsDensityCompact => 'ঘন';

  @override
  String get settingsReading => 'পড়া';

  @override
  String get settingsGoal => 'বার্ষিক লক্ষ্য';

  @override
  String settingsGoalValue(int count, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$year-এ $countটি বই',
      one: '$year-এ 1টি বই',
    );
    return '$_temp0';
  }

  @override
  String settingsGoalNone(int year) {
    return '$year-এর জন্য ঠিক করা নেই';
  }

  @override
  String get settingsReadingReminder => 'রোজ পড়ার কথা মনে করানো';

  @override
  String get settingsReadingReminderBody =>
      'আপনার বাছা সময়ে আলতো একটি খোঁচা। সেদিন পড়া হয়ে গেলে আর আসবে না।';

  @override
  String get settingsReminderTime => 'মনে করানোর সময়';

  @override
  String get settingsLending => 'ধার দেওয়া';

  @override
  String get settingsLoanLength => 'সাধারণত কত দিনের ধার';

  @override
  String get settingsLoanLengthNone => 'ফেরতের তারিখ নেই';

  @override
  String settingsLoanLengthDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিন',
      one: '1 দিন',
    );
    return '$_temp0';
  }

  @override
  String get settingsLoanLengthSheet => 'সাধারণত কত দিনের জন্য বই ধার দেন?';

  @override
  String get settingsLoanLengthHelp => '0 মানে ফেরতের তারিখ নেই।';

  @override
  String get settingsCountryCode => 'ডিফল্ট দেশের কোড';

  @override
  String settingsCountryCodeValue(String code) {
    return '+$code';
  }

  @override
  String get settingsCountryCodeSheet => 'ফোন নম্বরের দেশের কোড';

  @override
  String get settingsCountryCodeHelp =>
      'কোড ছাড়া নম্বর লেখা হলে এটি ব্যবহার হয়। শুধু অঙ্ক, যেমন 91।';

  @override
  String get settingsLoanReminderTime => 'ধারের কথা মনে করানোর সময়';

  @override
  String get settingsData => 'আপনার ডেটা';

  @override
  String get settingsBackupNow => 'এখনই ব্যাকআপ নিন';

  @override
  String settingsBackupLast(String when) {
    return 'শেষ ব্যাকআপ: $when';
  }

  @override
  String get settingsBackupNever => 'এখনও ব্যাকআপ নেওয়া হয়নি';

  @override
  String get settingsBackupToday => 'আজ';

  @override
  String get settingsBackupYesterday => 'গতকাল';

  @override
  String settingsBackupDaysAgo(int count) {
    return '$count দিন আগে';
  }

  @override
  String get settingsBackupSaved => 'ব্যাকআপ এই ডিভাইসে সংরক্ষিত হল।';

  @override
  String get settingsAutoBackup => 'প্রতি সপ্তাহে নিজে থেকে ব্যাকআপ';

  @override
  String get settingsAutoBackupBody => 'এই অ্যাপের স্টোরেজে শেষ 3টি কপি রাখে।';

  @override
  String get settingsShareBackup => 'ব্যাকআপ পাঠান';

  @override
  String get settingsRestore => 'ব্যাকআপ থেকে ফিরিয়ে আনুন';

  @override
  String get settingsExportCsv => 'স্প্রেডশিট (CSV) হিসেবে রপ্তানি';

  @override
  String get settingsErase => 'সব ডেটা মুছুন';

  @override
  String get settingsPrivacy => 'গোপনীয়তা';

  @override
  String get settingsPrivacyBody =>
      'আপনি নিজে ব্যাকআপ বা রপ্তানি না পাঠালে আপনার লাইব্রেরি এই ডিভাইস ছেড়ে কোথাও যায় না। কোনো অ্যাকাউন্ট নেই, কোনো ট্র্যাকিং নেই। বইয়ের বিবরণ ISBN বা নাম দিয়ে Open Library-তে খোঁজা হয় (সেখানে না পেলে Google Books-এ), আর প্রচ্ছদ সেখান থেকেই আসে; এর বাইরে কিছুই পাঠানো হয় না।';

  @override
  String get settingsCrashReports => 'সমস্যার রিপোর্ট পাঠানোর প্রস্তাব দিন';

  @override
  String get settingsCrashReportsBody =>
      'কিছু গোলমাল হলে Kitabkhana ডেভেলপারকে ইমেলে রিপোর্ট পাঠানোর প্রস্তাব দেয়। মেল অ্যাপে আপনি পাঠান না টিপলে কিছুই যায় না।';

  @override
  String get settingsSaveCopy => 'কপি রাখুন…';

  @override
  String get settingsSaveCopyBody =>
      'Google Drive, iCloud Drive, Downloads বা USB স্টিকে, যাতে ফোন হারালেও লাইব্রেরি থেকে যায়।';

  @override
  String settingsSaveCopyLast(String when) {
    return 'ফোনের বাইরে শেষ কপি: $when';
  }

  @override
  String get backupCopySaved => 'কপি রাখা হল';

  @override
  String get offDeviceTitle => 'আপনার লাইব্রেরি শুধু এই ফোনেই আছে';

  @override
  String get offDeviceBody =>
      'নিজে থেকে নেওয়া ব্যাকআপ ফোনেই থাকে, ফোন হারালে সেগুলোও হারাবে। Google Drive, iCloud Drive বা কম্পিউটারে একটি কপি রাখুন।';

  @override
  String get offDeviceSave => 'কপি রাখুন';

  @override
  String get offDeviceLater => 'পরে';

  @override
  String get settingsImportApp => 'Goodreads বা StoryGraph থেকে আনুন';

  @override
  String get settingsImportAppBody =>
      'যেকোনো অ্যাপের \"Export library\"-এর CSV ফাইলটি ব্যবহার করুন।';

  @override
  String get importNotAnExport =>
      'এটি Goodreads বা StoryGraph-এর রপ্তানি মনে হচ্ছে না।';

  @override
  String importTitle(String app) {
    return '$app থেকে আনুন';
  }

  @override
  String importFound(int count, int existing) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ফাইলে $countটি বই',
      one: 'ফাইলে 1টি বই',
    );
    return '$_temp0, $existingটি আগে থেকেই আপনার লাইব্রেরিতে।';
  }

  @override
  String importAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই যোগ করুন',
      one: '1টি বই যোগ করুন',
    );
    return '$_temp0';
  }

  @override
  String importWantQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countটি বই আপনার \'পড়তে চাই\' তালিকায় আছে। এগুলো কোথায় রাখবেন?',
      one: '1টি বই আপনার \'পড়তে চাই\' তালিকায় আছে। এটি কোথায় রাখবেন?',
    );
    return '$_temp0';
  }

  @override
  String get importWantWishlist => 'আমার ইচ্ছেতালিকায় (এগুলো আমার নেই)';

  @override
  String get importWantOwned => 'আমার তাকে (এগুলো আমার আছে)';

  @override
  String get importNothingNew => 'যোগ করার মতো নতুন কিছু নেই';

  @override
  String get importWorking => 'বই যোগ হচ্ছে…';

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই যোগ হল',
      one: '1টি বই যোগ হল',
      zero: 'নতুন কোনো বই যোগ হয়নি',
    );
    return '$_temp0';
  }

  @override
  String get batchTitle => 'পুরো তাক স্ক্যান করুন';

  @override
  String get batchBody =>
      'একের পর এক বারকোড স্ক্যান করুন, তারপর সব একসঙ্গে যোগ করুন';

  @override
  String get batchHint =>
      'প্রতিটি বইয়ের বারকোড স্ক্যান করুন; ক্যামেরা খোলা থাকবে';

  @override
  String get batchEmpty =>
      'স্ক্যান করা বই এখানে দেখা যাবে। যেগুলো চান না সেগুলোর টিক তুলে দিন।';

  @override
  String get batchOwned => 'আগে থেকেই আপনার লাইব্রেরিতে';

  @override
  String get batchNotFound => 'পাওয়া যায়নি; পরে নিজে যোগ করুন';

  @override
  String get batchFailed => 'খোঁজা গেল না; ইন্টারনেট সংযোগ দেখুন';

  @override
  String get batchRemove => 'সরান';

  @override
  String get batchPlace => 'কোথায় রাখবেন';

  @override
  String batchAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই যোগ করুন',
      one: '1টি বই যোগ করুন',
      zero: 'বই যোগ করুন',
    );
    return '$_temp0';
  }

  @override
  String batchAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই যোগ হল',
      one: '1টি বই যোগ হল',
      zero: 'কোনো বই যোগ হয়নি',
    );
    return '$_temp0';
  }

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get statsShareYear => 'আপনার বছরটি শেয়ার করুন';

  @override
  String yearReviewTitle(String year) {
    return 'বইয়ে আমার $year';
  }

  @override
  String yearReviewBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'বই শেষ করেছি',
      one: 'বই শেষ করেছি',
    );
    return '$_temp0';
  }

  @override
  String get yearReviewPages => 'পৃষ্ঠা পড়েছি';

  @override
  String get yearReviewStreak => 'সবচেয়ে লম্বা ধারা (দিন)';

  @override
  String get yearReviewGoal => 'পড়ার লক্ষ্য';

  @override
  String get yearReviewTopGenre => 'প্রিয় ধরন';

  @override
  String get yearReviewTopAuthor => 'সবচেয়ে বেশি পড়া লেখক';

  @override
  String get yearReviewLongest => 'সবচেয়ে বড় বই';

  @override
  String yearReviewLongestValue(String title, int pages) {
    return '$title · $pages পৃষ্ঠা';
  }

  @override
  String get yearReviewFooter => 'Kitabkhana দিয়ে তৈরি';

  @override
  String get yearReviewShare => 'শেয়ার';

  @override
  String get yearReviewEmpty =>
      'এ বছর একটি বই শেষ করুন বা কিছু পৃষ্ঠা লিখে রাখুন, আপনার বছরের হিসেব এখানে দেখা যাবে।';

  @override
  String get quoteScriptLabel => 'পৃষ্ঠাটি কোন লিপিতে';

  @override
  String get quoteScriptLatin => 'ইংরেজি ও অন্যান্য লাতিন লিপি';

  @override
  String get quoteScriptDevanagari => 'হিন্দি, মারাঠি (দেবনাগরী)';

  @override
  String get timerStart => 'পড়ার টাইমার চালু করুন';

  @override
  String timerStop(String time) {
    return 'টাইমার থামান ($time)';
  }

  @override
  String timerRunning(String time) {
    return '$time ধরে পড়ছেন';
  }

  @override
  String timerLogged(String time) {
    return '$time পড়া লেখা হল';
  }

  @override
  String get timerTooShort => 'এক মিনিটের কম, তাই কিছু লেখা হয়নি';

  @override
  String durationMinutes(int minutes) {
    return '$minutes মিনিট';
  }

  @override
  String durationHours(int hours) {
    return '$hours ঘণ্টা';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ঘণ্টা $minutes মিনিট';
  }

  @override
  String readingTimeToday(String time) {
    return 'টাইমারে $time';
  }

  @override
  String get statsTimeTitle => 'পড়ার সময়';

  @override
  String get statsTimeBody => 'পড়া ট্যাবের টাইমার দিয়ে মাপা।';

  @override
  String get statsTimeNone =>
      'যে বই পড়ছেন তাতে টাইমার চালান, পড়ার সময় এখানে দেখা যাবে।';

  @override
  String get rereadAction => 'আবার পড়ুন';

  @override
  String get rereadStarted => 'নতুন পড়া আজ থেকে শুরু। আগেরটি রাখা থাকল।';

  @override
  String rereadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count বার পড়া',
    );
    return '$_temp0';
  }

  @override
  String get rereadEarlier => 'আগের পড়া';

  @override
  String rereadRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String rereadFinishedOn(String date) {
    return '$date-এ শেষ';
  }

  @override
  String rereadStartedOn(String date) {
    return '$date-এ শুরু';
  }

  @override
  String get rereadUndated => 'আগে পড়া (তারিখ নেই)';

  @override
  String get fieldSeries => 'সিরিজ';

  @override
  String get fieldSeriesNumber => 'নং';

  @override
  String get fieldSeriesNumberInvalid => 'একটি সংখ্যা';

  @override
  String seriesPlace(String number, String series) {
    return '$series-এর $number নম্বর বই';
  }

  @override
  String seriesOnly(String series) {
    return '$series-এর অংশ';
  }

  @override
  String get seriesYouHave => 'আপনার লাইব্রেরিতে';

  @override
  String seriesMissing(String numbers) {
    return 'নেই: $numbers';
  }

  @override
  String get seriesComplete => 'এ পর্যন্ত সব বই আপনার আছে।';

  @override
  String get lendFromContacts => 'পরিচিতি থেকে বাছুন';

  @override
  String get widgetLabel => 'এখন পড়ছি';

  @override
  String get widgetNothing => 'এখন কিছু পড়ছি না';

  @override
  String widgetOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই ফেরতের তারিখ পেরিয়েছে',
      one: '1টি বই ফেরতের তারিখ পেরিয়েছে',
    );
    return '$_temp0';
  }

  @override
  String widgetLentOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই ধার দেওয়া',
      one: '1টি বই ধার দেওয়া',
    );
    return '$_temp0';
  }

  @override
  String widgetAlsoReading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আরও $countটি পড়া চলছে',
      one: 'আরও 1টি পড়া চলছে',
    );
    return '$_temp0';
  }

  @override
  String get settingsReportProblem => 'সমস্যা জানান';

  @override
  String get settingsReportProblemBody =>
      'ডেভেলপারকে ইমেল করুন, অ্যাপের সাম্প্রতিক বার্তাসহ।';

  @override
  String get crashPromptTitle => 'কিছু একটা ভুল হয়েছে';

  @override
  String get crashPromptBody =>
      'গতবার ব্যবহারের সময় Kitabkhana-য় একটি সমস্যা হয়েছিল। সারাতে সাহায্য করতে ডেভেলপারকে একটি রিপোর্ট ইমেল করতে পারেন। আগে আপনার মেল অ্যাপ খুলবে, যাতে পাঠানোর আগে সব দেখে নিতে পারেন।';

  @override
  String get crashPromptScreenshot => 'স্ক্রিনশট যোগ করুন';

  @override
  String get crashPromptScreenshotHint =>
      'এতে স্ক্রিনে থাকা বইয়ের নাম দেখা যেতে পারে।';

  @override
  String get crashPromptSend => 'রিপোর্ট ইমেল করুন';

  @override
  String get crashPromptDismiss => 'এখন নয়';

  @override
  String get reportSentMailLink =>
      'মেল অ্যাপ সংযুক্তি ছাড়াই খুলেছে; বিবরণ বার্তার মধ্যে আছে।';

  @override
  String get reportShared =>
      'কোনো মেল অ্যাপ পাওয়া যায়নি, তাই রিপোর্টটি অন্যভাবে পাঠানো হল।';

  @override
  String get settingsHelp => 'সাহায্য';

  @override
  String get settingsDiagnostics => 'ডায়াগনস্টিক রপ্তানি';

  @override
  String get settingsDiagnosticsBody =>
      'সংস্করণ আর অ্যাপের সাম্প্রতিক বার্তা, আপনার লাইব্রেরির কিছুই নয়।';

  @override
  String get settingsFeedback => 'মতামত পাঠান';

  @override
  String get settingsFeedbackSubject => 'Kitabkhana নিয়ে মতামত';

  @override
  String get settingsAbout => 'পরিচিতি';

  @override
  String get aboutTitle => 'পরিচিতি';

  @override
  String aboutVersion(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get aboutLicenses => 'ওপেন-সোর্স লাইসেন্স';

  @override
  String get aboutPrivacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get aboutTagline =>
      'আপনার নিজের, ধার দেওয়া আর প্রিয় বইয়ের একটি নিজস্ব ঘর।';

  @override
  String get aboutMadeWithCare => 'যত্ন করে তৈরি';

  @override
  String get onboardingSkip => 'এড়িয়ে যান';

  @override
  String get onboardingNext => 'পরের';

  @override
  String onboardingStep(int current, int total) {
    return 'ধাপ $current / $total';
  }

  @override
  String get onboarding1Title => 'জানুন কী কী আছে';

  @override
  String get onboarding1Body =>
      'প্রতিটি বই আর প্রতিটি তাক এক শান্ত জায়গায়, ধার দেওয়া বইগুলোও।';

  @override
  String get onboarding2Title => 'একই বই দু\'বার কিনবেন না';

  @override
  String get onboarding2Body =>
      'দোকানে বারকোড স্ক্যান করুন, Kitabkhana সঙ্গে সঙ্গে বলে দেবে বইটি আপনার তাকে আগে থেকেই আছে কি না।';

  @override
  String get onboarding3Title => 'আপনার বই আপনার কাছেই';

  @override
  String get onboarding3Body =>
      'কোনো অ্যাকাউন্ট নেই, সাইন-আপ নেই, ট্র্যাকিং নেই। লাইব্রেরি এই ডিভাইসেই থাকে, আর কখনো বাইরে যাবে কি না তা আপনিই ঠিক করেন।';

  @override
  String get onboardingPlacesTitle => 'আপনার বইগুলো কোথায় থাকে?';

  @override
  String get onboardingPlacesBody =>
      'শুরুর জন্য কয়েকটি জায়গা বাছুন। পরে নাম বদলাতে বা আরও যোগ করতে পারবেন।';

  @override
  String get onboardingPlacesUse => 'এই জায়গাগুলো নিন';

  @override
  String get onboardingPlacesSkip => 'এখন নয়';

  @override
  String get onboardingReadyTitle => 'সব তৈরি';

  @override
  String get onboardingReadyBody =>
      'প্রথম বইটি যোগ করুন, ব্যাকআপ থেকে লাইব্রেরি ফিরিয়ে আনুন, বা শুধু ঘুরে দেখুন।';

  @override
  String get onboardingAddFirst => 'প্রথম বইটি যোগ করুন';

  @override
  String get onboardingRestore => 'ব্যাকআপ থেকে ফিরিয়ে আনুন';

  @override
  String get onboardingExplore => 'অ্যাপটি ঘুরে দেখুন';

  @override
  String bookTileByAuthor(String authors) {
    return 'লেখক $authors';
  }

  @override
  String bookTileAt(String place) {
    return '$place-এ';
  }

  @override
  String get devSeedStore => 'স্টোরের নমুনা ডেটা আনুন (dev)';

  @override
  String get devSeedPerf => '5,000 বই ভরুন (dev)';

  @override
  String get devSeedPerfBusy => 'ভরা হচ্ছে…';

  @override
  String devSeedPerfDone(String summary) {
    return 'ভরা হল: $summary';
  }

  @override
  String paceDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আপনার গতিতে প্রায় $count দিন বাকি',
      one: 'আপনার গতিতে প্রায় 1 দিন বাকি',
    );
    return '$_temp0';
  }

  @override
  String paceFinishBy(String date) {
    return '$date-এর মধ্যে শেষ';
  }

  @override
  String get progressReachedEnd => 'এটাই শেষ পৃষ্ঠা!';

  @override
  String get progressMarkFinished => 'পড়া শেষ হিসেবে চিহ্নিত করুন';

  @override
  String detailPageInvalid(int max) {
    return '0 থেকে $max-এর মধ্যে একটি সংখ্যা দিন';
  }

  @override
  String get detailRateIt => 'রেটিং দেবেন?';

  @override
  String detailRateStar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count তারা দিন',
      one: '1 তারা দিন',
    );
    return '$_temp0';
  }

  @override
  String get detailFinishedCelebration => 'শেষ! দারুণ।';

  @override
  String get detailChange => 'বদলান';

  @override
  String detailLentTo(String name, String since) {
    return '$since থেকে $name-কে ধার দেওয়া';
  }

  @override
  String detailBorrowedFrom(String name, String since) {
    return '$since থেকে $name-এর কাছ থেকে ধার নেওয়া';
  }

  @override
  String detailDue(String date) {
    return 'ফেরতের তারিখ $date';
  }

  @override
  String get detailReturn => 'ফেরত';

  @override
  String get detailReturned => 'ফেরত হিসেবে চিহ্নিত';

  @override
  String get detailEdit => 'সম্পাদনা';

  @override
  String get detailShare => 'শেয়ার';

  @override
  String get detailMore => 'আরও';

  @override
  String detailShareText(String title, String authors) {
    return '$title, লেখক $authors';
  }

  @override
  String detailShareTextNoAuthor(String title) {
    return '$title';
  }

  @override
  String get detailDeleteTitle => 'বইটি মুছবেন?';

  @override
  String get detailDeleteBody =>
      'এটি আপনার লাইব্রেরি থেকে সরে যাবে। ঠিক পরেই ফিরিয়ে আনতে পারবেন।';

  @override
  String get detailSectionNotes => 'নোট';

  @override
  String get detailNotesHint => 'একটি নোট লিখুন';

  @override
  String get detailNotesSaved => 'নোট সংরক্ষিত হল';

  @override
  String get detailSectionTags => 'ট্যাগ';

  @override
  String get detailAddTag => 'ট্যাগ যোগ করুন';

  @override
  String get detailTagHint => 'ট্যাগের নাম';

  @override
  String detailRemoveTag(String name) {
    return '$name ট্যাগ সরান';
  }

  @override
  String get detailSectionDetails => 'বিবরণ';

  @override
  String get detailIsbn => 'ISBN';

  @override
  String get detailOwner => 'মালিক';

  @override
  String get detailAddedOn => 'যোগ করার তারিখ';

  @override
  String get detailStarted => 'শুরু';

  @override
  String get detailFinished => 'শেষ';

  @override
  String get detailBack => 'ফিরে যান';

  @override
  String detailPagesYear(int pages) {
    return '$pages পৃষ্ঠা';
  }

  @override
  String get editBookTitle => 'বই সম্পাদনা';

  @override
  String get bookSavedChanges => 'পরিবর্তন সংরক্ষিত হল';

  @override
  String get detailMove => 'সরান';

  @override
  String get scanSearchHint => 'নাম দিয়ে খুঁজুন';

  @override
  String get scanTypeIsbn => 'ISBN লিখুন';

  @override
  String get scanTorch => 'টর্চ';

  @override
  String get scanSwitchCamera => 'ক্যামেরা বদলান';

  @override
  String get scanPermTitle => 'Kitabkhana-কে ক্যামেরা ব্যবহার করতে দিন';

  @override
  String get scanPermBody =>
      'ক্যামেরা শুধু এই ডিভাইসে বারকোড পড়ে। কিছু রেকর্ড বা আপলোড হয় না।';

  @override
  String get scanPermAllow => 'ক্যামেরা চালু করুন';

  @override
  String get scanDeniedTitle => 'ক্যামেরা বন্ধ';

  @override
  String get scanDeniedBody =>
      'ক্যামেরা ছাড়াও নাম দিয়ে খুঁজতে বা ISBN লিখতে পারেন।';

  @override
  String get scanTryAgain => 'আবার চেষ্টা করুন';

  @override
  String get scanBlockedTitle => 'ক্যামেরার অনুমতি বন্ধ';

  @override
  String get scanBlockedBody =>
      'বারকোড স্ক্যান করতে সেটিংসে এটি চালু করুন। ততক্ষণ নাম দিয়ে খুঁজতে পারেন।';

  @override
  String get scanOpenSettings => 'সেটিংস খুলুন';

  @override
  String get scanNoCameraNote =>
      'এখানে ক্যামেরা নেই, তাই নাম দিয়ে খুঁজুন বা ISBN লিখুন।';

  @override
  String get scanWebHttpsNote =>
      'ওয়েবে ক্যামেরা দিয়ে স্ক্যান করতে সুরক্ষিত (HTTPS) পাতা দরকার।';

  @override
  String get scanChecking => 'আপনার লাইব্রেরি দেখা হচ্ছে…';

  @override
  String get verdictOwned => 'এটি আপনার আছে';

  @override
  String verdictOwnedWhere(String place) {
    return '$place-এ';
  }

  @override
  String get verdictNoPlace => 'কোনো জায়গা ঠিক করা নেই';

  @override
  String get verdictOtherEdition => 'আপনার কাছে এর অন্য একটি সংস্করণ আছে';

  @override
  String get verdictWishlist => 'আপনার ইচ্ছেতালিকায়';

  @override
  String get verdictMarkBought => 'কেনা হয়েছে বলে চিহ্নিত করুন';

  @override
  String verdictLentTo(String name) {
    return '$name-কে ধার দেওয়া';
  }

  @override
  String verdictSince(String date) {
    return '$date থেকে';
  }

  @override
  String verdictBorrowedFrom(String name) {
    return '$name-এর কাছ থেকে ধার নেওয়া';
  }

  @override
  String get verdictBorrowed => 'ধার নেওয়া';

  @override
  String get verdictDidYouMean => 'আপনি কি এটি খুঁজছেন…?';

  @override
  String get verdictNoneOfThese => 'এগুলোর কোনোটিই নয়';

  @override
  String get verdictNotInLibrary => 'আপনার লাইব্রেরিতে নেই';

  @override
  String get verdictAddWishlist => 'ইচ্ছেতালিকায় যোগ করুন';

  @override
  String get verdictBoughtIt => 'কিনেছি — লাইব্রেরিতে যোগ করুন';

  @override
  String get verdictOpenBook => 'বই খুলুন';

  @override
  String get verdictScanAnother => 'আরেকটি স্ক্যান করুন';

  @override
  String get verdictWishlistAdded => 'ইচ্ছেতালিকায় যোগ হল';

  @override
  String get verdictBoughtDone => 'কেনা হয়েছে বলে চিহ্নিত';

  @override
  String verdictMatch(int percent) {
    return '$percent% মিল';
  }

  @override
  String get verdictUnknownTitle => 'অজানা নাম';

  @override
  String get scanSearchLabel => 'বারকোড নেই?';

  @override
  String get lendAction => 'ধার দিন';

  @override
  String get lendSheetTitleLend => 'বইটি ধার দিন';

  @override
  String get lendSheetTitleBorrow => 'বইটি ধার নিয়েছি';

  @override
  String get lendToggleLend => 'ধার দিন';

  @override
  String get lendToggleBorrow => 'ধার নিন';

  @override
  String get lendPersonLent => 'কাকে দিলেন';

  @override
  String get lendPersonBorrowed => 'কার কাছ থেকে নিলেন';

  @override
  String get lendPhone => 'ফোন (ঐচ্ছিক)';

  @override
  String get lendPhoneHint => 'নম্বর, অন্য দেশের হলে কোডসহ';

  @override
  String get lendPhoneInvalid => 'এটি ফোন নম্বর মনে হচ্ছে না।';

  @override
  String get lendStarted => 'কবে থেকে';

  @override
  String get lendDue => 'ফেরতের তারিখ';

  @override
  String get lendDueNone => 'তারিখ নেই';

  @override
  String get lendDue1w => '1 সপ্তাহ';

  @override
  String get lendDue2w => '2 সপ্তাহ';

  @override
  String get lendDue1m => '1 মাস';

  @override
  String get lendDueCustom => 'তারিখ বাছুন';

  @override
  String get lendNote => 'নোট (ঐচ্ছিক)';

  @override
  String get lendSave => 'সংরক্ষণ';

  @override
  String get lendNameRequired => 'বইটি কার কাছে?';

  @override
  String lendSaved(String name) {
    return '$name-কে ধার দেওয়া হল';
  }

  @override
  String lendSavedBorrow(String name) {
    return '$name-এর কাছ থেকে ধার নেওয়া হল';
  }

  @override
  String get returnPickLocationTitle => 'এটি কোথায় ফিরবে?';

  @override
  String get returnPickLocationBody =>
      'এর পুরোনো জায়গা মুছে ফেলা হয়েছে। নতুন একটি বাছুন।';

  @override
  String returnBorrowedTitle(String name) {
    return '$name-কে ফেরত দেওয়া হল';
  }

  @override
  String get returnBorrowedRemove => 'আমার লাইব্রেরি থেকে সরান';

  @override
  String get returnBorrowedKeep => 'ইচ্ছেতালিকায় রাখুন';

  @override
  String get failureNeedsName => 'মানুষটির নাম লিখুন।';

  @override
  String get reminderChannelName => 'ধারের কথা মনে করানো';

  @override
  String get reminderChannelDesc =>
      'ধার দেওয়া বা নেওয়া বই ফেরতের দিন মনে করানো';

  @override
  String reminderDueTitle(String book) {
    return '“$book” আজ ফেরত দেওয়ার কথা';
  }

  @override
  String reminderLentDueBody(String name) {
    return '$name-এর কাছে আছে। আলতো করে মনে করাবেন?';
  }

  @override
  String reminderBorrowedDueBody(String name) {
    return '$name-কে ফেরত দেওয়ার সময় হয়েছে।';
  }

  @override
  String reminderOverdueTitle(String book) {
    return '“$book”-এর ফেরতের তারিখ পেরিয়েছে';
  }

  @override
  String reminderLentOverdueBody(String name) {
    return '$name-এর কাছে এখনও আছে। মনে করাবেন?';
  }

  @override
  String reminderBorrowedOverdueBody(String name) {
    return 'শিগগিরই $name-কে ফেরত দিন।';
  }

  @override
  String get reminderPermTitle => 'ফেরতের দিন মনে করাব?';

  @override
  String get reminderPermBody =>
      'বই ফেরতের দিন Kitabkhana আপনাকে মনে করিয়ে দিতে পারে। মনে করানো এই ডিভাইসেই থাকে।';

  @override
  String get reminderPermAllow => 'নোটিফিকেশন চালু করুন';

  @override
  String get reminderPermLater => 'এখন নয়';

  @override
  String nudgeMessage(String name, String book) {
    return 'হ্যালো $name! 📚 পড়া হয়ে গেলে “$book” ফেরত দেবেন? ধন্যবাদ!';
  }

  @override
  String get nudgeWhatsApp => 'WhatsApp-এ মনে করান';

  @override
  String get nudgeSms => 'SMS পাঠান';

  @override
  String get nudgeNoPhone => 'মনে করাতে একটি ফোন নম্বর যোগ করুন।';

  @override
  String get nudgeFailed => 'কোনো মেসেজিং অ্যাপ খোলা গেল না।';

  @override
  String get overdueBannerOne => '1টি বইয়ের ফেরতের তারিখ পেরিয়েছে';

  @override
  String overdueBannerMany(int count) {
    return '$countটি বইয়ের ফেরতের তারিখ পেরিয়েছে';
  }

  @override
  String get devTestReminder => 'পরীক্ষামূলক রিমাইন্ডার (2 মিনিট)';

  @override
  String get devTestReminderSet =>
      'পরীক্ষামূলক রিমাইন্ডার 2 মিনিট পরের জন্য রাখা হল';

  @override
  String get detailRemind => 'মনে করান';

  @override
  String get loansTitle => 'ধার';

  @override
  String get loansTabLent => 'ধার দেওয়া';

  @override
  String get loansTabBorrowed => 'ধার নেওয়া';

  @override
  String get loansTabOverdue => 'তারিখ পেরিয়েছে';

  @override
  String get loansTabHistory => 'ইতিহাস';

  @override
  String get loansEmptyLent => 'সবাই আপনার বই ফেরত দিয়েছেন। চমৎকার।';

  @override
  String get loansEmptyBorrowed => 'এখন আপনি কোনো বই ধার নেননি।';

  @override
  String get loansEmptyOverdue => 'কোনোটির তারিখ পেরোয়নি। বাহ্‌।';

  @override
  String get loansEmptyHistory => 'ফেরত আসা বই এখানে দেখা যাবে।';

  @override
  String loanSince(String date) {
    return '$date থেকে';
  }

  @override
  String loanDueOn(String date) {
    return 'ফেরত $date';
  }

  @override
  String get loanDueToday => 'আজ ফেরত';

  @override
  String loanDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিনে ফেরত',
      one: 'কাল ফেরত',
    );
    return '$_temp0';
  }

  @override
  String loanOverdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিন দেরি',
      one: '1 দিন দেরি',
    );
    return '$_temp0';
  }

  @override
  String get loanNoDue => 'তারিখ নেই';

  @override
  String loanReturnedOn(String date) {
    return '$date-এ ফেরত';
  }

  @override
  String get loanActionReturn => 'ফেরত';

  @override
  String get loanActionExtend => 'সময় বাড়ান';

  @override
  String get loanReturnedToast => 'ফেরত হিসেবে চিহ্নিত';

  @override
  String get extendTitle => 'ফেরতের তারিখ বাড়ান';

  @override
  String get extend1w => '+1 সপ্তাহ';

  @override
  String get extend2w => '+2 সপ্তাহ';

  @override
  String get extend1m => '+1 মাস';

  @override
  String extendDone(String date) {
    return 'এখন ফেরত $date';
  }

  @override
  String get loansOpenTooltip => 'ধার';
}

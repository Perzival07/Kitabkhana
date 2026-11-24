// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String coverSemantics(String title, String author) {
    return '$title का कवर, लेखक $author';
  }

  @override
  String coverSemanticsNoAuthor(String title) {
    return '$title का कवर';
  }

  @override
  String get statusWant => 'पढ़ना है';

  @override
  String get statusReading => 'पढ़ रहे हैं';

  @override
  String get statusFinished => 'पढ़ ली';

  @override
  String get statusDropped => 'छोड़ दी';

  @override
  String get seeAll => 'सब देखें';

  @override
  String get loading => 'लोड हो रहा है';

  @override
  String percentSemantics(int percent) {
    return '$percent प्रतिशत';
  }

  @override
  String get appName => 'Kitabkhana';

  @override
  String get navLibrary => 'लाइब्रेरी';

  @override
  String get navScan => 'स्कैन';

  @override
  String get navReading => 'पढ़ाई';

  @override
  String get navStats => 'आँकड़े';

  @override
  String get navMore => 'और';

  @override
  String get libraryTitle => 'आपकी लाइब्रेरी';

  @override
  String get libraryEmptyBody =>
      'अपनी पहली किताब जोड़ें और अपनी अलमारी सजाना शुरू करें।';

  @override
  String get scanTitle => 'दोबारा कभी न खरीदें';

  @override
  String get scanEmptyBody =>
      'बारकोड स्कैन करके देखें कि किताब आपके पास पहले से है या नहीं।';

  @override
  String get readingTitle => 'अभी पढ़ रहे हैं';

  @override
  String get readingEmptyBody =>
      'आपकी प्रगति, लगातार पढ़ाई के दिन और रफ़्तार यहाँ दिखेंगे।';

  @override
  String get statsTitle => 'आपका पढ़ाई का साल';

  @override
  String get statsEmptyBody =>
      'कुछ पढ़ाई दर्ज करते ही लक्ष्य और चार्ट यहाँ दिखेंगे।';

  @override
  String get moreTitle => 'और';

  @override
  String get moreEmptyBody => 'उधार, उद्धरण, जगहें और सेटिंग्स यहाँ हैं।';

  @override
  String get routeAddBook => 'किताब जोड़ें';

  @override
  String get routeBook => 'किताब';

  @override
  String get routeEditBook => 'किताब बदलें';

  @override
  String get routeLoans => 'उधार';

  @override
  String get routeQuotes => 'उद्धरण';

  @override
  String get routeLocations => 'जगहें';

  @override
  String get routeSettings => 'सेटिंग्स';

  @override
  String get routeOnboarding => 'स्वागत है';

  @override
  String get routeStubBody => 'यह स्क्रीन जल्द आ रही है।';

  @override
  String get notFoundTitle => 'यह पेज नहीं मिला';

  @override
  String get notFoundBody => 'लिंक पुराना या गलत लिखा हो सकता है।';

  @override
  String get goToLibrary => 'अपनी लाइब्रेरी पर जाएँ';

  @override
  String get detailPlaceholderTitle => 'कोई किताब चुनें';

  @override
  String get detailPlaceholderBody =>
      'बाईं ओर कोई किताब चुनें, उसका ब्योरा यहाँ दिखेगा।';

  @override
  String get failureOffline =>
      'लगता है आप ऑफ़लाइन हैं। बाकी सब ठीक से चलता रहेगा।';

  @override
  String get failureTimeout => 'बहुत देर लग गई। कृपया फिर कोशिश करें।';

  @override
  String get failureServer =>
      'किताबों की सेवा में दिक्कत है। कृपया थोड़ी देर बाद कोशिश करें।';

  @override
  String get failureRateLimited =>
      'एक साथ बहुत ज़्यादा खोज हो गईं। ज़रा रुकें।';

  @override
  String get failureNotFound => 'यह नहीं मिला।';

  @override
  String get failureValidation => 'कृपया जो लिखा है उसे जाँच लें।';

  @override
  String get failureConflict => 'यह पहले से सहेजी किसी चीज़ से टकराता है।';

  @override
  String get failureBookAlreadyLent => 'यह किताब पहले से उधार दी हुई है।';

  @override
  String get failureStorage => 'यह इस डिवाइस पर सहेजा नहीं जा सका।';

  @override
  String get failurePermissionCamera =>
      'बारकोड स्कैन करने के लिए कैमरे की अनुमति चाहिए।';

  @override
  String get failurePermissionNotifications =>
      'उधार की याद दिलाने के लिए सूचनाओं की अनुमति चाहिए।';

  @override
  String get failurePermissionFiles => 'इसके लिए फ़ाइलों तक पहुँच चाहिए।';

  @override
  String get failureUnsupported => 'यह इस डिवाइस पर उपलब्ध नहीं है।';

  @override
  String get failureUnexpected => 'कुछ गड़बड़ हो गई। कृपया फिर कोशिश करें।';

  @override
  String get errorWidgetTitle => 'यहाँ कुछ गड़बड़ हो गई';

  @override
  String get errorWidgetBody =>
      'वापस जाकर फिर कोशिश करें। आपकी लाइब्रेरी सुरक्षित है।';

  @override
  String get addBookTitle => 'किताब जोड़ें';

  @override
  String get addScanTitle => 'बारकोड स्कैन करें';

  @override
  String get addScanBody => 'कैमरा किताब के पिछले कवर पर रखें';

  @override
  String get addIsbnTitle => 'ISBN लिखें';

  @override
  String get addIsbnBody => '10 या 13 अंकों का नंबर डालें';

  @override
  String get addSearchTitle => 'नाम से खोजें';

  @override
  String get addSearchBody => 'Open Library के कैटलॉग में ढूँढें';

  @override
  String get addManualTitle => 'खुद भरें';

  @override
  String get addManualBody => 'ब्योरा खुद भरें';

  @override
  String get scanHint => 'कैमरा पिछले कवर के बारकोड पर रखें';

  @override
  String get scanUnavailableTitle => 'यहाँ कैमरे से स्कैन नहीं हो सकता';

  @override
  String get scanUnavailableBody => 'आप ISBN लिखकर भी किताब जोड़ सकते हैं।';

  @override
  String get isbnFieldLabel => 'ISBN';

  @override
  String get isbnFieldHint => '978…';

  @override
  String get isbnInvalid => 'यह सही ISBN नहीं लगता। कृपया अंक जाँच लें।';

  @override
  String get isbnIncomplete => 'ISBN में 10 या 13 अंक होते हैं।';

  @override
  String get isbnValid => 'सही ISBN';

  @override
  String get lookUp => 'खोजें';

  @override
  String get pasteFromClipboard => 'चिपकाएँ';

  @override
  String get lookingUp => 'खोज रहे हैं…';

  @override
  String get lookupNotFound => 'यह ISBN नहीं मिला। आप ब्योरा खुद भर सकते हैं।';

  @override
  String get searchFieldHint => 'नाम या लेखक से खोजें';

  @override
  String get searchPrompt => 'कैटलॉग में खोजने के लिए किताब का नाम लिखें।';

  @override
  String get searchNoResults =>
      'कुछ नहीं मिला। दूसरे शब्द आज़माएँ या किताब खुद भरें।';

  @override
  String get searchOffline =>
      'आप ऑफ़लाइन हैं, इसलिए कैटलॉग में खोज नहीं हो सकती। किताब खुद भर सकते हैं।';

  @override
  String get searchFailed =>
      'इस बार खोज नहीं हो पाई। फिर कोशिश करें या किताब खुद भरें।';

  @override
  String get enterManually => 'खुद भरें';

  @override
  String get fieldTitle => 'नाम';

  @override
  String get fieldSubtitle => 'उपशीर्षक';

  @override
  String get fieldAuthors => 'लेखक';

  @override
  String get fieldPages => 'पन्ने';

  @override
  String get fieldGenre => 'विधा';

  @override
  String get fieldLanguage => 'भाषा';

  @override
  String get fieldNotes => 'नोट्स';

  @override
  String get fieldOwnership => 'किसकी है';

  @override
  String get fieldStatus => 'पढ़ाई की स्थिति';

  @override
  String get fieldLocation => 'जगह';

  @override
  String get noLocation => 'कोई जगह नहीं';

  @override
  String get ownershipOwned => 'मेरी';

  @override
  String get ownershipWishlist => 'इच्छा-सूची';

  @override
  String get ownershipBorrowed => 'उधार ली';

  @override
  String get titleRequired => 'कृपया किताब का नाम लिखें';

  @override
  String get pagesInvalid =>
      'पन्नों की संख्या 0 से ज़्यादा पूरी संख्या होनी चाहिए';

  @override
  String get save => 'सहेजें';

  @override
  String get saveAndAddAnother => 'सहेजें और एक और जोड़ें';

  @override
  String get coverSection => 'कवर';

  @override
  String get coverTakePhoto => 'फ़ोटो लें';

  @override
  String get coverChoosePhoto => 'फ़ोटो चुनें';

  @override
  String get coverUseGenerated => 'बना हुआ कवर लगाएँ';

  @override
  String get coverPhotoFailed => 'यह फ़ोटो इस्तेमाल नहीं हो सकी।';

  @override
  String get fromCatalogue =>
      'Open Library कैटलॉग से। सहेजने से पहले कुछ भी बदल सकते हैं।';

  @override
  String get duplicateTitle => 'शायद यह आपके पास पहले से है';

  @override
  String duplicateBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ये किताबें आपके पास पहले से लगती हैं।',
      one: 'यह किताब आपके पास पहले से लगती है।',
    );
    return '$_temp0';
  }

  @override
  String get openExisting => 'वही खोलें';

  @override
  String get addAnotherCopy => 'एक और प्रति जोड़ें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String addedTo(String location) {
    return '$location में जोड़ी गई';
  }

  @override
  String get addedToLibrary => 'आपकी लाइब्रेरी में जोड़ी गई';

  @override
  String get view => 'देखें';

  @override
  String get saveFailed => 'सहेजा नहीं जा सका। कृपया फिर कोशिश करें।';

  @override
  String inLocation(String location) {
    return '$location में';
  }

  @override
  String yearAndPages(int year, int pages) {
    return '$year · $pages पन्ने';
  }

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पन्ने',
      one: '$count पन्ना',
    );
    return '$_temp0';
  }

  @override
  String get tryAgain => 'फिर कोशिश करें';

  @override
  String libraryBooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें',
      one: '$count किताब',
    );
    return '$_temp0';
  }

  @override
  String libraryLentOutCount(int count) {
    return '$count उधार दी गईं';
  }

  @override
  String get librarySearchHint => 'नाम या लेखक खोजें';

  @override
  String get libraryScanTooltip => 'बारकोड स्कैन करें';

  @override
  String get filterAll => 'सभी';

  @override
  String get filterWishlist => 'इच्छा-सूची';

  @override
  String get filterLentOut => 'उधार दी';

  @override
  String get filterBorrowed => 'उधार ली';

  @override
  String get filterLocation => 'जगह';

  @override
  String get filterTag => 'टैग';

  @override
  String get filterAnyLocation => 'कोई भी जगह';

  @override
  String get filterAnyTag => 'कोई भी टैग';

  @override
  String get filterNoTags => 'अभी कोई टैग नहीं';

  @override
  String get sortTooltip => 'क्रम';

  @override
  String get sortRecentlyAdded => 'हाल में जोड़ी गई';

  @override
  String get sortTitle => 'नाम';

  @override
  String get sortAuthor => 'लेखक';

  @override
  String get sortRecentlyRead => 'हाल में पढ़ी गई';

  @override
  String get sortRating => 'रेटिंग';

  @override
  String get viewAsGrid => 'ग्रिड में दिखाएँ';

  @override
  String get viewAsList => 'सूची में दिखाएँ';

  @override
  String get addBook => 'किताब जोड़ें';

  @override
  String get libraryEmptyTitle => 'आपकी अलमारी खाली है';

  @override
  String get libraryAddFirst => 'पहली किताब जोड़ें';

  @override
  String get libraryScanBarcode => 'बारकोड स्कैन करें';

  @override
  String libraryNoResultsQuery(String query) {
    return '“$query” से कुछ नहीं मिला';
  }

  @override
  String get libraryNoResultsFilters => 'इन फ़िल्टरों से कुछ नहीं मिला';

  @override
  String get libraryClearFilters => 'फ़िल्टर हटाएँ';

  @override
  String get lentRibbon => 'उधार';

  @override
  String get quickChangeStatus => 'स्थिति बदलें';

  @override
  String get quickMove => 'किसी जगह पर रखें';

  @override
  String get quickDelete => 'हटाएँ';

  @override
  String bookDeleted(String title) {
    return '“$title” हटाई गई';
  }

  @override
  String get undo => 'वापस लें';

  @override
  String bookMoved(String title) {
    return '“$title” की जगह बदली';
  }

  @override
  String bookStatusChanged(String title, String status) {
    return '“$title” को “$status” किया';
  }

  @override
  String get seedDemoData => '300 नमूना किताबें जोड़ें';

  @override
  String seedDemoDone(int count) {
    return '$count नमूना किताबें जोड़ी गईं';
  }

  @override
  String get libraryLoadFailed => 'आपकी किताबें लोड नहीं हो सकीं';

  @override
  String get locationsTitle => 'जगहें';

  @override
  String locationsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें',
      one: '1 किताब',
      zero: 'कोई किताब नहीं',
    );
    return '$_temp0';
  }

  @override
  String get locationAdd => 'जगह जोड़ें';

  @override
  String get locationRename => 'जगह का नाम बदलें';

  @override
  String get locationNameLabel => 'नाम';

  @override
  String get locationNameExists => 'इस नाम की जगह पहले से है।';

  @override
  String get locationNameEmpty => 'जगह को कोई नाम दें।';

  @override
  String get locationIconLabel => 'आइकन';

  @override
  String get locationIconShelf => 'अलमारी';

  @override
  String get locationIconBox => 'डिब्बा';

  @override
  String get locationIconRoom => 'कमरा';

  @override
  String get locationIconBag => 'बैग';

  @override
  String get locationIconOffice => 'दफ़्तर';

  @override
  String get locationIconOther => 'अन्य';

  @override
  String get locationParentLabel => 'किसके अंदर (वैकल्पिक)';

  @override
  String get locationNoParent => 'किसी के अंदर नहीं';

  @override
  String get locationEdit => 'नाम या आइकन बदलें';

  @override
  String get locationDelete => 'जगह हटाएँ';

  @override
  String locationDeleteTitle(String name) {
    return '\"$name\" हटाएँ?';
  }

  @override
  String get locationDeleteEmpty => 'इस जगह पर कोई किताब नहीं है।';

  @override
  String locationMoveBooksTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें कहाँ रखें…',
      one: '1 किताब कहाँ रखें…',
    );
    return '$_temp0';
  }

  @override
  String get locationDeleteConfirm => 'हटाएँ और किताबें रखें';

  @override
  String get locationDeleted => 'जगह हटाई गई';

  @override
  String get locationsEmptyTitle => 'आपकी किताबें कहाँ रहती हैं?';

  @override
  String get locationsEmptyBody =>
      'अलमारियाँ, डिब्बे या कमरे जोड़ें, ताकि कोई भी किताब झट से मिल जाए।';

  @override
  String get locationsStarterTitle => 'इनसे शुरू करें?';

  @override
  String get locationsStarterAccept => 'तीनों जोड़ें';

  @override
  String get locationsStarterSkip => 'छोड़ें';

  @override
  String get starterLivingRoom => 'बैठक की अलमारी';

  @override
  String get starterBedroom => 'सोने के कमरे की अलमारी';

  @override
  String get starterStorage => 'रखने का डिब्बा';

  @override
  String get locationReorderHint => 'क्रम बदलने के लिए खींचें';

  @override
  String get locationPickerTitle => 'जगह चुनें';

  @override
  String get locationPickerSearch => 'खोजें या नई बनाएँ';

  @override
  String get locationPickerRecent => 'हाल की';

  @override
  String get locationPickerAll => 'सभी जगहें';

  @override
  String locationCreateNew(String name) {
    return '\"$name\" बनाएँ';
  }

  @override
  String get locationCreateNewPlain => 'नई जगह बनाएँ';

  @override
  String get locationsManage => 'जगहें सँभालें';

  @override
  String get bookNotFound => 'यह किताब अब आपकी लाइब्रेरी में नहीं है।';

  @override
  String detailPageOf(int current, int total) {
    return 'पन्ना $current / $total';
  }

  @override
  String detailPercentRead(int percent) {
    return '$percent% पढ़ी';
  }

  @override
  String get detailUpdatePage => 'पन्ना बदलें';

  @override
  String get detailUpdatePageTitle => 'आप अभी कहाँ तक पहुँचे?';

  @override
  String get detailPageLabel => 'पन्ना';

  @override
  String get detailPercentLabel => 'कितने प्रतिशत पढ़ी';

  @override
  String get detailPageDecrease => 'पिछला पन्ना';

  @override
  String get detailPageIncrease => 'अगला पन्ना';

  @override
  String detailPageAddPages(int count) {
    return '$count पन्ने जोड़ें';
  }

  @override
  String get readingGreetingMorning => 'सुप्रभात';

  @override
  String get readingGreetingAfternoon => 'नमस्ते';

  @override
  String get readingGreetingEvening => 'शुभ संध्या';

  @override
  String readingStreakDays(int count) {
    return '$count दिन लगातार';
  }

  @override
  String readingStreakLongest(int count) {
    return 'सबसे लंबा: $count';
  }

  @override
  String get readingCurrentlyReading => 'अभी पढ़ रहे हैं';

  @override
  String readingPageOf(int current, int total) {
    return 'पन्ना $current / $total';
  }

  @override
  String get readingToday => 'आज';

  @override
  String readingPagesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आज $count पन्ने',
      one: 'आज 1 पन्ना',
      zero: 'आज अभी कोई पन्ना नहीं',
    );
    return '$_temp0';
  }

  @override
  String readingLast7Days(int count) {
    return 'पिछले 7 दिन: $count पन्ने';
  }

  @override
  String readingOverdueTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबों की तारीख निकल गई है',
      one: '1 किताब की तारीख निकल गई है',
    );
    return '$_temp0';
  }

  @override
  String get readingOverdueBody => 'देखें किसके पास हैं';

  @override
  String get readingUpNext => 'आगे पढ़ने को';

  @override
  String get readingPickNext => 'अगली किताब चुनें';

  @override
  String get readingPickNextBody =>
      '\'पढ़ना है\' वाली सूची से कुछ चुनें, या नई किताब जोड़ें।';

  @override
  String get readingPickNextEmptyBody =>
      'जो किताब पढ़नी है उसे जोड़ें, वह यहाँ आपका इंतज़ार करेगी।';

  @override
  String get readingAddBook => 'किताब जोड़ें';

  @override
  String get statsYearPrevious => 'पिछला साल';

  @override
  String get statsYearNext => 'अगला साल';

  @override
  String get statsGoalTitle => 'पढ़ाई का लक्ष्य';

  @override
  String statsGoalOf(int finished, int target) {
    return '$target में से $finished किताबें';
  }

  @override
  String get statsGoalReached => 'लक्ष्य पूरा। शाबाश!';

  @override
  String statsGoalAhead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'रफ़्तार से $count किताबें आगे',
      one: 'रफ़्तार से 1 किताब आगे',
    );
    return '$_temp0';
  }

  @override
  String statsGoalBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'रफ़्तार से $count किताबें पीछे',
      one: 'रफ़्तार से 1 किताब पीछे',
    );
    return '$_temp0';
  }

  @override
  String get statsGoalOnPace => 'बिल्कुल सही रफ़्तार';

  @override
  String statsGoalMissed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें कम रह गईं',
      one: '1 किताब कम रह गई',
    );
    return '$_temp0';
  }

  @override
  String get statsGoalUpcoming => 'नया साल सामने है';

  @override
  String get statsGoalSetTitle => 'पढ़ाई का लक्ष्य तय करें';

  @override
  String statsGoalSetBody(int year) {
    return '$year में कितनी किताबें पूरी करना चाहेंगे, चुनें।';
  }

  @override
  String get statsGoalCta => 'लक्ष्य तय करें';

  @override
  String get statsGoalEdit => 'लक्ष्य बदलें';

  @override
  String statsGoalSheetTitle(int year) {
    return '$year में पूरी करनी हैं';
  }

  @override
  String get statsGoalFewer => 'कम किताबें';

  @override
  String get statsGoalMore => 'ज़्यादा किताबें';

  @override
  String get statsGoalRemove => 'लक्ष्य हटाएँ';

  @override
  String get statsGoalInvalid => '1 से 999 तक कोई संख्या लिखें';

  @override
  String get statsMonthlyTitle => 'हर महीने पूरी हुई किताबें';

  @override
  String get statsMonthlyEmpty =>
      'कोई किताब पूरी करें, उसका महीना यहाँ चमक उठेगा।';

  @override
  String statsMonthBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें',
      one: '1 किताब',
    );
    return '$_temp0';
  }

  @override
  String statsMonthSheetTitle(String month) {
    return '$month में पूरी हुईं';
  }

  @override
  String get statsWeeklyTitle => 'हर हफ़्ते के पन्ने';

  @override
  String get statsWeeklyEmpty =>
      'पढ़ते हुए पन्ना बदलते रहें, आपके हफ़्ते यहाँ दिखेंगे।';

  @override
  String statsWeeklyTotal(int count) {
    return '12 हफ़्तों में $count पन्ने';
  }

  @override
  String get statsGenresTitle => 'पसंदीदा विधाएँ';

  @override
  String get statsAuthorsTitle => 'पसंदीदा लेखक';

  @override
  String get statsTopEmpty => 'इस साल के लिए अभी यहाँ कुछ नहीं।';

  @override
  String get statsFactsTitle => 'आपकी लाइब्रेरी';

  @override
  String get statsFactTotal => 'किताबें';

  @override
  String get statsFactOwned => 'मेरी';

  @override
  String get statsFactWishlist => 'इच्छा-सूची';

  @override
  String get statsFactLent => 'उधार दी';

  @override
  String get statsFactRating => 'औसत रेटिंग';

  @override
  String get statsFactLongest => 'सबसे लंबी किताब';

  @override
  String statsFactPages(int count) {
    return '$count पन्ने';
  }

  @override
  String get statsFactNone => 'अभी कोई नहीं';

  @override
  String get statsEmptyAdd => 'किताब जोड़ें';

  @override
  String get statsEmptyTitle => 'आपका पढ़ाई का साल यहाँ से शुरू होता है';

  @override
  String get quoteCaptureTitle => 'उद्धरण खींचें';

  @override
  String get quoteSourceBody =>
      'पन्ने की फ़ोटो लें और पसंद की पंक्तियाँ छुएँ, या उन्हें लिख दें। सिर्फ़ शब्द रखे जाते हैं; फ़ोटो कभी सहेजी नहीं जाती।';

  @override
  String get quoteTakePhoto => 'फ़ोटो लें';

  @override
  String get quoteChoosePhoto => 'फ़ोटो चुनें';

  @override
  String get quoteTypeIt => 'इसके बजाय लिखें';

  @override
  String get quoteRotateLeft => 'बाएँ घुमाएँ';

  @override
  String get quoteRotateRight => 'दाएँ घुमाएँ';

  @override
  String get quoteReadText => 'शब्द पढ़ें';

  @override
  String get quoteReading => 'पन्ना पढ़ रहे हैं…';

  @override
  String get quotePickLines => 'जो पंक्तियाँ रखनी हैं उन्हें छुएँ।';

  @override
  String get quoteSelectAll => 'सब चुनें';

  @override
  String get quoteUseSelected => 'चुनी पंक्तियाँ लें';

  @override
  String get quoteNoText => 'कोई शब्द नहीं मिले। आप उद्धरण लिख सकते हैं।';

  @override
  String get quoteReadFailed =>
      'यह फ़ोटो पढ़ी नहीं जा सकी। दूसरी आज़माएँ, या लिख दें।';

  @override
  String get quoteBodyLabel => 'उद्धरण';

  @override
  String get quotePageLabel => 'पन्ना (वैकल्पिक)';

  @override
  String get quotePageInvalid => 'किताब के अंदर का कोई पन्ना लिखें';

  @override
  String get quoteBodyRequired => 'पहले उद्धरण लिखें';

  @override
  String get quotePickAgain => 'फिर से पंक्तियाँ चुनें';

  @override
  String get quoteSave => 'उद्धरण सहेजें';

  @override
  String get quoteSaved => 'उद्धरण सहेजा गया';

  @override
  String get quotesSectionTitle => 'उद्धरण';

  @override
  String get quotesSectionEmpty => 'इस किताब की पसंदीदा पंक्तियाँ सँजोकर रखें।';

  @override
  String get quoteSnap => 'उद्धरण खींचें';

  @override
  String quotePageShort(int page) {
    return 'पृ. $page';
  }

  @override
  String get quotesTitle => 'उद्धरण';

  @override
  String get quotesSearchHint => 'अपने उद्धरण खोजें';

  @override
  String get quotesFavourites => 'पसंदीदा';

  @override
  String get quotesAllBooks => 'सभी किताबें';

  @override
  String get quotesPickBook => 'यह किस किताब से है?';

  @override
  String get quotesBookFilterTitle => 'इस किताब के उद्धरण दिखाएँ';

  @override
  String get quotesEmptyTitle => 'अभी कोई उद्धरण नहीं';

  @override
  String get quotesEmptyBody =>
      'पन्ने की फ़ोटो लें या कोई पंक्ति लिखें, आपके पसंदीदा अंश यहाँ रहेंगे।';

  @override
  String get quotesNoMatch => 'कोई उद्धरण नहीं मिला।';

  @override
  String get quotesNoBooksYet =>
      'पहले कोई किताब जोड़ें, फिर उसके उद्धरण सहेजें।';

  @override
  String quoteAttribution(String title) {
    return '$title';
  }

  @override
  String quoteAttributionPage(String title, int page) {
    return '$title, पृ. $page';
  }

  @override
  String get quoteFavourite => 'पसंदीदा बनाएँ';

  @override
  String get quoteUnfavourite => 'पसंदीदा से हटाएँ';

  @override
  String get quoteEdit => 'बदलें';

  @override
  String get quoteEditTitle => 'उद्धरण बदलें';

  @override
  String get quoteShareImage => 'तस्वीर के रूप में भेजें';

  @override
  String get quoteShareText => 'शब्दों के रूप में भेजें';

  @override
  String get quoteDelete => 'हटाएँ';

  @override
  String get quoteDeleted => 'उद्धरण हटाया गया';

  @override
  String quoteShareTextBody(String body, String attribution) {
    return '“$body”\n— $attribution';
  }

  @override
  String get quoteMore => 'और';

  @override
  String get quoteOfWeekTitle => 'इस हफ़्ते का उद्धरण';

  @override
  String get failureBackupNotABackup => 'यह Kitabkhana का बैकअप नहीं है।';

  @override
  String get failureBackupDamaged =>
      'यह बैकअप खराब लगता है, इसलिए कुछ नहीं बदला गया।';

  @override
  String get failureBackupNewer =>
      'यह बैकअप नए वर्ज़न से बना है। पहले ऐप अपडेट करें।';

  @override
  String get backupExportTitle => 'अपनी लाइब्रेरी का बैकअप लें';

  @override
  String get backupExportWarning =>
      'बैकअप फ़ाइल में आपकी पूरी लाइब्रेरी होती है, उन लोगों के नाम और फ़ोन नंबर भी जिन्हें आपने किताबें उधार दीं। इसे किसी निजी जगह रखें।';

  @override
  String get backupExportAction => 'बैकअप बनाएँ';

  @override
  String get backupPreparing => 'आपका बैकअप तैयार हो रहा है…';

  @override
  String get backupOpening => 'फ़ाइल जाँच रहे हैं…';

  @override
  String get backupRestoring => 'आपकी लाइब्रेरी वापस ला रहे हैं…';

  @override
  String get backupRestoreTitle => 'बैकअप से वापस लाएँ';

  @override
  String backupFound(String date, int books, int loans, int quotes) {
    String _temp0 = intl.Intl.pluralLogic(
      books,
      locale: localeName,
      other: '$books किताबें',
      one: '1 किताब',
    );
    String _temp1 = intl.Intl.pluralLogic(
      loans,
      locale: localeName,
      other: '$loans उधार',
      one: '1 उधार',
    );
    String _temp2 = intl.Intl.pluralLogic(
      quotes,
      locale: localeName,
      other: '$quotes उद्धरण',
      one: '1 उद्धरण',
    );
    return '$date को बना: $_temp0, $_temp1, $_temp2।';
  }

  @override
  String get backupModeMerge => 'मेरी लाइब्रेरी में मिलाएँ';

  @override
  String get backupModeMergeBody =>
      'जो नहीं है वह जोड़ें, और जो दोनों में है उसका नया रूप रखें।';

  @override
  String get backupModeReplace => 'मेरी लाइब्रेरी बदल दें';

  @override
  String get backupModeReplaceBody => 'यह लाइब्रेरी मिटाकर बैकअप वाली लगाएँ।';

  @override
  String get backupReplaceConfirmTitle => 'अपनी लाइब्रेरी बदलें?';

  @override
  String get backupReplaceConfirmBody =>
      'यहाँ का सब कुछ बैकअप से बदल जाएगा। पहले आपकी अभी की लाइब्रेरी की एक सुरक्षा-प्रति सहेजी जाएगी।';

  @override
  String get backupReplaceConfirm => 'बदलें';

  @override
  String get backupDoneTitle => 'बैकअप वापस आ गया';

  @override
  String backupImported(int books, int loans, int quotes) {
    String _temp0 = intl.Intl.pluralLogic(
      books,
      locale: localeName,
      other: '$books किताबें',
      one: '1 किताब',
    );
    String _temp1 = intl.Intl.pluralLogic(
      loans,
      locale: localeName,
      other: '$loans उधार',
      one: '1 उधार',
    );
    String _temp2 = intl.Intl.pluralLogic(
      quotes,
      locale: localeName,
      other: '$quotes उद्धरण',
      one: '1 उद्धरण',
    );
    return 'आयात हुए: $_temp0, $_temp1, $_temp2।';
  }

  @override
  String backupCoversSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कवर कॉपी नहीं हो सके।',
      one: '1 कवर कॉपी नहीं हो सका।',
    );
    return '$_temp0';
  }

  @override
  String get ok => 'ठीक है';

  @override
  String get csvPreparing => 'आपकी स्प्रेडशीट तैयार हो रही हैं…';

  @override
  String get csvExportTitle => 'स्प्रेडशीट के रूप में निकालें';

  @override
  String get csvExportWarning =>
      'books.csv और loans.csv Excel, Numbers या Google Sheets में खुलती हैं। उधार में उन लोगों के नाम और फ़ोन नंबर होते हैं जिन्हें आपने दीं या जिनसे लीं।';

  @override
  String get csvExportAction => 'निकालें';

  @override
  String get eraseTitle => 'सारा डेटा मिटाएँ?';

  @override
  String get eraseBody =>
      'इससे हर किताब, उधार, उद्धरण और पढ़ाई का रिकॉर्ड, आपके कवर, सेटिंग्स और इस डिवाइस पर रखे बैकअप हमेशा के लिए मिट जाएँगे। यह वापस नहीं होगा। अगर लाइब्रेरी फिर चाहिए हो सकती है, तो पहले बैकअप भेज दें।';

  @override
  String get eraseContinue => 'आगे बढ़ें';

  @override
  String eraseTypeTitle(String word) {
    return 'पक्का करने के लिए $word लिखें';
  }

  @override
  String get eraseTypeHint => 'शब्द बिल्कुल वैसे ही, बड़े अक्षरों में लिखें।';

  @override
  String get eraseAction => 'सब कुछ मिटाएँ';

  @override
  String get eraseWorking => 'मिटा रहे हैं…';

  @override
  String get eraseDone => 'सारा डेटा मिट गया। नई शुरुआत।';

  @override
  String get readingReminderTitle => 'कुछ पन्ने पढ़ने का समय?';

  @override
  String get readingReminderBody => 'लगातार पढ़ाई का सिलसिला जारी रखें।';

  @override
  String get moreGroupLibrary => 'आपकी लाइब्रेरी';

  @override
  String get moreGroupApp => 'ऐप';

  @override
  String get moreLoans => 'उधार';

  @override
  String get moreQuotes => 'उद्धरण';

  @override
  String get moreLocations => 'जगहें';

  @override
  String get moreTags => 'टैग';

  @override
  String get moreSettings => 'सेटिंग्स';

  @override
  String get moreAbout => 'जानकारी';

  @override
  String moreCountOut(int count) {
    return '$count बाहर';
  }

  @override
  String get tagsTitle => 'टैग';

  @override
  String get tagsEmptyTitle => 'अभी कोई टैग नहीं';

  @override
  String get tagsEmptyBody =>
      'किताब के पेज से उसमें टैग जोड़ें, वे यहाँ दिखेंगे।';

  @override
  String tagsBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें',
      one: '1 किताब',
      zero: 'कोई किताब नहीं',
    );
    return '$_temp0';
  }

  @override
  String get tagsRename => 'नाम बदलें';

  @override
  String get tagsRenameTitle => 'टैग का नाम बदलें';

  @override
  String get tagsNameLabel => 'टैग का नाम';

  @override
  String get tagsNameTaken => 'इस नाम का टैग पहले से है।';

  @override
  String get tagsDelete => 'हटाएँ';

  @override
  String get tagsDeleteTitle => 'यह टैग हटाएँ?';

  @override
  String get tagsDeleteBody => 'यह हर किताब से हट जाएगा। किताबें बनी रहेंगी।';

  @override
  String get tagsDeleted => 'टैग हटाया गया';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsAppearance => 'रूप-रंग';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsThemeLight => 'हल्की';

  @override
  String get settingsThemeDark => 'गहरी';

  @override
  String get settingsDefaultView => 'लाइब्रेरी किस तरह दिखे';

  @override
  String get settingsViewGrid => 'ग्रिड';

  @override
  String get settingsViewList => 'सूची';

  @override
  String get settingsDensity => 'ग्रिड का घनत्व';

  @override
  String get settingsDensityComfortable => 'खुला-खुला';

  @override
  String get settingsDensityCompact => 'सघन';

  @override
  String get settingsReading => 'पढ़ाई';

  @override
  String get settingsGoal => 'सालाना लक्ष्य';

  @override
  String settingsGoalValue(int count, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$year में $count किताबें',
      one: '$year में 1 किताब',
    );
    return '$_temp0';
  }

  @override
  String settingsGoalNone(int year) {
    return '$year के लिए तय नहीं';
  }

  @override
  String get settingsReadingReminder => 'रोज़ पढ़ने की याद';

  @override
  String get settingsReadingReminderBody =>
      'आपके चुने समय पर हल्की-सी याद। उस दिन पढ़ लिया हो तो नहीं आएगी।';

  @override
  String get settingsReminderTime => 'याद का समय';

  @override
  String get settingsLending => 'उधार देना';

  @override
  String get settingsLoanLength => 'उधार की सामान्य अवधि';

  @override
  String get settingsLoanLengthNone => 'कोई तारीख नहीं';

  @override
  String settingsLoanLengthDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return '$_temp0';
  }

  @override
  String get settingsLoanLengthSheet =>
      'आप आमतौर पर किताब कितने दिन के लिए देते हैं?';

  @override
  String get settingsLoanLengthHelp => '0 का मतलब कोई तारीख नहीं।';

  @override
  String get settingsCountryCode => 'डिफ़ॉल्ट देश कोड';

  @override
  String settingsCountryCodeValue(String code) {
    return '+$code';
  }

  @override
  String get settingsCountryCodeSheet => 'फ़ोन नंबरों का देश कोड';

  @override
  String get settingsCountryCodeHelp =>
      'जब नंबर बिना कोड के लिखा हो तब काम आता है। सिर्फ़ अंक, जैसे 91।';

  @override
  String get settingsLoanReminderTime => 'उधार की याद का समय';

  @override
  String get settingsData => 'आपका डेटा';

  @override
  String get settingsBackupNow => 'अभी बैकअप लें';

  @override
  String settingsBackupLast(String when) {
    return 'पिछला बैकअप: $when';
  }

  @override
  String get settingsBackupNever => 'अभी तक बैकअप नहीं';

  @override
  String get settingsBackupToday => 'आज';

  @override
  String get settingsBackupYesterday => 'कल';

  @override
  String settingsBackupDaysAgo(int count) {
    return '$count दिन पहले';
  }

  @override
  String get settingsBackupSaved => 'बैकअप इस डिवाइस पर सहेजा गया।';

  @override
  String get settingsAutoBackup => 'हर हफ़्ते अपने-आप बैकअप';

  @override
  String get settingsAutoBackupBody =>
      'इस ऐप के स्टोरेज में आखिरी 3 प्रतियाँ रखता है।';

  @override
  String get settingsShareBackup => 'बैकअप भेजें';

  @override
  String get settingsRestore => 'बैकअप से वापस लाएँ';

  @override
  String get settingsExportCsv => 'स्प्रेडशीट (CSV) के रूप में निकालें';

  @override
  String get settingsErase => 'सारा डेटा मिटाएँ';

  @override
  String get settingsPrivacy => 'निजता';

  @override
  String get settingsPrivacyBody =>
      'आपकी लाइब्रेरी इस डिवाइस से तभी बाहर जाती है जब आप खुद बैकअप या निर्यात भेजें। न कोई खाता है, न कोई ट्रैकिंग। किताबों का ब्योरा ISBN या नाम से Open Library पर खोजा जाता है (और वहाँ न मिले तो Google Books पर), और कवर वहीं से आते हैं; इसके अलावा कुछ नहीं भेजा जाता।';

  @override
  String get settingsCrashReports => 'समस्या की रिपोर्ट भेजने का सुझाव दें';

  @override
  String get settingsCrashReportsBody =>
      'कुछ गड़बड़ होने पर Kitabkhana डेवलपर को ईमेल से रिपोर्ट भेजने का सुझाव देता है। जब तक आप अपने मेल ऐप में भेजें न दबाएँ, कुछ नहीं जाता।';

  @override
  String get settingsSaveCopy => 'कॉपी यहाँ सहेजें…';

  @override
  String get settingsSaveCopyBody =>
      'Google Drive, iCloud Drive, Downloads या USB स्टिक, ताकि फ़ोन खोने पर भी लाइब्रेरी बची रहे।';

  @override
  String settingsSaveCopyLast(String when) {
    return 'फ़ोन से बाहर पिछली कॉपी: $when';
  }

  @override
  String get backupCopySaved => 'कॉपी सहेजी गई';

  @override
  String get offDeviceTitle => 'आपकी लाइब्रेरी सिर्फ़ इसी फ़ोन पर है';

  @override
  String get offDeviceBody =>
      'अपने-आप बने बैकअप फ़ोन पर ही रहते हैं, फ़ोन के साथ वे भी चले जाएँगे। Google Drive, iCloud Drive या कंप्यूटर पर एक कॉपी रख लें।';

  @override
  String get offDeviceSave => 'कॉपी सहेजें';

  @override
  String get offDeviceLater => 'बाद में';

  @override
  String get settingsImportApp => 'Goodreads या StoryGraph से लाएँ';

  @override
  String get settingsImportAppBody =>
      'किसी भी ऐप के \"Export library\" वाली CSV फ़ाइल इस्तेमाल करें।';

  @override
  String get importNotAnExport =>
      'यह Goodreads या StoryGraph का निर्यात नहीं लगता।';

  @override
  String importTitle(String app) {
    return '$app से लाएँ';
  }

  @override
  String importFound(int count, int existing) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फ़ाइल में $count किताबें',
      one: 'फ़ाइल में 1 किताब',
    );
    return '$_temp0, $existing पहले से आपकी लाइब्रेरी में।';
  }

  @override
  String importAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें जोड़ें',
      one: '1 किताब जोड़ें',
    );
    return '$_temp0';
  }

  @override
  String importWantQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें आपकी \'पढ़नी है\' सूची में हैं। इन्हें कहाँ रखें?',
      one: '1 किताब आपकी \'पढ़नी है\' सूची में है। इसे कहाँ रखें?',
    );
    return '$_temp0';
  }

  @override
  String get importWantWishlist => 'मेरी इच्छा-सूची में (ये मेरे पास नहीं हैं)';

  @override
  String get importWantOwned => 'मेरी अलमारी में (ये मेरे पास हैं)';

  @override
  String get importNothingNew => 'जोड़ने को कुछ नया नहीं';

  @override
  String get importWorking => 'किताबें जोड़ रहे हैं…';

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें जोड़ीं',
      one: '1 किताब जोड़ी',
      zero: 'कोई नई किताब नहीं जुड़ी',
    );
    return '$_temp0';
  }

  @override
  String get batchTitle => 'पूरी अलमारी स्कैन करें';

  @override
  String get batchBody =>
      'एक के बाद एक बारकोड स्कैन करें, फिर सब एक साथ जोड़ें';

  @override
  String get batchHint => 'हर किताब का बारकोड स्कैन करें; कैमरा खुला रहेगा';

  @override
  String get batchEmpty =>
      'स्कैन की हुई किताबें यहाँ दिखेंगी। जो नहीं चाहिए उनका निशान हटा दें।';

  @override
  String get batchOwned => 'पहले से आपकी लाइब्रेरी में';

  @override
  String get batchNotFound => 'नहीं मिली; बाद में खुद जोड़ें';

  @override
  String get batchFailed => 'खोज नहीं हो सकी; इंटरनेट जाँचें';

  @override
  String get batchRemove => 'हटाएँ';

  @override
  String get batchPlace => 'इन्हें कहाँ रखें';

  @override
  String batchAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें जोड़ें',
      one: '1 किताब जोड़ें',
      zero: 'किताबें जोड़ें',
    );
    return '$_temp0';
  }

  @override
  String batchAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें जोड़ीं',
      one: '1 किताब जोड़ी',
      zero: 'कोई किताब नहीं जुड़ी',
    );
    return '$_temp0';
  }

  @override
  String get close => 'बंद करें';

  @override
  String get statsShareYear => 'अपना साल साझा करें';

  @override
  String yearReviewTitle(String year) {
    return 'किताबों में मेरा $year';
  }

  @override
  String yearReviewBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'किताबें पूरी कीं',
      one: 'किताब पूरी की',
    );
    return '$_temp0';
  }

  @override
  String get yearReviewPages => 'पन्ने पढ़े';

  @override
  String get yearReviewStreak => 'सबसे लंबा सिलसिला (दिन)';

  @override
  String get yearReviewGoal => 'पढ़ाई का लक्ष्य';

  @override
  String get yearReviewTopGenre => 'पसंदीदा विधा';

  @override
  String get yearReviewTopAuthor => 'सबसे ज़्यादा पढ़े लेखक';

  @override
  String get yearReviewLongest => 'सबसे लंबी किताब';

  @override
  String yearReviewLongestValue(String title, int pages) {
    return '$title · $pages पन्ने';
  }

  @override
  String get yearReviewFooter => 'Kitabkhana के साथ बनाया';

  @override
  String get yearReviewShare => 'भेजें';

  @override
  String get yearReviewEmpty =>
      'इस साल कोई किताब पूरी करें या कुछ पन्ने दर्ज करें, आपका साल यहाँ दिखेगा।';

  @override
  String get quoteScriptLabel => 'पन्ना किस लिपि में है';

  @override
  String get quoteScriptLatin => 'अंग्रेज़ी और अन्य लैटिन लिपियाँ';

  @override
  String get quoteScriptDevanagari => 'हिन्दी, मराठी (देवनागरी)';

  @override
  String get timerStart => 'पढ़ाई का टाइमर शुरू करें';

  @override
  String timerStop(String time) {
    return 'टाइमर रोकें ($time)';
  }

  @override
  String timerRunning(String time) {
    return '$time से पढ़ रहे हैं';
  }

  @override
  String timerLogged(String time) {
    return '$time की पढ़ाई दर्ज की';
  }

  @override
  String get timerTooShort => 'एक मिनट से कम, इसलिए कुछ दर्ज नहीं हुआ';

  @override
  String durationMinutes(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String durationHours(int hours) {
    return '$hours घंटे';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours घंटे $minutes मिनट';
  }

  @override
  String readingTimeToday(String time) {
    return 'टाइमर से $time';
  }

  @override
  String get statsTimeTitle => 'पढ़ाई का समय';

  @override
  String get statsTimeBody => 'पढ़ाई टैब के टाइमर से मापा गया।';

  @override
  String get statsTimeNone =>
      'जो किताब पढ़ रहे हैं उस पर टाइमर चलाएँ, आपका पढ़ाई का समय यहाँ दिखेगा।';

  @override
  String get rereadAction => 'फिर से पढ़ें';

  @override
  String get rereadStarted => 'नई पढ़ाई आज से शुरू। पिछली दर्ज रहेगी।';

  @override
  String rereadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बार पढ़ी',
    );
    return '$_temp0';
  }

  @override
  String get rereadEarlier => 'पहले की पढ़ाई';

  @override
  String rereadRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String rereadFinishedOn(String date) {
    return '$date को पूरी की';
  }

  @override
  String rereadStartedOn(String date) {
    return '$date को शुरू की';
  }

  @override
  String get rereadUndated => 'पहले पढ़ी (तारीख नहीं)';

  @override
  String get fieldSeries => 'शृंखला';

  @override
  String get fieldSeriesNumber => 'क्रमांक';

  @override
  String get fieldSeriesNumberInvalid => 'कोई संख्या';

  @override
  String seriesPlace(String number, String series) {
    return '$series की किताब $number';
  }

  @override
  String seriesOnly(String series) {
    return '$series का हिस्सा';
  }

  @override
  String get seriesYouHave => 'आपकी लाइब्रेरी में';

  @override
  String seriesMissing(String numbers) {
    return 'नहीं हैं: $numbers';
  }

  @override
  String get seriesComplete => 'यहाँ तक की हर किताब आपके पास है।';

  @override
  String get lendFromContacts => 'संपर्कों से चुनें';

  @override
  String get widgetLabel => 'अभी पढ़ रहे हैं';

  @override
  String get widgetNothing => 'अभी कुछ नहीं पढ़ रहे';

  @override
  String widgetOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबों की तारीख निकली',
      one: '1 किताब की तारीख निकली',
    );
    return '$_temp0';
  }

  @override
  String widgetLentOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count किताबें उधार दीं',
      one: '1 किताब उधार दी',
    );
    return '$_temp0';
  }

  @override
  String widgetAlsoReading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'और $count किताबें चल रही हैं',
      one: 'और 1 किताब चल रही है',
    );
    return '$_temp0';
  }

  @override
  String get settingsReportProblem => 'समस्या बताएँ';

  @override
  String get settingsReportProblemBody =>
      'डेवलपर को ईमेल करें, ऐप के हाल के संदेश साथ में जुड़े होंगे।';

  @override
  String get crashPromptTitle => 'कुछ गड़बड़ हो गई';

  @override
  String get crashPromptBody =>
      'पिछली बार इस्तेमाल करते समय Kitabkhana में कोई दिक्कत आई। इसे ठीक करने में मदद के लिए आप डेवलपर को रिपोर्ट ईमेल कर सकते हैं। पहले आपका मेल ऐप खुलेगा, ताकि भेजने से पहले आप सब देख सकें।';

  @override
  String get crashPromptScreenshot => 'स्क्रीनशॉट जोड़ें';

  @override
  String get crashPromptScreenshotHint =>
      'इसमें स्क्रीन पर दिख रहे किताबों के नाम आ सकते हैं।';

  @override
  String get crashPromptSend => 'रिपोर्ट ईमेल करें';

  @override
  String get crashPromptDismiss => 'अभी नहीं';

  @override
  String get reportSentMailLink =>
      'आपका मेल ऐप बिना अटैचमेंट के खुला; ब्योरा संदेश में है।';

  @override
  String get reportShared =>
      'कोई मेल ऐप नहीं मिला, इसलिए रिपोर्ट दूसरे तरीके से भेजी गई।';

  @override
  String get settingsHelp => 'मदद';

  @override
  String get settingsDiagnostics => 'जाँच-जानकारी निकालें';

  @override
  String get settingsDiagnosticsBody =>
      'वर्ज़न और ऐप के हाल के संदेश, आपकी लाइब्रेरी का कुछ भी नहीं।';

  @override
  String get settingsFeedback => 'सुझाव भेजें';

  @override
  String get settingsFeedbackSubject => 'Kitabkhana पर सुझाव';

  @override
  String get settingsAbout => 'जानकारी';

  @override
  String get aboutTitle => 'जानकारी';

  @override
  String aboutVersion(String version) {
    return 'वर्ज़न $version';
  }

  @override
  String get aboutLicenses => 'ओपन-सोर्स लाइसेंस';

  @override
  String get aboutPrivacyPolicy => 'निजता नीति';

  @override
  String get aboutTagline => 'आपकी अपनी, उधार दी और प्यारी किताबों का निजी घर।';

  @override
  String get aboutMadeWithCare => 'प्यार से बनाया';

  @override
  String get onboardingSkip => 'छोड़ें';

  @override
  String get onboardingNext => 'आगे';

  @override
  String onboardingStep(int current, int total) {
    return 'चरण $current / $total';
  }

  @override
  String get onboarding1Title => 'जानें आपके पास क्या है';

  @override
  String get onboarding1Body =>
      'हर किताब और हर अलमारी एक शांत जगह पर, उधार दी हुई किताबें भी।';

  @override
  String get onboarding2Title => 'दोबारा कभी न खरीदें';

  @override
  String get onboarding2Body =>
      'दुकान में बारकोड स्कैन करें, Kitabkhana तुरंत बताएगा कि वह आपकी अलमारी में पहले से है या नहीं।';

  @override
  String get onboarding3Title => 'आपकी किताबें आपके पास';

  @override
  String get onboarding3Body =>
      'न खाता, न साइन-अप, न ट्रैकिंग। आपकी लाइब्रेरी इसी डिवाइस पर रहती है, और बाहर जाए या नहीं, यह आप तय करते हैं।';

  @override
  String get onboardingPlacesTitle => 'आपकी किताबें कहाँ रहती हैं?';

  @override
  String get onboardingPlacesBody =>
      'शुरुआत के लिए कुछ जगहें चुनें। बाद में नाम बदल या और जोड़ सकते हैं।';

  @override
  String get onboardingPlacesUse => 'ये जगहें लें';

  @override
  String get onboardingPlacesSkip => 'अभी नहीं';

  @override
  String get onboardingReadyTitle => 'सब तैयार है';

  @override
  String get onboardingReadyBody =>
      'पहली किताब जोड़ें, बैकअप से अपनी लाइब्रेरी वापस लाएँ, या बस घूमकर देखें।';

  @override
  String get onboardingAddFirst => 'पहली किताब जोड़ें';

  @override
  String get onboardingRestore => 'बैकअप से वापस लाएँ';

  @override
  String get onboardingExplore => 'ऐप देखें';

  @override
  String bookTileByAuthor(String authors) {
    return 'लेखक $authors';
  }

  @override
  String bookTileAt(String place) {
    return '$place में';
  }

  @override
  String get devSeedStore => 'स्टोर का नमूना डेटा लोड करें (dev)';

  @override
  String get devSeedPerf => '5,000 किताबें डालें (dev)';

  @override
  String get devSeedPerfBusy => 'डाल रहे हैं…';

  @override
  String devSeedPerfDone(String summary) {
    return 'डाला गया: $summary';
  }

  @override
  String paceDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपकी रफ़्तार से लगभग $count दिन बाकी',
      one: 'आपकी रफ़्तार से लगभग 1 दिन बाकी',
    );
    return '$_temp0';
  }

  @override
  String paceFinishBy(String date) {
    return '$date तक पूरी';
  }

  @override
  String get progressReachedEnd => 'यह आखिरी पन्ना है!';

  @override
  String get progressMarkFinished => 'पढ़ ली के रूप में दर्ज करें';

  @override
  String detailPageInvalid(int max) {
    return '0 से $max तक कोई संख्या लिखें';
  }

  @override
  String get detailRateIt => 'रेटिंग दें?';

  @override
  String detailRateStar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सितारे दें',
      one: '1 सितारा दें',
    );
    return '$_temp0';
  }

  @override
  String get detailFinishedCelebration => 'पूरी हो गई! बहुत खूब।';

  @override
  String get detailChange => 'बदलें';

  @override
  String detailLentTo(String name, String since) {
    return '$since से $name को उधार दी';
  }

  @override
  String detailBorrowedFrom(String name, String since) {
    return '$since से $name से उधार ली';
  }

  @override
  String detailDue(String date) {
    return 'लौटाने की तारीख $date';
  }

  @override
  String get detailReturn => 'लौटी';

  @override
  String get detailReturned => 'लौटाई गई दर्ज की';

  @override
  String get detailEdit => 'बदलें';

  @override
  String get detailShare => 'भेजें';

  @override
  String get detailMore => 'और';

  @override
  String detailShareText(String title, String authors) {
    return '$title, लेखक $authors';
  }

  @override
  String detailShareTextNoAuthor(String title) {
    return '$title';
  }

  @override
  String get detailDeleteTitle => 'यह किताब हटाएँ?';

  @override
  String get detailDeleteBody =>
      'यह आपकी लाइब्रेरी से हट जाएगी। तुरंत बाद वापस ले सकते हैं।';

  @override
  String get detailSectionNotes => 'नोट्स';

  @override
  String get detailNotesHint => 'नोट लिखें';

  @override
  String get detailNotesSaved => 'नोट सहेजा गया';

  @override
  String get detailSectionTags => 'टैग';

  @override
  String get detailAddTag => 'टैग जोड़ें';

  @override
  String get detailTagHint => 'टैग का नाम';

  @override
  String detailRemoveTag(String name) {
    return 'टैग $name हटाएँ';
  }

  @override
  String get detailSectionDetails => 'ब्योरा';

  @override
  String get detailIsbn => 'ISBN';

  @override
  String get detailOwner => 'मालिक';

  @override
  String get detailAddedOn => 'जोड़ने की तारीख';

  @override
  String get detailStarted => 'शुरू की';

  @override
  String get detailFinished => 'पूरी की';

  @override
  String get detailBack => 'वापस';

  @override
  String detailPagesYear(int pages) {
    return '$pages पन्ने';
  }

  @override
  String get editBookTitle => 'किताब बदलें';

  @override
  String get bookSavedChanges => 'बदलाव सहेजे गए';

  @override
  String get detailMove => 'जगह बदलें';

  @override
  String get scanSearchHint => 'नाम से खोजें';

  @override
  String get scanTypeIsbn => 'ISBN लिखें';

  @override
  String get scanTorch => 'टॉर्च';

  @override
  String get scanSwitchCamera => 'कैमरा बदलें';

  @override
  String get scanPermTitle => 'Kitabkhana को कैमरा इस्तेमाल करने दें';

  @override
  String get scanPermBody =>
      'कैमरा सिर्फ़ इसी डिवाइस पर बारकोड पढ़ता है। कुछ रिकॉर्ड या अपलोड नहीं होता।';

  @override
  String get scanPermAllow => 'कैमरा चालू करें';

  @override
  String get scanDeniedTitle => 'कैमरा बंद है';

  @override
  String get scanDeniedBody =>
      'बिना कैमरे के भी आप नाम से खोज सकते हैं या ISBN लिख सकते हैं।';

  @override
  String get scanTryAgain => 'फिर कोशिश करें';

  @override
  String get scanBlockedTitle => 'कैमरे की अनुमति बंद है';

  @override
  String get scanBlockedBody =>
      'बारकोड स्कैन करने के लिए इसे सेटिंग्स में चालू करें। तब तक नाम से खोज सकते हैं।';

  @override
  String get scanOpenSettings => 'सेटिंग्स खोलें';

  @override
  String get scanNoCameraNote =>
      'यहाँ कैमरा नहीं है, इसलिए नाम से खोजें या ISBN लिखें।';

  @override
  String get scanWebHttpsNote =>
      'वेब पर कैमरे से स्कैन के लिए सुरक्षित (HTTPS) पेज चाहिए।';

  @override
  String get scanChecking => 'आपकी लाइब्रेरी देख रहे हैं…';

  @override
  String get verdictOwned => 'यह आपके पास है';

  @override
  String verdictOwnedWhere(String place) {
    return '$place पर';
  }

  @override
  String get verdictNoPlace => 'कोई जगह तय नहीं';

  @override
  String get verdictOtherEdition => 'आपके पास इसका दूसरा संस्करण है';

  @override
  String get verdictWishlist => 'आपकी इच्छा-सूची में';

  @override
  String get verdictMarkBought => 'खरीदी हुई दर्ज करें';

  @override
  String verdictLentTo(String name) {
    return '$name को उधार दी';
  }

  @override
  String verdictSince(String date) {
    return '$date से';
  }

  @override
  String verdictBorrowedFrom(String name) {
    return '$name से उधार ली';
  }

  @override
  String get verdictBorrowed => 'उधार ली';

  @override
  String get verdictDidYouMean => 'क्या आपका मतलब…?';

  @override
  String get verdictNoneOfThese => 'इनमें से कोई नहीं';

  @override
  String get verdictNotInLibrary => 'आपकी लाइब्रेरी में नहीं';

  @override
  String get verdictAddWishlist => 'इच्छा-सूची में जोड़ें';

  @override
  String get verdictBoughtIt => 'मैंने खरीद ली — लाइब्रेरी में जोड़ें';

  @override
  String get verdictOpenBook => 'किताब खोलें';

  @override
  String get verdictScanAnother => 'दूसरी स्कैन करें';

  @override
  String get verdictWishlistAdded => 'इच्छा-सूची में जोड़ी गई';

  @override
  String get verdictBoughtDone => 'खरीदी हुई दर्ज की';

  @override
  String verdictMatch(int percent) {
    return '$percent% मेल';
  }

  @override
  String get verdictUnknownTitle => 'अज्ञात नाम';

  @override
  String get scanSearchLabel => 'बारकोड नहीं है?';

  @override
  String get lendAction => 'उधार दें';

  @override
  String get lendSheetTitleLend => 'यह किताब उधार दें';

  @override
  String get lendSheetTitleBorrow => 'यह किताब उधार ली';

  @override
  String get lendToggleLend => 'उधार दें';

  @override
  String get lendToggleBorrow => 'उधार लें';

  @override
  String get lendPersonLent => 'किसे दी';

  @override
  String get lendPersonBorrowed => 'किससे ली';

  @override
  String get lendPhone => 'फ़ोन (वैकल्पिक)';

  @override
  String get lendPhoneHint => 'नंबर, दूसरा देश हो तो कोड के साथ';

  @override
  String get lendPhoneInvalid => 'यह फ़ोन नंबर नहीं लगता।';

  @override
  String get lendStarted => 'कब से';

  @override
  String get lendDue => 'लौटाने की तारीख';

  @override
  String get lendDueNone => 'कोई तारीख नहीं';

  @override
  String get lendDue1w => '1 हफ़्ता';

  @override
  String get lendDue2w => '2 हफ़्ते';

  @override
  String get lendDue1m => '1 महीना';

  @override
  String get lendDueCustom => 'तारीख चुनें';

  @override
  String get lendNote => 'नोट (वैकल्पिक)';

  @override
  String get lendSave => 'सहेजें';

  @override
  String get lendNameRequired => 'किताब किसके पास है?';

  @override
  String lendSaved(String name) {
    return '$name को उधार दी';
  }

  @override
  String lendSavedBorrow(String name) {
    return '$name से उधार ली';
  }

  @override
  String get returnPickLocationTitle => 'इसे वापस कहाँ रखें?';

  @override
  String get returnPickLocationBody =>
      'इसकी पुरानी जगह हटा दी गई है। नई चुनें।';

  @override
  String returnBorrowedTitle(String name) {
    return '$name को लौटाई';
  }

  @override
  String get returnBorrowedRemove => 'मेरी लाइब्रेरी से हटाएँ';

  @override
  String get returnBorrowedKeep => 'इच्छा-सूची में रखें';

  @override
  String get failureNeedsName => 'उस व्यक्ति का नाम लिखें।';

  @override
  String get reminderChannelName => 'उधार की याद';

  @override
  String get reminderChannelDesc =>
      'उधार दी या ली किताब लौटाने की तारीख पर याद';

  @override
  String reminderDueTitle(String book) {
    return '“$book” आज लौटानी है';
  }

  @override
  String reminderLentDueBody(String name) {
    return '$name के पास है। प्यार से याद दिलाएँ?';
  }

  @override
  String reminderBorrowedDueBody(String name) {
    return '$name को लौटाने का समय है।';
  }

  @override
  String reminderOverdueTitle(String book) {
    return '“$book” की तारीख निकल गई';
  }

  @override
  String reminderLentOverdueBody(String name) {
    return '$name के पास अब भी है। याद दिलाएँ?';
  }

  @override
  String reminderBorrowedOverdueBody(String name) {
    return 'जल्द ही $name को लौटा दें।';
  }

  @override
  String get reminderPermTitle => 'तारीख पर याद दिलाएँ?';

  @override
  String get reminderPermBody =>
      'Kitabkhana किताब लौटाने के दिन आपको याद दिला सकता है। याद इसी डिवाइस पर रहती है।';

  @override
  String get reminderPermAllow => 'सूचनाएँ चालू करें';

  @override
  String get reminderPermLater => 'अभी नहीं';

  @override
  String nudgeMessage(String name, String book) {
    return 'नमस्ते $name! 📚 पढ़ लेने के बाद क्या “$book” लौटा देंगे? धन्यवाद!';
  }

  @override
  String get nudgeWhatsApp => 'WhatsApp पर याद दिलाएँ';

  @override
  String get nudgeSms => 'SMS भेजें';

  @override
  String get nudgeNoPhone => 'याद दिलाने के लिए फ़ोन नंबर जोड़ें।';

  @override
  String get nudgeFailed => 'कोई मैसेज ऐप नहीं खुल सका।';

  @override
  String get overdueBannerOne => '1 किताब की तारीख निकल गई है';

  @override
  String overdueBannerMany(int count) {
    return '$count किताबों की तारीख निकल गई है';
  }

  @override
  String get devTestReminder => 'परीक्षण याद लगाएँ (2 मिनट)';

  @override
  String get devTestReminderSet => 'परीक्षण याद 2 मिनट बाद के लिए लगी';

  @override
  String get detailRemind => 'याद दिलाएँ';

  @override
  String get loansTitle => 'उधार';

  @override
  String get loansTabLent => 'उधार दी';

  @override
  String get loansTabBorrowed => 'उधार ली';

  @override
  String get loansTabOverdue => 'तारीख निकली';

  @override
  String get loansTabHistory => 'इतिहास';

  @override
  String get loansEmptyLent => 'सबने आपकी किताबें लौटा दी हैं। बढ़िया।';

  @override
  String get loansEmptyBorrowed => 'अभी आपने कोई किताब उधार नहीं ली है।';

  @override
  String get loansEmptyOverdue => 'किसी की तारीख नहीं निकली। बहुत अच्छे।';

  @override
  String get loansEmptyHistory => 'लौटाई गई किताबें यहाँ दिखेंगी।';

  @override
  String loanSince(String date) {
    return '$date से';
  }

  @override
  String loanDueOn(String date) {
    return '$date तक लौटानी';
  }

  @override
  String get loanDueToday => 'आज लौटानी है';

  @override
  String loanDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन में लौटानी है',
      one: 'कल लौटानी है',
    );
    return '$_temp0';
  }

  @override
  String loanOverdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन देर',
      one: '1 दिन देर',
    );
    return '$_temp0';
  }

  @override
  String get loanNoDue => 'कोई तारीख नहीं';

  @override
  String loanReturnedOn(String date) {
    return '$date को लौटी';
  }

  @override
  String get loanActionReturn => 'लौटी';

  @override
  String get loanActionExtend => 'समय बढ़ाएँ';

  @override
  String get loanReturnedToast => 'लौटाई गई दर्ज की';

  @override
  String get extendTitle => 'लौटाने की तारीख बढ़ाएँ';

  @override
  String get extend1w => '+1 हफ़्ता';

  @override
  String get extend2w => '+2 हफ़्ते';

  @override
  String get extend1m => '+1 महीना';

  @override
  String extendDone(String date) {
    return 'अब $date तक';
  }

  @override
  String get loansOpenTooltip => 'उधार';
}

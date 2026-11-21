/// Route paths, in one place.
abstract final class Routes {
  static const library = '/library';
  static const libraryAdd = '/library/add';
  static const libraryAddScan = '/library/add/scan';
  static const libraryAddIsbn = '/library/add/isbn';
  static const libraryAddSearch = '/library/add/search';
  static const libraryAddManual = '/library/add/manual';
  static const libraryAddPreview = '/library/add/preview';
  static const scan = '/scan';
  static const reading = '/reading';
  static const stats = '/stats';
  static const more = '/more';
  static const loans = '/loans';
  static const quotes = '/quotes';
  static const locations = '/locations';
  static const settings = '/settings';
  static const tags = '/tags';
  static const about = '/about';
  static const onboarding = '/onboarding';
  static const devGallery = '/dev/gallery';
  static const devLookup = '/dev/lookup';

  static String book(String id) => '/book/$id';
  static String bookEdit(String id) => '/book/$id/edit';
  static String quoteCapture(String bookId) => '/book/$bookId/quote';
}

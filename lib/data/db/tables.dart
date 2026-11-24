import 'package:drift/drift.dart';

import '../../core/uuid.dart';
import '../../features/lending/domain/loan_direction.dart';
import '../../features/library/domain/book_enums.dart';
import 'converters.dart';

/// Columns shared by every synced table: UUIDv7 text id, timestamps, soft
/// delete marker and a revision counter. Repositories set `updatedAt` from the
/// app `Clock` and bump `rev` on every write.
mixin SyncColumns on Table {
  TextColumn get id => text().clientDefault(uuidV7)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get rev => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BookRow')
class Books extends Table with SyncColumns {
  TextColumn get isbn13 => text().nullable()();
  TextColumn get olWorkKey => text().nullable()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get authors => text().withDefault(const Constant(''))();
  TextColumn get titleKey => text()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get coverLocalPath => text().nullable()();
  IntColumn get pages => integer().nullable()();
  TextColumn get genre => text().withDefault(const Constant(''))();
  TextColumn get language => text().withDefault(const Constant(''))();
  TextColumn get ownership =>
      textEnum<Ownership>().withDefault(Constant(Ownership.owned.name))();
  TextColumn get status =>
      textEnum<ReadStatus>().withDefault(Constant(ReadStatus.want.name))();
  IntColumn get currentPage => integer().withDefault(const Constant(0))();
  IntColumn get rating => integer().nullable()();
  TextColumn get locationId => text().nullable().references(
    Locations,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get ownerName => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get startedOn =>
      text().map(const DateOnlyConverter()).nullable()();
  TextColumn get finishedOn =>
      text().map(const DateOnlyConverter()).nullable()();

  /// v3: the series the book belongs to ("Discworld") and its place in it
  /// (2, or 2.5 for a novella between books).
  TextColumn get series => text().nullable()();
  RealColumn get seriesNumber => real().nullable()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK (pages IS NULL OR pages > 0)',
    'CHECK (current_page >= 0)',
    'CHECK (rating IS NULL OR (rating BETWEEN 1 AND 5))',
    "CHECK (ownership IN ('owned', 'wishlist', 'borrowed'))",
    "CHECK (status IN ('want', 'reading', 'finished', 'dropped'))",
  ];
}

@DataClassName('LocationRow')
class Locations extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable().references(
    Locations,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get icon => text().nullable()();
}

@DataClassName('LoanRow')
class Loans extends Table with SyncColumns {
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get direction => textEnum<LoanDirection>()();
  TextColumn get personName => text()();
  TextColumn get personPhone => text().nullable()();
  TextColumn get startedOn => text().map(const DateOnlyConverter())();
  TextColumn get dueOn => text().map(const DateOnlyConverter()).nullable()();
  TextColumn get returnedOn =>
      text().map(const DateOnlyConverter()).nullable()();
  TextColumn get previousLocationId => text().nullable().references(
    Locations,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get note => text().nullable()();

  @override
  List<String> get customConstraints => <String>[
    "CHECK (direction IN ('lent', 'borrowed'))",
  ];
}

@DataClassName('ReadingLogRow')
class ReadingLogs extends Table with SyncColumns {
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get date => text().map(const DateOnlyConverter())();
  IntColumn get pagesRead => integer()();
  IntColumn get fromPage => integer()();
  IntColumn get toPage => integer()();

  @override
  List<String> get customConstraints => <String>['CHECK (pages_read > 0)'];
}

/// v3: time spent reading one book on one day, from the reading timer.
@DataClassName('ReadingSessionRow')
class ReadingSessions extends Table with SyncColumns {
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get date => text().map(const DateOnlyConverter())();
  IntColumn get minutes => integer()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK (minutes > 0 AND minutes <= 1440)',
  ];
}

/// v3: an earlier read of a book that is being read again. The current read
/// stays on the book (`startedOn` / `finishedOn`).
@DataClassName('ReadThroughRow')
class ReadThroughs extends Table with SyncColumns {
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get startedOn =>
      text().map(const DateOnlyConverter()).nullable()();
  TextColumn get finishedOn =>
      text().map(const DateOnlyConverter()).nullable()();
}

@DataClassName('QuoteRow')
class Quotes extends Table with SyncColumns {
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get body => text()();
  IntColumn get page => integer().nullable()();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
}

@DataClassName('GoalRow')
class Goals extends Table with SyncColumns {
  IntColumn get year => integer()();
  IntColumn get targetBooks => integer()();

  @override
  List<String> get customConstraints => <String>['CHECK (target_books > 0)'];
}

@DataClassName('TagRow')
class Tags extends Table with SyncColumns {
  TextColumn get name => text()();
}

@DataClassName('BookTagRow')
class BookTags extends Table with SyncColumns {
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get tagId => text().references(Tags, #id)();
}

/// Processed cover images on platforms without a file system (web). Device
/// local, not synced. Rows disappear with their book.
@DataClassName('CoverBlobRow')
class CoverBlobs extends Table {
  TextColumn get bookId =>
      text().references(Books, #id, onDelete: KeyAction.cascade)();
  BlobColumn get bytes => blob()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {bookId};
}

/// Device-local cache of Open Library lookups. Not synced or backed up.
@DataClassName('LookupCacheRow')
class LookupCache extends Table {
  TextColumn get key => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  BoolColumn get isNotFound => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Device-local key/value settings. Not synced.
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

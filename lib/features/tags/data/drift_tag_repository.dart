import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../core/uuid.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/db_guard.dart';
import '../../../data/db/sync_sql.dart';
import '../domain/tag.dart';
import '../domain/tag_repository.dart';

Tag _toDomain(TagRow r) => Tag(
  id: r.id,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  rev: r.rev,
  name: r.name,
);

class DriftTagRepository implements TagRepository {
  DriftTagRepository(this._db, this._clock, {String Function()? newId})
    : _newId = newId ?? uuidV7;

  final AppDatabase _db;
  final Clock _clock;
  final String Function() _newId;

  @override
  Stream<List<Tag>> watchAll() {
    final q = _db.liveTags()
      ..orderBy([
        (t) => OrderingTerm.asc(t.name.collate(Collate.noCase)),
        (t) => OrderingTerm.asc(t.id),
      ]);
    return q.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<Tag>> watchForBook(String bookId) {
    final links = _db.bookTags;
    final query =
        _db.select(_db.tags).join([
            innerJoin(links, links.tagId.equalsExp(_db.tags.id)),
          ])
          ..where(
            _db.tags.deletedAt.isNull() &
                links.deletedAt.isNull() &
                links.bookId.equals(bookId),
          )
          ..orderBy([
            OrderingTerm.asc(_db.tags.name.collate(Collate.noCase)),
            OrderingTerm.asc(_db.tags.id),
          ]);
    return query.watch().map(
      (rows) => rows.map((r) => _toDomain(r.readTable(_db.tags))).toList(),
    );
  }

  @override
  Future<Result<Tag>> createIfAbsent(String name) => dbGuard(
    () => _db.transaction(() async {
      final clean = name.trim();
      if (clean.isEmpty) {
        throw const FailureException(
          ValidationFailure(field: 'name', messageKey: 'failureValidation'),
        );
      }
      final wanted = clean.toLowerCase();
      final all = await _db.liveTags().get();
      for (final t in all) {
        if (t.name.trim().toLowerCase() == wanted) return _toDomain(t);
      }
      final now = _clock.now();
      final id = _newId();
      await _db
          .into(_db.tags)
          .insert(
            TagsCompanion.insert(
              id: Value(id),
              name: clean,
              createdAt: now,
              updatedAt: now,
            ),
          );
      final saved = await (_db.select(
        _db.tags,
      )..where((t) => t.id.equals(id))).getSingle();
      return _toDomain(saved);
    }),
  );

  @override
  Future<Result<void>> attach(String bookId, String tagId) => dbGuard(
    () => _db.transaction(() async {
      final book = await (_db.liveBooks()..where((t) => t.id.equals(bookId)))
          .getSingleOrNull();
      if (book == null) {
        throw const FailureException(NotFoundFailure('book'));
      }
      final tag = await (_db.liveTags()..where((t) => t.id.equals(tagId)))
          .getSingleOrNull();
      if (tag == null) throw const FailureException(NotFoundFailure('tag'));
      final existing =
          await (_db.select(_db.bookTags)..where(
                (t) =>
                    t.deletedAt.isNull() &
                    t.bookId.equals(bookId) &
                    t.tagId.equals(tagId),
              ))
              .getSingleOrNull();
      if (existing != null) return;
      final now = _clock.now();
      await _db
          .into(_db.bookTags)
          .insert(
            BookTagsCompanion.insert(
              id: Value(_newId()),
              bookId: bookId,
              tagId: tagId,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }),
  );

  @override
  Future<Result<void>> detach(String bookId, String tagId) => dbGuard(() async {
    await _db.customUpdate(
      'UPDATE book_tags SET deleted_at = ?1, updated_at = ?1, '
      'rev = rev + 1 WHERE book_id = ?2 AND tag_id = ?3 '
      'AND deleted_at IS NULL',
      variables: [
        Variable<DateTime>(_clock.now()),
        Variable<String>(bookId),
        Variable<String>(tagId),
      ],
      updates: {_db.bookTags},
      updateKind: UpdateKind.update,
    );
  });

  @override
  Future<Result<void>> softDelete(String tagId) => dbGuard(
    () => _db.transaction(() async {
      final now = _clock.now();
      await _db.customUpdate(
        'UPDATE book_tags SET deleted_at = ?1, updated_at = ?1, '
        'rev = rev + 1 WHERE tag_id = ?2 AND deleted_at IS NULL',
        variables: [Variable<DateTime>(now), Variable<String>(tagId)],
        updates: {_db.bookTags},
        updateKind: UpdateKind.update,
      );
      final n = await softDeleteById(_db, table: _db.tags, id: tagId, now: now);
      if (n == 0) throw const FailureException(NotFoundFailure('tag'));
    }),
  );
}

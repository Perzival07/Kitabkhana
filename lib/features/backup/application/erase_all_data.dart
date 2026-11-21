import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../data/db/app_database.dart';
import '../../../platform/cover_store/cover_store.dart';
import '../../reminders/domain/notification_scheduler.dart';
import '../data/backup_store.dart';
import 'auto_backup.dart';

/// The word the reader must type to confirm erasing everything.
const String eraseConfirmWord = 'DELETE';

/// Whether [typed] confirms an erase (exact, case-sensitive; surrounding
/// spaces are ignored).
bool isEraseConfirmed(String typed) => typed.trim() == eraseConfirmWord;

/// Wipes the whole app: every table (settings included), cover images,
/// backups on the device and pending notifications. Afterwards the app is as
/// it was on first launch.
class EraseAllData {
  EraseAllData({
    required this.db,
    required this.store,
    required this.covers,
    required this.folder,
    required this.notifications,
  });

  final AppDatabase db;
  final BackupStore store;
  final CoverStore covers;
  final BackupFolder folder;
  final NotificationScheduler notifications;

  Future<Result<void>> call() async {
    try {
      final bookIds = await store.allBookIds();

      // Database first: if this fails nothing else has been touched.
      await db.transaction(() async {
        await db.customStatement('PRAGMA defer_foreign_keys = ON');
        // Children before parents. (The search index follows the books by
        // trigger, so it is not listed.)
        await db.delete(db.bookTags).go();
        await db.delete(db.quotes).go();
        await db.delete(db.readingLogs).go();
        await db.delete(db.loans).go();
        await db.delete(db.coverBlobs).go();
        await db.delete(db.books).go();
        await db.delete(db.tags).go();
        await db.delete(db.goals).go();
        await db.delete(db.locations).go();
        await db.delete(db.lookupCache).go();
        await db.delete(db.appMeta).go();
      });

      for (final id in bookIds) {
        try {
          await covers.delete(id);
        } on Object {
          // A missing file is fine.
        }
      }
      await folder.deleteAll();
      if (notifications.supported) {
        for (final id in await notifications.pendingIds()) {
          await notifications.cancel(id);
        }
      }
      return const Ok<void>(null);
    } on Object catch (e, s) {
      return Err(UnexpectedFailure(e, s));
    }
  }
}

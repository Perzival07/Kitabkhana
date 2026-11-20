import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/book/application/book_progress.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';

void main() {
  final today = DateTime(2025, 3, 10);
  Book book({int? pages = 300}) =>
      Book.create(id: 'b', title: 'Dune', now: DateTime(2025), pages: pages);

  test('reading stamps startedOn once', () {
    final b = withStatus(book(), ReadStatus.reading, today);
    expect(b.startedOn, today);
    expect(b.finishedOn, isNull);
    final again = withStatus(
      b.copyWith(status: ReadStatus.want),
      ReadStatus.reading,
      DateTime(2026),
    );
    expect(again.startedOn, today, reason: 'kept, not overwritten');
  });

  test('finished stamps finishedOn and sets currentPage to pages', () {
    final b = withStatus(
      book().copyWith(status: ReadStatus.reading, currentPage: 40),
      ReadStatus.finished,
      today,
    );
    expect(b.finishedOn, today);
    expect(b.currentPage, 300);
    expect(b.startedOn, today);
  });

  test('finished with unknown pages keeps the current page', () {
    final b = withStatus(
      book(pages: null).copyWith(status: ReadStatus.reading, currentPage: 40),
      ReadStatus.finished,
      today,
    );
    expect(b.currentPage, 40);
  });

  test('going back to reading clears the finish date', () {
    final done = withStatus(book(), ReadStatus.finished, today);
    final back = withStatus(done, ReadStatus.reading, DateTime(2025, 4));
    expect(back.finishedOn, isNull);
    expect(back.startedOn, today);
  });

  test('want and dropped leave dates alone', () {
    final r = withStatus(book(), ReadStatus.reading, today);
    final d = withStatus(r, ReadStatus.dropped, DateTime(2025, 5));
    expect(d.startedOn, today);
    expect(d.status, ReadStatus.dropped);
  });

  test('withPage clamps to 0..pages', () {
    expect(withPage(book(), 120).currentPage, 120);
    expect(withPage(book(), 999).currentPage, 300);
    expect(withPage(book(), -5).currentPage, 0);
    expect(withPage(book(pages: null), 999).currentPage, 999);
  });
}

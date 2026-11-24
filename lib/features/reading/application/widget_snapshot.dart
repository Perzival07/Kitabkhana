import '../../../l10n/app_localizations.dart';
import '../../../platform/home_widget/home_screen_widget.dart';
import '../../library/domain/book.dart';

/// The home-screen widget's text: the book being read (most recently read
/// first) with its page and progress, and the loans.
WidgetSnapshot buildWidgetSnapshot(
  AppLocalizations l10n, {
  required List<Book> reading,
  required int lentOut,
  required int overdue,
}) {
  final footer = overdue > 0
      ? l10n.widgetOverdue(overdue)
      : lentOut > 0
      ? l10n.widgetLentOut(lentOut)
      : '';
  if (reading.isEmpty) {
    return WidgetSnapshot(
      label: l10n.widgetLabel,
      title: l10n.widgetNothing,
      subtitle: l10n.readingPickNext,
      footer: footer,
    );
  }
  final b = reading.first;
  final pages = b.pages;
  final progress = b.progress;
  final page = pages == null
      ? '${l10n.detailPageLabel} ${b.currentPage}'
      : l10n.readingPageOf(b.currentPage, pages);
  return WidgetSnapshot(
    label: l10n.widgetLabel,
    title: b.title,
    subtitle: b.authors.isEmpty ? page : '${b.authors} · $page',
    progress: progress == null ? null : (progress * 100).round(),
    footer: reading.length > 1 && footer.isEmpty
        ? l10n.widgetAlsoReading(reading.length - 1)
        : footer,
  );
}

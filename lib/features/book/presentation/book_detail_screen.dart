import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/add_book_providers.dart';
import '../../../app/book_detail_providers.dart';
import '../../../app/l10n/failure_message.dart';
import '../../../app/providers.dart';
import '../../../app/repositories.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/k_tokens.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../lending/domain/loan.dart';
import '../../lending/presentation/lend_sheet.dart';
import '../../lending/presentation/return_flow.dart';
import '../../lending/domain/loan_direction.dart';
import '../../library/domain/book.dart';
import '../../library/domain/book_enums.dart';
import '../../library/presentation/book_cover_view.dart';
import '../../library/presentation/widgets/book_tiles.dart';
import '../../locations/domain/location.dart';
import '../../tags/domain/tag.dart';
import '../../locations/presentation/location_name.dart';
import '../../locations/presentation/location_picker.dart';
import '../application/book_progress.dart';
import 'widgets/celebration.dart';
import 'widgets/update_page_sheet.dart';

/// A book's page: header, status, progress, location or loan, actions, notes,
/// tags and details. With [embedded] (the right pane on wide screens) it has
/// no back button and reports deletion through [onClosed].
class BookDetailScreen extends ConsumerStatefulWidget {
  const BookDetailScreen({
    required this.bookId,
    this.embedded = false,
    this.onClosed,
    super.key,
  });

  final String bookId;
  final bool embedded;
  final VoidCallback? onClosed;

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  int _celebrate = 0;

  void _toastError(Failure failure) {
    final l10n = AppLocalizations.of(context);
    KToast.showWith(
      ScaffoldMessenger.of(context),
      failureMessage(l10n, failure),
      icon: Icons.error_outline_rounded,
    );
  }

  Future<void> _change(Book Function(Book) change) async {
    final r = await ref
        .read(bookRepositoryProvider)
        .update(widget.bookId, change);
    if (r case Err<Book>(:final failure) when mounted) _toastError(failure);
  }

  Future<void> _setStatus(Book book, ReadStatus status) async {
    if (status == book.status) return;
    final today = ref.read(clockProvider).today();
    final wasFinished = book.status == ReadStatus.finished;
    await _change((b) => withStatus(b, status, today));
    if (status == ReadStatus.finished && !wasFinished && mounted) {
      unawaited(HapticFeedback.mediumImpact());
      setState(() => _celebrate++);
    }
  }

  Future<void> _updatePage(Book book) async {
    final page = await showUpdatePageSheet(
      context,
      current: book.currentPage,
      pages: book.pages,
    );
    if (page == null) return;
    await _change((b) => withPage(b, page));
  }

  Future<void> _move(Book book) async {
    final pick = await showLocationPicker(context, selectedId: book.locationId);
    if (pick == null) return;
    await _change((b) => b.copyWith(locationId: pick.id));
  }

  Future<void> _return(Loan loan) async {
    final done = await returnLoanFlow(context, ref, loan);
    // A borrowed book that was removed leaves this page.
    if (done && loan.direction == LoanDirection.borrowed && mounted) {
      final stillThere = ref.read(bookByIdProvider(widget.bookId)).value;
      if (stillThere == null) _leave();
    }
  }

  Future<void> _lend(Book book) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final loan = await showLendSheet(context, book: book);
    if (loan == null) return;
    KToast.showWith(
      messenger,
      loan.direction == LoanDirection.lent
          ? l10n.lendSaved(loan.personName)
          : l10n.lendSavedBorrow(loan.personName),
    );
  }

  Future<void> _share(Book book) async {
    final l10n = AppLocalizations.of(context);
    final text = book.authors.isEmpty
        ? l10n.detailShareTextNoAuthor(book.title)
        : l10n.detailShareText(book.title, book.authors);
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _delete(Book book) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showKConfirmDialog(
      context: context,
      title: l10n.detailDeleteTitle,
      message: l10n.detailDeleteBody,
      confirmLabel: l10n.quickDelete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final repo = ref.read(bookRepositoryProvider);
    final r = await repo.softDelete(book.id);
    if (!mounted) return;
    switch (r) {
      case Ok<void>():
        KToast.showWith(
          messenger,
          l10n.bookDeleted(book.title),
          icon: Icons.delete_outline_rounded,
          actionLabel: l10n.undo,
          onAction: () => repo.restore(book.id),
        );
        _leave();
      case Err<void>(:final failure):
        _toastError(failure);
    }
  }

  void _leave() {
    if (widget.embedded) {
      widget.onClosed?.call();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(Routes.library);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(bookByIdProvider(widget.bookId));
    final book = async.value;

    if (book == null) {
      return Scaffold(
        appBar: widget.embedded
            ? null
            : AppBar(leading: _BackButton(onPressed: _leave)),
        body: async.isLoading
            ? const KPageSkeleton()
            : KEmptyState(
                illustration: KIllustration.openBook,
                title: l10n.bookNotFound,
                actionLabel: widget.embedded ? null : l10n.goToLibrary,
                onAction: widget.embedded ? null : _leave,
              ),
      );
    }

    final loan = ref.watch(activeLoanForProvider(book.id)).value;
    final locations = ref.watch(locationsProvider).value ?? const <Location>[];
    final tags = ref.watch(bookTagsProvider(book.id)).value ?? const <Tag>[];
    Location? place;
    for (final loc in locations) {
      if (loc.id == book.locationId) place = loc;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: widget.embedded ? null : _BackButton(onPressed: _leave),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: l10n.detailMore,
            iconColor: Colors.white,
            onSelected: (v) {
              if (v == 'delete') _delete(book);
            },
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'delete',
                child: Text(l10n.quickDelete),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _Header(book: book, hero: !widget.embedded),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KSpacing.screen,
                      KSpacing.lg,
                      KSpacing.screen,
                      KSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _StatusRow(
                          book: book,
                          onStatus: (s) => _setStatus(book, s),
                          onRate: (n) => _change(
                            (b) => b.copyWith(rating: b.rating == n ? null : n),
                          ),
                        ),
                        if (book.status == ReadStatus.reading) ...<Widget>[
                          const SizedBox(height: KSpacing.lg),
                          _ProgressCard(
                            book: book,
                            onUpdate: () => _updatePage(book),
                          ),
                        ],
                        const SizedBox(height: KSpacing.lg),
                        _PlaceCard(
                          place: place,
                          all: locations,
                          loan: loan,
                          onChange: () => _move(book),
                          onReturn: loan == null ? null : () => _return(loan),
                        ),
                        const SizedBox(height: KSpacing.lg),
                        _ActionsRow(
                          onLend: loan == null ? () => _lend(book) : null,
                          onMove: () => _move(book),
                          onEdit: () => context.push(Routes.bookEdit(book.id)),
                          onShare: () => _share(book),
                        ),
                        const SizedBox(height: KSpacing.xl),
                        _NotesSection(
                          // A new key per book keeps the field in step when
                          // the two-pane view switches books.
                          key: ValueKey<String>('notes-${book.id}'),
                          notes: book.notes ?? '',
                          onSave: (text) => _change(
                            (b) => b.copyWith(
                              notes: text.trim().isEmpty ? null : text.trim(),
                            ),
                          ),
                        ),
                        const SizedBox(height: KSpacing.xl),
                        _TagsSection(bookId: book.id, tags: tags),
                        const SizedBox(height: KSpacing.xl),
                        _DetailsSection(book: book, loan: loan),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(child: CelebrationBurst(play: _celebrate)),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).detailBack,
    icon: const Icon(Icons.arrow_back_rounded),
    onPressed: onPressed,
  );
}

/// Blurred, darkened cover as a backdrop, with the hero cover and titles.
class _Header extends StatelessWidget {
  const _Header({required this.book, required this.hero});

  final Book book;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight;
    final pages = book.pages;
    final facts = <String>[if (pages != null) l10n.pagesCount(pages)];
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Transform.scale(
                scale: 2.2,
                child: ExcludeSemantics(child: BookCoverView(book: book)),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.5),
                  theme.scaffoldBackgroundColor,
                ],
                stops: const <double>[0, 0.88, 1],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            KSpacing.screen,
            top + KSpacing.sm,
            KSpacing.screen,
            KSpacing.xxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: <Widget>[
                  BookCoverView(
                    book: book,
                    size: KCoverSize.hero,
                    heroTag: hero ? bookHeroTag(book.id) : null,
                  ),
                  const SizedBox(height: KSpacing.lg),
                  Text(
                    book.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  if ((book.subtitle ?? '').isNotEmpty) ...<Widget>[
                    const SizedBox(height: KSpacing.xs),
                    Text(
                      book.subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  if (book.authors.isNotEmpty) ...<Widget>[
                    const SizedBox(height: KSpacing.sm),
                    Text(
                      book.authors,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (facts.isNotEmpty) ...<Widget>[
                    const SizedBox(height: KSpacing.xs),
                    Text(
                      facts.join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.book,
    required this.onStatus,
    required this.onRate,
  });

  final Book book;
  final ValueChanged<ReadStatus> onStatus;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: KSpacing.sm,
          runSpacing: KSpacing.sm,
          children: <Widget>[
            for (final s in ReadStatus.values)
              ChoiceChip(
                label: Text(statusLabel(l10n, s)),
                selected: book.status == s,
                onSelected: (_) => onStatus(s),
              ),
          ],
        ),
        if (book.status == ReadStatus.finished) ...<Widget>[
          const SizedBox(height: KSpacing.md),
          if (book.rating == null)
            Text(l10n.detailRateIt, style: theme.textTheme.labelLarge),
          Row(
            children: <Widget>[
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: l10n.detailRateStar(i),
                  isSelected: (book.rating ?? 0) >= i,
                  icon: const Icon(Icons.star_border_rounded),
                  selectedIcon: Icon(
                    Icons.star_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => onRate(i),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.book, required this.onUpdate});

  final Book book;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pages = book.pages;
    final progress = book.progress ?? 0;
    final text = pages == null
        ? '${l10n.detailPageLabel} ${book.currentPage}'
        : l10n.detailPageOf(book.currentPage, pages);
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(text, style: theme.textTheme.titleMedium)),
              if (pages != null)
                Text(
                  l10n.detailPercentRead((progress * 100).round()),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          if (pages != null) ...<Widget>[
            const SizedBox(height: KSpacing.sm),
            KProgressBar(value: progress),
          ],
          const SizedBox(height: KSpacing.md),
          KButton(
            label: l10n.detailUpdatePage,
            icon: Icons.edit_outlined,
            variant: KButtonVariant.tonal,
            onPressed: onUpdate,
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.all,
    required this.loan,
    required this.onChange,
    required this.onReturn,
  });

  final Location? place;
  final List<Location> all;
  final Loan? loan;
  final VoidCallback onChange;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final loan = this.loan;
    if (loan != null) {
      final fmt = DateFormat.MMMd(Localizations.localeOf(context).toString());
      final since = fmt.format(loan.startedOn);
      final base = loan.direction == LoanDirection.lent
          ? l10n.detailLentTo(loan.personName, since)
          : l10n.detailBorrowedFrom(loan.personName, since);
      final due = loan.dueOn == null
          ? ''
          : ' · ${l10n.detailDue(fmt.format(loan.dueOn!))}';
      return KCard(
        child: Row(
          children: <Widget>[
            Icon(Icons.swap_horiz_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: KSpacing.md),
            Expanded(child: Text('$base$due')),
            if (onReturn != null)
              TextButton(onPressed: onReturn, child: Text(l10n.detailReturn)),
          ],
        ),
      );
    }
    final label = place == null ? l10n.noLocation : locationPath(place!, all);
    return KCard(
      child: Row(
        children: <Widget>[
          Icon(Icons.place_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: KSpacing.md),
          Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
          TextButton(onPressed: onChange, child: Text(l10n.detailChange)),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.onLend,
    required this.onMove,
    required this.onEdit,
    required this.onShare,
  });

  final VoidCallback? onLend;
  final VoidCallback onMove;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget action(IconData icon, String label, VoidCallback? onTap) => Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(KRadii.button),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: KSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon),
              const SizedBox(height: KSpacing.xs),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
    return Row(
      children: <Widget>[
        if (onLend != null)
          action(Icons.swap_horiz_rounded, l10n.lendAction, onLend),
        action(Icons.place_outlined, l10n.detailMove, onMove),
        action(Icons.edit_outlined, l10n.detailEdit, onEdit),
        action(Icons.ios_share_rounded, l10n.detailShare, onShare),
      ],
    );
  }
}

class _NotesSection extends StatefulWidget {
  const _NotesSection({required this.notes, required this.onSave, super.key});

  final String notes;
  final ValueChanged<String> onSave;

  @override
  State<_NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<_NotesSection> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.notes,
  );
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(_NotesSection old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && widget.notes != _controller.text) {
      _controller.text = widget.notes;
    }
  }

  void _commit() {
    if (_controller.text.trim() != widget.notes.trim()) {
      widget.onSave(_controller.text);
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.detailSectionNotes,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: KSpacing.sm),
        TextField(
          controller: _controller,
          focusNode: _focus,
          minLines: 2,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          onTapOutside: (_) => _focus.unfocus(),
          decoration: InputDecoration(hintText: l10n.detailNotesHint),
        ),
      ],
    );
  }
}

class _TagsSection extends ConsumerWidget {
  const _TagsSection({required this.bookId, required this.tags});

  final String bookId;
  final List<Tag> tags;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = await showKBottomSheet<String>(
      context: context,
      builder: (_) => const _TagNameBody(),
    );
    if (name == null || name.trim().isEmpty) return;
    final tagsRepo = ref.read(tagRepositoryProvider);
    final created = await tagsRepo.createIfAbsent(name.trim());
    if (created case Ok(:final value)) {
      await tagsRepo.attach(bookId, value.id);
    } else if (created case Err(:final failure) when context.mounted) {
      KToast.showWith(
        ScaffoldMessenger.of(context),
        failureMessage(l10n, failure),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.detailSectionTags,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: KSpacing.sm),
        Wrap(
          spacing: KSpacing.sm,
          runSpacing: KSpacing.sm,
          children: <Widget>[
            for (final t in tags)
              InputChip(
                label: Text(t.name),
                deleteButtonTooltipMessage: l10n.detailRemoveTag(t.name),
                onDeleted: () =>
                    ref.read(tagRepositoryProvider).detach(bookId, t.id),
              ),
            ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.detailAddTag),
              onPressed: () => _add(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}

class _TagNameBody extends StatefulWidget {
  const _TagNameBody();

  @override
  State<_TagNameBody> createState() => _TagNameBodyState();
}

class _TagNameBodyState extends State<_TagNameBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.detailAddTag, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: KSpacing.lg),
        TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (v) => Navigator.of(context).pop(v),
          decoration: InputDecoration(labelText: l10n.detailTagHint),
        ),
        const SizedBox(height: KSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(_controller.text),
            child: Text(l10n.save),
          ),
        ),
      ],
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.book, required this.loan});

  final Book book;
  final Loan? loan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final rows = <(String, String)>[
      if (book.isbn13 != null) (l10n.detailIsbn, book.isbn13!.value),
      if (book.language.isNotEmpty) (l10n.fieldLanguage, book.language),
      if (book.genre.isNotEmpty) (l10n.fieldGenre, book.genre),
      if ((book.ownerName ?? '').isNotEmpty)
        (l10n.detailOwner, book.ownerName!),
      if (book.startedOn != null)
        (l10n.detailStarted, fmt.format(book.startedOn!)),
      if (book.finishedOn != null)
        (l10n.detailFinished, fmt.format(book.finishedOn!)),
      (l10n.detailAddedOn, fmt.format(book.createdAt)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.detailSectionDetails, style: theme.textTheme.titleMedium),
        const SizedBox(height: KSpacing.sm),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: KSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 112,
                  child: Text(
                    r.$1,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.kTokens.mutedText,
                    ),
                  ),
                ),
                Expanded(child: Text(r.$2)),
              ],
            ),
          ),
      ],
    );
  }
}

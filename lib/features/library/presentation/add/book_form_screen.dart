import 'dart:async';

import 'package:flutter/material.dart';

import '../../../locations/presentation/location_name.dart';
import '../../../locations/presentation/location_picker.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/add_book_providers.dart';
import '../../../../app/l10n/failure_message.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../core/result.dart';
import '../../../../core/text/isbn.dart';
import '../../../../core/text/series.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../platform/photo_picker/photo_picker.dart';
import '../../../../ui/ui.dart';
import '../../application/add_book.dart';
import '../../../book/application/book_progress.dart';
import '../../../../app/providers.dart';
import '../../domain/book.dart';
import '../../domain/book_enums.dart';
import '../../../../app/cover_providers.dart';
import '../../../../app/repositories.dart';
import 'add_args.dart';
import 'duplicate_sheet.dart';

/// The Add Book form. Used for manual entry and, pre-filled with a cover and
/// a note, as the preview of a catalogue match.
class BookFormScreen extends ConsumerStatefulWidget {
  const BookFormScreen({required this.args, super.key});

  final BookFormArgs args;

  @override
  ConsumerState<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends ConsumerState<BookFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  late final TextEditingController _authors;
  late final TextEditingController _pages;
  late final TextEditingController _isbn;
  late final TextEditingController _genre;
  late final TextEditingController _language;
  late final TextEditingController _notes;
  late final TextEditingController _series;
  late final TextEditingController _seriesNumber;
  late Ownership _ownership;
  late ReadStatus _status;
  String? _locationId;
  Uint8List? _photo;
  late bool _useCatalogueCover;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.args.draft;
    _title = TextEditingController(text: d.title);
    _subtitle = TextEditingController(text: d.subtitle ?? '');
    _authors = TextEditingController(text: d.authors);
    _pages = TextEditingController(text: d.pages?.toString() ?? '');
    _isbn = TextEditingController(text: d.isbn13?.value ?? '');
    _genre = TextEditingController(text: d.genre);
    _language = TextEditingController(text: d.language);
    _notes = TextEditingController(text: d.notes ?? '');
    _series = TextEditingController(text: d.series ?? '');
    _seriesNumber = TextEditingController(
      text: d.seriesNumber == null ? '' : seriesNumberText(d.seriesNumber!),
    );
    _ownership = d.ownership;
    _status = d.status;
    _locationId = d.locationId;
    _useCatalogueCover = d.coverUrl != null;
    // Keep the live cover preview in step with what is typed.
    _title.addListener(_refresh);
    _authors.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    for (final c in <TextEditingController>[
      _title,
      _subtitle,
      _authors,
      _pages,
      _isbn,
      _genre,
      _language,
      _notes,
      _series,
      _seriesNumber,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto(PhotoSource source) async {
    final bytes = await ref.read(photoPickerProvider).pick(source);
    if (bytes == null || !mounted) return;
    setState(() => _photo = bytes);
  }

  BookDraft _buildDraft() {
    final d = widget.args.draft;
    final pagesText = _pages.text.trim();
    return BookDraft(
      title: _title.text,
      authors: _authors.text,
      subtitle: _subtitle.text,
      isbn13: _isbn.text.trim().isEmpty ? null : parseIsbn(_isbn.text),
      olWorkKey: d.olWorkKey,
      pages: pagesText.isEmpty ? null : int.tryParse(pagesText),
      genre: _genre.text,
      language: _language.text,
      ownership: _ownership,
      status: _status,
      locationId: _locationId,
      ownerName: d.ownerName,
      notes: _notes.text,
      coverUrl: _useCatalogueCover ? d.coverUrl : null,
      coverPhoto: _photo,
      series: _series.text.trim().isEmpty ? null : _series.text.trim(),
      seriesNumber: _series.text.trim().isEmpty
          ? null
          : double.tryParse(_seriesNumber.text.trim().replaceAll(',', '.')),
    );
  }

  Future<void> _saveEdit(Book book) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final d = _buildDraft();
    final title = d.title.trim();
    final isbn = d.isbn13;
    final today = ref.read(clockProvider).today();
    setState(() => _saving = true);
    final r = await ref
        .read(bookRepositoryProvider)
        .update(
          book.id,
          (b) => withStatus(
            b.copyWith(
              title: title,
              authors: d.authors.trim(),
              subtitle: d.subtitle?.trim().isEmpty ?? true
                  ? null
                  : d.subtitle!.trim(),
              isbn13: isbn,
              pages: d.pages,
              genre: d.genre.trim(),
              language: d.language.trim(),
              ownership: d.ownership,
              locationId: d.locationId,
              notes: d.notes?.trim().isEmpty ?? true ? null : d.notes!.trim(),
              series: d.series,
              seriesNumber: d.seriesNumber,
              coverUrl: _useCatalogueCover ? b.coverUrl : null,
            ),
            d.status,
            today,
          ),
        );
    if (!mounted) return;
    switch (r) {
      case Ok<Book>():
        final photo = _photo;
        if (photo != null) {
          final ref0 = await ref
              .read(coverStoreProvider)
              .saveFromBytes(book.id, photo);
          if (ref0 case Ok<String>(:final value)) {
            await ref
                .read(bookRepositoryProvider)
                .update(book.id, (b) => b.copyWith(coverLocalPath: value));
          }
        } else if (!_useCatalogueCover && book.coverLocalPath != null) {
          await ref
              .read(bookRepositoryProvider)
              .update(book.id, (b) => b.copyWith(coverLocalPath: null));
        }
        KToast.showWith(messenger, l10n.bookSavedChanges);
        if (router.canPop()) {
          router.pop();
        } else {
          router.go(Routes.book(book.id));
        }
      case Err<Book>(:final failure):
        setState(() => _saving = false);
        KToast.showWith(
          messenger,
          failureMessage(l10n, failure),
          icon: Icons.error_outline_rounded,
        );
    }
  }

  Future<void> _save({required bool addAnother}) async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    final editing = widget.args.editing;
    if (editing != null) return _saveEdit(editing);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final locations = ref.read(locationsProvider).value ?? const [];
    final draft = _buildDraft();
    final useCase = ref.read(addBookProvider);

    setState(() => _saving = true);
    var result = await useCase(draft);
    if (!mounted) return;

    if (result case Ok<AddBookResult>(:final value)
        when value is DuplicatesFound) {
      final choice = await showDuplicateSheet(context, value.books);
      if (!mounted) return;
      switch (choice) {
        case OpenExisting(:final bookId):
          setState(() => _saving = false);
          router.go(Routes.book(bookId));
          return;
        case AddAnotherCopy():
          result = await useCase(draft, allowDuplicate: true);
          if (!mounted) return;
        case null:
          setState(() => _saving = false);
          return;
      }
    }

    switch (result) {
      case Ok<AddBookResult>(:final value) when value is BookAdded:
        Haptics.light();
        String? place;
        for (final loc in locations) {
          if (loc.id == value.book.locationId) place = loc.name;
        }
        KToast.showWith(
          messenger,
          place == null ? l10n.addedToLibrary : l10n.addedTo(place),
          actionLabel: l10n.view,
          onAction: () => router.go(Routes.book(value.book.id)),
        );
        router.go(addAnother ? Routes.libraryAdd : Routes.library);
      case Err<AddBookResult>(:final failure):
        setState(() => _saving = false);
        KToast.showWith(
          messenger,
          failureMessage(l10n, failure),
          icon: Icons.error_outline_rounded,
        );
      case Ok<AddBookResult>():
        setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final args = widget.args;
    final locations = ref.watch(locationsProvider).value ?? const [];
    final catalogueUrl = widget.args.draft.coverUrl;
    final hasCover =
        _photo != null || (_useCatalogueCover && catalogueUrl != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          args.isEdit
              ? l10n.editBookTitle
              : (args.isPreview ? l10n.addBookTitle : l10n.addManualTitle),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  KSpacing.screen,
                  KSpacing.sm,
                  KSpacing.screen,
                  KSpacing.xxl,
                ),
                children: <Widget>[
                  if (args.notice != null) ...<Widget>[
                    _Notice(text: args.notice!),
                    const SizedBox(height: KSpacing.lg),
                  ],
                  if (args.isPreview) ...<Widget>[
                    Text(
                      l10n.fromCatalogue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: KSpacing.lg),
                  ],
                  Center(
                    child: KBookCover(
                      title: _title.text.trim().isEmpty
                          ? l10n.fieldTitle
                          : _title.text.trim(),
                      author: _authors.text,
                      localImage: _photo == null ? null : MemoryImage(_photo!),
                      imageUrl: _useCatalogueCover ? catalogueUrl : null,
                      size: args.isPreview ? KCoverSize.lg : KCoverSize.md,
                    ),
                  ),
                  const SizedBox(height: KSpacing.md),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: KSpacing.sm,
                    runSpacing: KSpacing.sm,
                    children: <Widget>[
                      KButton(
                        label: l10n.coverTakePhoto,
                        icon: Icons.photo_camera_outlined,
                        variant: KButtonVariant.tonal,
                        onPressed: () => _pickPhoto(PhotoSource.camera),
                      ),
                      KButton(
                        label: l10n.coverChoosePhoto,
                        icon: Icons.photo_library_outlined,
                        variant: KButtonVariant.tonal,
                        onPressed: () => _pickPhoto(PhotoSource.gallery),
                      ),
                      if (hasCover)
                        KButton(
                          label: l10n.coverUseGenerated,
                          variant: KButtonVariant.text,
                          onPressed: () => setState(() {
                            _photo = null;
                            _useCatalogueCover = false;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: KSpacing.xl),
                  TextFormField(
                    controller: _title,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.fieldTitle),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.titleRequired
                        : null,
                  ),
                  const SizedBox(height: KSpacing.md),
                  TextFormField(
                    controller: _subtitle,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.fieldSubtitle),
                  ),
                  const SizedBox(height: KSpacing.md),
                  TextFormField(
                    controller: _authors,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.fieldAuthors),
                  ),
                  const SizedBox(height: KSpacing.md),
                  TextFormField(
                    controller: _pages,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(labelText: l10n.fieldPages),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return null;
                      final n = int.tryParse(t);
                      return (n == null || n <= 0) ? l10n.pagesInvalid : null;
                    },
                  ),
                  const SizedBox(height: KSpacing.md),
                  TextFormField(
                    controller: _isbn,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9Xx\- ]')),
                    ],
                    decoration: InputDecoration(labelText: l10n.isbnFieldLabel),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return null;
                      return parseIsbn(t) == null ? l10n.isbnInvalid : null;
                    },
                  ),
                  const SizedBox(height: KSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _series,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.fieldSeries,
                          ),
                        ),
                      ),
                      const SizedBox(width: KSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _seriesNumber,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.fieldSeriesNumber,
                          ),
                          validator: (v) {
                            final t = v?.trim().replaceAll(',', '.') ?? '';
                            if (t.isEmpty) return null;
                            final n = double.tryParse(t);
                            return n == null || n < 0
                                ? l10n.fieldSeriesNumberInvalid
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KSpacing.md),
                  TextFormField(
                    controller: _genre,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.fieldGenre),
                  ),
                  const SizedBox(height: KSpacing.md),
                  TextFormField(
                    controller: _language,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.fieldLanguage),
                  ),
                  const SizedBox(height: KSpacing.xl),
                  _Label(l10n.fieldOwnership),
                  Wrap(
                    spacing: KSpacing.sm,
                    runSpacing: KSpacing.sm,
                    children: <Widget>[
                      for (final o in Ownership.values)
                        KFilterChip(
                          label: switch (o) {
                            Ownership.owned => l10n.ownershipOwned,
                            Ownership.wishlist => l10n.ownershipWishlist,
                            Ownership.borrowed => l10n.ownershipBorrowed,
                          },
                          selected: _ownership == o,
                          onSelected: (_) => setState(() => _ownership = o),
                        ),
                    ],
                  ),
                  const SizedBox(height: KSpacing.lg),
                  _Label(l10n.fieldStatus),
                  Wrap(
                    spacing: KSpacing.sm,
                    runSpacing: KSpacing.sm,
                    children: <Widget>[
                      for (final s in ReadStatus.values)
                        KFilterChip(
                          label: switch (s) {
                            ReadStatus.want => l10n.statusWant,
                            ReadStatus.reading => l10n.statusReading,
                            ReadStatus.finished => l10n.statusFinished,
                            ReadStatus.dropped => l10n.statusDropped,
                          },
                          selected: _status == s,
                          onSelected: (_) => setState(() => _status = s),
                        ),
                    ],
                  ),
                  const SizedBox(height: KSpacing.lg),
                  InkWell(
                    borderRadius: BorderRadius.circular(KRadii.input),
                    onTap: () async {
                      final pick = await showLocationPicker(
                        context,
                        selectedId: _locationId,
                      );
                      if (pick != null) setState(() => _locationId = pick.id);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.fieldLocation,
                        suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                      ),
                      child: Text(
                        locations
                                .where((l) => l.id == _locationId)
                                .map((l) => locationPath(l, locations))
                                .firstOrNull ??
                            l10n.noLocation,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: KSpacing.md),
                  TextFormField(
                    controller: _notes,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(labelText: l10n.fieldNotes),
                  ),
                  const SizedBox(height: KSpacing.xl),
                  KButton(
                    label: l10n.save,
                    loading: _saving,
                    expand: true,
                    onPressed: () => _save(addAnother: false),
                  ),
                  if (!args.isEdit) ...<Widget>[
                    const SizedBox(height: KSpacing.sm),
                    KButton(
                      label: l10n.saveAndAddAnother,
                      variant: KButtonVariant.text,
                      expand: true,
                      onPressed: _saving ? null : () => _save(addAnother: true),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KSpacing.sm),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(KRadii.button),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

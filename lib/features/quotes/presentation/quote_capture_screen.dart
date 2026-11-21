import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/add_book_providers.dart';
import '../../../app/book_detail_providers.dart';
import '../../../app/l10n/failure_message.dart';
import '../../../app/quote_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/image/page_image.dart';
import '../../../core/result.dart';
import '../../../core/text/quote_cleanup.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/ocr/ocr_service.dart';
import '../../../platform/photo_picker/photo_picker.dart';
import '../../../ui/ui.dart';
import '../domain/quote.dart';
import 'crop_step.dart';

enum _Phase { source, crop, reading, lines, edit }

/// Saves a quote from a photo of a page, or typed by hand.
///
/// photo → crop → on-device text reading → tap the lines to keep → edit →
/// save. Where text reading is unavailable (the web) it opens straight on the
/// text field. The photo lives in memory only and is dropped as soon as the
/// text has been read; only the text is saved.
class QuoteCaptureScreen extends ConsumerStatefulWidget {
  const QuoteCaptureScreen({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<QuoteCaptureScreen> createState() => _QuoteCaptureScreenState();
}

class _QuoteCaptureScreenState extends ConsumerState<QuoteCaptureScreen> {
  late _Phase _phase;
  Uint8List? _photo;
  List<OcrLine> _lines = const <OcrLine>[];
  final Set<int> _picked = <int>{};
  final TextEditingController _body = TextEditingController();
  final TextEditingController _page = TextEditingController();
  bool _pagePrefilled = false;
  String? _bodyError;
  String? _pageError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _phase = ref.read(ocrServiceProvider).isSupported
        ? _Phase.source
        : _Phase.edit;
  }

  @override
  void dispose() {
    _body.dispose();
    _page.dispose();
    _photo = null;
    super.dispose();
  }

  void _toast(String text) => KToast.showWith(
    ScaffoldMessenger.of(context),
    text,
    icon: Icons.error_outline_rounded,
  );

  Future<void> _pick(PhotoSource source) async {
    final bytes = await ref.read(photoPickerProvider).pick(source);
    if (bytes == null || !mounted) return;
    setState(() {
      _photo = bytes;
      _phase = _Phase.crop;
    });
  }

  Future<void> _read(PageChoice choice) async {
    final l10n = AppLocalizations.of(context);
    final photo = _photo;
    if (photo == null) return;
    setState(() => _phase = _Phase.reading);
    try {
      final edited = await ref.read(pageEditorProvider)(
        PageEdit(photo, choice.quarterTurns, choice.crop),
      );
      final r = await ref.read(ocrServiceProvider).recognise(edited);
      if (!mounted) return;
      switch (r) {
        case Err<List<OcrLine>>():
          _photo = null;
          setState(() => _phase = _Phase.source);
          _toast(l10n.quoteReadFailed);
        case Ok<List<OcrLine>>(:final value) when value.isEmpty:
          _photo = null;
          setState(() => _phase = _Phase.edit);
          _toast(l10n.quoteNoText);
        case Ok<List<OcrLine>>(:final value):
          _photo = null;
          setState(() {
            _lines = value;
            _picked.clear();
            _phase = _Phase.lines;
          });
      }
    } on Object {
      if (!mounted) return;
      _photo = null;
      setState(() => _phase = _Phase.source);
      _toast(l10n.quoteReadFailed);
    }
  }

  void _useSelected() {
    final chosen = (_picked.toList()..sort()).map((i) => _lines[i].text);
    setState(() {
      _body.text = cleanQuoteText(chosen);
      _bodyError = null;
      _phase = _Phase.edit;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final text = _body.text.trim();
    if (text.isEmpty) {
      setState(() => _bodyError = l10n.quoteBodyRequired);
      return;
    }
    final pageText = _page.text.trim();
    final page = pageText.isEmpty ? null : int.tryParse(pageText);
    if (pageText.isNotEmpty && (page == null || page < 1)) {
      setState(() => _pageError = l10n.quotePageInvalid);
      return;
    }
    setState(() {
      _saving = true;
      _bodyError = null;
      _pageError = null;
    });
    final r = await ref
        .read(saveQuoteProvider)
        .call(bookId: widget.bookId, body: text, page: page);
    if (!mounted) return;
    switch (r) {
      case Ok<Quote>():
        KToast.showWith(
          messenger,
          l10n.quoteSaved,
          icon: Icons.format_quote_rounded,
        );
        if (context.canPop()) context.pop();
      case Err<Quote>(:final failure):
        setState(() {
          _saving = false;
          // A page past the end of the book is the likely validation error.
          if (failure case final f when f.debugMessage == 'page') {
            _pageError = l10n.quotePageInvalid;
          } else {
            _toast(failureMessage(l10n, failure));
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final book = ref.watch(bookByIdProvider(widget.bookId)).value;
    if (!_pagePrefilled && book != null) {
      _pagePrefilled = true;
      if (book.currentPage > 0) _page.text = '${book.currentPage}';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quoteCaptureTitle),
        actions: <Widget>[
          if (_phase == _Phase.lines)
            TextButton(
              onPressed: () => setState(() {
                if (_picked.length == _lines.length) {
                  _picked.clear();
                } else {
                  _picked.addAll(Iterable<int>.generate(_lines.length));
                }
              }),
              child: Text(l10n.quoteSelectAll),
            ),
        ],
      ),
      body: SafeArea(
        child: switch (_phase) {
          _Phase.source => _Source(
            bookTitle: book?.title,
            onCamera: () => _pick(PhotoSource.camera),
            onGallery: () => _pick(PhotoSource.gallery),
            onType: () => setState(() => _phase = _Phase.edit),
          ),
          _Phase.crop => CropStep(image: _photo!, onDone: _read),
          _Phase.reading => const _Reading(),
          _Phase.lines => _LinesStep(
            lines: _lines,
            picked: _picked,
            onToggle: (i) => setState(() {
              if (!_picked.remove(i)) _picked.add(i);
            }),
            onUse: _useSelected,
          ),
          _Phase.edit => _EditStep(
            body: _body,
            page: _page,
            maxPage: book?.pages,
            bodyError: _bodyError,
            pageError: _pageError,
            saving: _saving,
            canPickAgain: _lines.isNotEmpty,
            onPickAgain: () => setState(() => _phase = _Phase.lines),
            onSave: _save,
          ),
        },
      ),
    );
  }
}

class _Source extends StatelessWidget {
  const _Source({
    required this.bookTitle,
    required this.onCamera,
    required this.onGallery,
    required this.onType,
  });

  final String? bookTitle;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(KSpacing.screen),
      children: <Widget>[
        if (bookTitle != null)
          Text(
            bookTitle!,
            style: theme.textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: KSpacing.sm),
        Text(l10n.quoteSourceBody, style: theme.textTheme.bodyMedium),
        const SizedBox(height: KSpacing.xl),
        KButton(
          label: l10n.quoteTakePhoto,
          icon: Icons.photo_camera_outlined,
          expand: true,
          onPressed: onCamera,
        ),
        const SizedBox(height: KSpacing.md),
        KButton(
          label: l10n.quoteChoosePhoto,
          icon: Icons.photo_library_outlined,
          variant: KButtonVariant.tonal,
          expand: true,
          onPressed: onGallery,
        ),
        const SizedBox(height: KSpacing.md),
        TextButton(onPressed: onType, child: Text(l10n.quoteTypeIt)),
      ],
    );
  }
}

class _Reading extends StatelessWidget {
  const _Reading();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const CircularProgressIndicator(),
        const SizedBox(height: KSpacing.lg),
        Text(AppLocalizations.of(context).quoteReading),
      ],
    ),
  );
}

class _LinesStep extends StatelessWidget {
  const _LinesStep({
    required this.lines,
    required this.picked,
    required this.onToggle,
    required this.onUse,
  });

  final List<OcrLine> lines;
  final Set<int> picked;
  final void Function(int index) onToggle;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // A marker-pen yellow that reads on paper and in the dark theme.
    final marker = theme.brightness == Brightness.dark
        ? const Color(0x66E0B05A)
        : const Color(0x99F5D76E);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KSpacing.screen,
            KSpacing.md,
            KSpacing.screen,
            KSpacing.sm,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.quotePickLines, style: theme.textTheme.bodyMedium),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: KSpacing.screen,
              vertical: KSpacing.sm,
            ),
            itemCount: lines.length,
            itemBuilder: (context, i) {
              final on = picked.contains(i);
              return Semantics(
                selected: on,
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => onToggle(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : KDurations.fast,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: on ? marker : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          lines[i].text,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(KSpacing.screen),
          child: KButton(
            label: l10n.quoteUseSelected,
            icon: Icons.format_quote_rounded,
            expand: true,
            onPressed: picked.isEmpty ? null : onUse,
          ),
        ),
      ],
    );
  }
}

class _EditStep extends StatelessWidget {
  const _EditStep({
    required this.body,
    required this.page,
    required this.maxPage,
    required this.bodyError,
    required this.pageError,
    required this.saving,
    required this.canPickAgain,
    required this.onPickAgain,
    required this.onSave,
  });

  final TextEditingController body;
  final TextEditingController page;
  final int? maxPage;
  final String? bodyError;
  final String? pageError;
  final bool saving;
  final bool canPickAgain;
  final VoidCallback onPickAgain;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(KSpacing.screen),
      children: <Widget>[
        TextField(
          controller: body,
          minLines: 5,
          maxLines: 12,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.quoteBodyLabel,
            alignLabelWithHint: true,
            errorText: bodyError,
          ),
        ),
        if (canPickAgain)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onPickAgain,
              child: Text(l10n.quotePickAgain),
            ),
          ),
        const SizedBox(height: KSpacing.md),
        TextField(
          controller: page,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: l10n.quotePageLabel,
            helperText: maxPage == null ? null : '/ $maxPage',
            errorText: pageError,
          ),
        ),
        const SizedBox(height: KSpacing.xl),
        KButton(
          label: l10n.quoteSave,
          icon: Icons.check_rounded,
          expand: true,
          loading: saving,
          onPressed: saving ? null : onSave,
        ),
      ],
    );
  }
}

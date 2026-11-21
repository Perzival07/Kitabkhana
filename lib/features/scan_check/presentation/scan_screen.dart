import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/add_book_providers.dart';
import '../../../app/l10n/failure_message.dart';
import '../../../app/providers.dart';
import '../../../app/repositories.dart';
import '../../../app/router/routes.dart';
import '../../../app/scan_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/result.dart';
import '../../../core/text/isbn.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/camera_permission/camera_permission.dart';
import '../../../ui/ui.dart';
import '../../library/application/add_book.dart';
import '../../library/domain/book.dart';
import '../../library/domain/book_enums.dart';
import '../../library/domain/book_info.dart';
import '../../library/presentation/add/add_args.dart';
import '../../locations/presentation/location_picker.dart';
import '../application/scan_stabilizer.dart';
import '../domain/ownership_result.dart';
import 'scan_overlay.dart';
import 'verdict_sheet.dart';

/// The Scan tab: point the camera at a barcode (or search by title) and see
/// at once whether the book is already yours.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraAccess? _access;
  bool _cameraFailed = false;
  bool _checking = false;
  bool _sheetOpen = false;
  late final ScanStabilizer _stabilizer = ScanStabilizer(
    ref.read(clockProvider),
  );

  @override
  void initState() {
    super.initState();
    _loadAccess();
  }

  Future<void> _loadAccess() async {
    final a = await ref.read(cameraPermissionProvider).status();
    if (mounted) setState(() => _access = a);
  }

  Future<void> _request() async {
    final a = await ref.read(cameraPermissionProvider).request();
    if (mounted) setState(() => _access = a);
  }

  Future<void> _onCode(String raw) async {
    if (_sheetOpen || _checking) return;
    final isbn = _stabilizer.accept(raw);
    if (isbn != null) await _check(isbn);
  }

  Future<void> _check(String input) async {
    if (_sheetOpen || _checking || !mounted) return;
    setState(() => _checking = true);
    final check = ref.read(checkOwnershipProvider);
    final OwnershipResult result;
    try {
      result = await check(input);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
    if (!mounted) return;
    if (isOwnedVerdict(result)) {
      Haptics.success();
    } else {
      Haptics.light();
    }
    _sheetOpen = true;
    final outcome = await showVerdictSheet(
      context,
      result: result,
      check: check,
    );
    _sheetOpen = false;
    _stabilizer.reset();
    if (!mounted || outcome == null) return;
    await _handle(outcome);
  }

  Future<void> _handle(VerdictOutcome outcome) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    switch (outcome) {
      case ScanAnotherOutcome():
        return;
      case OpenBookOutcome(:final bookId):
        await context.push(Routes.book(bookId));
      case MarkBoughtOutcome(:final book):
        final pick = await showLocationPicker(
          context,
          selectedId: book.locationId,
        );
        if (pick == null) return;
        final r = await ref
            .read(bookRepositoryProvider)
            .update(
              book.id,
              (b) =>
                  b.copyWith(ownership: Ownership.owned, locationId: pick.id),
            );
        switch (r) {
          case Ok<Book>():
            KToast.showWith(messenger, l10n.verdictBoughtDone);
          case Err<Book>(:final failure):
            KToast.showWith(
              messenger,
              failureMessage(l10n, failure),
              icon: Icons.error_outline_rounded,
            );
        }
      case AddToWishlistOutcome(:final isbn, :final info):
        await _addNew(
          isbn: isbn,
          info: info,
          ownership: Ownership.wishlist,
          saveNow: true,
        );
      case AddAsBoughtOutcome(:final isbn, :final info):
        await _addNew(isbn: isbn, info: info, ownership: Ownership.owned);
    }
  }

  /// A wishlist add with known details saves at once; anything else opens the
  /// form pre-filled, so the user is never stuck.
  Future<void> _addNew({
    required Isbn13? isbn,
    required BookInfo? info,
    required Ownership ownership,
    bool saveNow = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final base = info != null
        ? BookDraft.fromInfo(info)
        : BookDraft(isbn13: isbn);
    final draft = BookDraft(
      title: base.title,
      authors: base.authors,
      subtitle: base.subtitle,
      isbn13: base.isbn13 ?? isbn,
      olWorkKey: base.olWorkKey,
      pages: base.pages,
      coverUrl: base.coverUrl,
      ownership: ownership,
    );
    if (saveNow && draft.title.trim().isNotEmpty) {
      final r = await ref.read(addBookProvider)(draft, allowDuplicate: true);
      if (!mounted) return;
      if (r case Ok<AddBookResult>()) {
        KToast.showWith(messenger, l10n.verdictWishlistAdded);
      } else if (r case Err<AddBookResult>(:final failure)) {
        KToast.showWith(
          messenger,
          failureMessage(l10n, failure),
          icon: Icons.error_outline_rounded,
        );
      }
      return;
    }
    await context.push(
      info != null ? Routes.libraryAddPreview : Routes.libraryAddManual,
      extra: BookFormArgs(draft: draft, info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final access = _access;
    final cameraUsable = access == CameraAccess.granted && !_cameraFailed;
    final builder = ref.watch(barcodeViewBuilderProvider);

    final Widget top;
    if (access == null) {
      top = const KPageSkeleton();
    } else if (cameraUsable) {
      top = Stack(
        fit: StackFit.expand,
        children: <Widget>[
          builder(context, _onCode, (context) {
            // The camera could not start (e.g. no camera, or a web page
            // without HTTPS): fall back to the search view.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_cameraFailed) {
                setState(() => _cameraFailed = true);
              }
            });
            return const SizedBox.shrink();
          }),
          ScanOverlay(hint: l10n.scanHint),
          if (_checking)
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(KSpacing.lg),
                child: KSkeleton(width: 160, height: 12),
              ),
            ),
        ],
      );
    } else {
      top = _PermissionPanel(
        access: _cameraFailed ? CameraAccess.unavailable : access,
        onRequest: _request,
        onOpenSettings: () => ref.read(cameraPermissionProvider).openSettings(),
        webNote: kIsWeb,
      );
    }

    final searchOnly = access == CameraAccess.unavailable || _cameraFailed;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: searchOnly ? 2 : 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(KRadii.card),
                ),
                child: top,
              ),
            ),
            _SearchPanel(
              onSearch: _check,
              onTypeIsbn: () => context.push(Routes.libraryAddIsbn),
              busy: _checking,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.onSearch,
    required this.onTypeIsbn,
    required this.busy,
  });

  final ValueChanged<String> onSearch;
  final VoidCallback onTypeIsbn;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KSpacing.screen,
        KSpacing.md,
        KSpacing.screen,
        KSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: KSpacing.xs),
              child: Text(
                l10n.scanSearchLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
          KSearchField(
            hint: l10n.scanSearchHint,
            onChanged: (v) {
              if (v.trim().length >= 3) onSearch(v);
            },
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) onSearch(v);
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onTypeIsbn,
              icon: const Icon(Icons.keyboard_alt_outlined),
              label: Text(l10n.scanTypeIsbn),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionPanel extends StatelessWidget {
  const _PermissionPanel({
    required this.access,
    required this.onRequest,
    required this.onOpenSettings,
    required this.webNote,
  });

  final CameraAccess access;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;
  final bool webNote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (access) {
      CameraAccess.notAsked => KEmptyState(
        illustration: KIllustration.scannerFrame,
        title: l10n.scanPermTitle,
        body: l10n.scanPermBody,
        actionLabel: l10n.scanPermAllow,
        onAction: onRequest,
      ),
      CameraAccess.denied => KEmptyState(
        illustration: KIllustration.scannerFrame,
        title: l10n.scanDeniedTitle,
        body: l10n.scanDeniedBody,
        actionLabel: l10n.scanTryAgain,
        onAction: onRequest,
      ),
      CameraAccess.permanentlyDenied => KEmptyState(
        illustration: KIllustration.scannerFrame,
        title: l10n.scanBlockedTitle,
        body: l10n.scanBlockedBody,
        actionLabel: l10n.scanOpenSettings,
        onAction: onOpenSettings,
      ),
      CameraAccess.unavailable || CameraAccess.granted => KEmptyState(
        illustration: KIllustration.scannerFrame,
        title: l10n.scanUnavailableTitle,
        body: webNote ? l10n.scanWebHttpsNote : l10n.scanNoCameraNote,
      ),
    };
  }
}

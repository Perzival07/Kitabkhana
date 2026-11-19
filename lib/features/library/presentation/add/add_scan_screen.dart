import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/add_book_providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../core/text/isbn.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import 'isbn_lookup_flow.dart';

/// A basic barcode scan for adding a book (the full scanner arrives with the
/// scan tab). Reads an ISBN barcode, looks it up and continues.
class AddScanScreen extends ConsumerStatefulWidget {
  const AddScanScreen({super.key});

  @override
  ConsumerState<AddScanScreen> createState() => _AddScanScreenState();
}

class _AddScanScreenState extends ConsumerState<AddScanScreen> {
  bool _busy = false;

  Future<void> _onCode(String code) async {
    if (_busy) return;
    final isbn = parseIsbn(code);
    if (isbn == null) return; // not a book barcode: keep scanning
    setState(() => _busy = true);
    unawaited(HapticFeedback.mediumImpact());
    await lookupIsbnAndContinue(context: context, ref: ref, isbn: isbn);
    if (mounted) setState(() => _busy = false);
  }

  Widget _unavailable(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KEmptyState(
      illustration: KIllustration.scannerFrame,
      title: l10n.scanUnavailableTitle,
      body: l10n.scanUnavailableBody,
      actionLabel: l10n.addIsbnTitle,
      onAction: () => context.pushReplacement(Routes.libraryAddIsbn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final builder = ref.watch(barcodeViewBuilderProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addScanTitle)),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            builder(context, _onCode, _unavailable),
            IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(KSpacing.screen),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(KRadii.button),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KSpacing.lg,
                        vertical: KSpacing.md,
                      ),
                      child: Text(
                        _busy ? l10n.lookingUp : l10n.scanHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_busy) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

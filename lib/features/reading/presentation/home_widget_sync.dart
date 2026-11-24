import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/book_detail_providers.dart';
import '../../../app/reading_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../lending/domain/loan_direction.dart';
import '../../../platform/home_widget/home_screen_widget.dart';
import '../application/widget_snapshot.dart';

/// Keeps the home-screen widget in step with the library: whenever the book
/// being read, its page, or the loans change, the widget gets new text.
class HomeWidgetSync extends ConsumerStatefulWidget {
  const HomeWidgetSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<HomeWidgetSync> createState() => _HomeWidgetSyncState();
}

class _HomeWidgetSyncState extends ConsumerState<HomeWidgetSync> {
  WidgetSnapshot? _last;

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final reading = ref.watch(currentlyReadingProvider).value;
    final active = ref.watch(activeLoansProvider).value;
    final overdue = ref.watch(overdueLoansProvider).value;
    if (l10n != null && reading != null && active != null && overdue != null) {
      final snap = buildWidgetSnapshot(
        l10n,
        reading: reading,
        lentOut: active.where((l) => l.direction == LoanDirection.lent).length,
        overdue: overdue.length,
      );
      if (snap != _last) {
        _last = snap;
        // After the frame: building must not call out to the platform.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(homeScreenWidgetProvider).show(snap);
        });
      }
    }
    return widget.child;
  }
}

import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// Shows a modal bottom sheet that is safe-area and keyboard aware,
/// scrollable, and capped at 90% of the screen height.
Future<T?> showKBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  final height = MediaQuery.sizeOf(context).height;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    constraints: BoxConstraints(maxHeight: height * 0.9, maxWidth: 640),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              KSpacing.screen,
              0,
              KSpacing.screen,
              KSpacing.xl,
            ),
            child: builder(sheetContext),
          ),
        ),
      );
    },
  );
}

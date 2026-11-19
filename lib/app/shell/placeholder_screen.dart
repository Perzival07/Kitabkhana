import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// Temporary tab/route body: a warm empty state. Replaced feature by feature.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.illustration,
    required this.title,
    required this.body,
    this.appBarTitle,
    super.key,
  });

  final KIllustration illustration;
  final String title;
  final String body;

  /// When set, shows an app bar with a back button (for pushed routes).
  final String? appBarTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTitle == null ? null : AppBar(title: Text(appBarTitle!)),
      body: SafeArea(
        child: KEmptyState(
          illustration: illustration,
          title: title,
          body: body,
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// What the home-screen widget shows, already in the reader's language.
@immutable
final class WidgetSnapshot {
  const WidgetSnapshot({
    required this.label,
    required this.title,
    this.subtitle = '',
    this.progress,
    this.footer = '',
  });

  final String label;
  final String title;
  final String subtitle;

  /// 0 to 100, or null to hide the bar.
  final int? progress;
  final String footer;

  Map<String, Object?> toMap() => <String, Object?>{
    'label': label,
    'title': title,
    'subtitle': subtitle,
    'progress': progress ?? -1,
    'footer': footer,
  };

  @override
  bool operator ==(Object other) =>
      other is WidgetSnapshot &&
      other.label == label &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.progress == progress &&
      other.footer == footer;

  @override
  int get hashCode => Object.hash(label, title, subtitle, progress, footer);
}

/// Hands the home-screen widget its text. Android only (the app's own
/// `ReadingWidgetProvider`); elsewhere it does nothing.
abstract interface class HomeScreenWidget {
  Future<void> show(WidgetSnapshot snapshot);
}

class AndroidHomeScreenWidget implements HomeScreenWidget {
  const AndroidHomeScreenWidget();

  static const MethodChannel _channel = MethodChannel('kitabkhana/widget');

  @override
  Future<void> show(WidgetSnapshot snapshot) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<bool>('update', snapshot.toMap());
    } on Object {
      // No widget support (an old launcher, a test): nothing to update.
    }
  }
}

import 'package:kitabkhana/platform/home_widget/home_screen_widget.dart';

/// Records what the home-screen widget was told to show.
class FakeHomeScreenWidget implements HomeScreenWidget {
  final List<WidgetSnapshot> shown = <WidgetSnapshot>[];

  @override
  Future<void> show(WidgetSnapshot snapshot) async => shown.add(snapshot);
}

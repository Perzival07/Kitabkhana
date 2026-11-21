import '../../../core/clock.dart';
import '../../../core/uuid.dart';
import '../domain/location.dart';
import '../domain/location_repository.dart';

/// A suggested first place for books.
final class StarterLocation {
  const StarterLocation(this.name, this.icon);

  final String name;
  final String icon;
}

/// Creates [chosen] locations, in order. Returns how many were saved.
Future<int> addStarterLocations(
  LocationRepository repo,
  Clock clock,
  List<StarterLocation> chosen,
) async {
  var saved = 0;
  for (var i = 0; i < chosen.length; i++) {
    final r = await repo.upsert(
      Location.create(
        id: uuidV7(),
        name: chosen[i].name,
        now: clock.now(),
        sortOrder: i,
        icon: chosen[i].icon,
      ),
    );
    if (r.isOk) saved++;
  }
  return saved;
}

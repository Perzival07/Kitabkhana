import '../domain/location.dart';

/// "Bedroom › Shelf 2" for a child location, just the name otherwise.
String locationPath(Location loc, Iterable<Location> all) {
  if (loc.parentId == null) return loc.name;
  for (final p in all) {
    if (p.id == loc.parentId) return '${p.name} › ${loc.name}';
  }
  return loc.name;
}

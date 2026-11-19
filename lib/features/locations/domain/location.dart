import '../../../core/copy_with.dart';
import '../../../core/entity.dart';

/// A physical place books live: shelf, box, room, bag, office...
final class Location extends Entity {
  const Location({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
    required super.rev,
    required this.name,
    this.parentId,
    this.sortOrder = 0,
    this.icon,
  });

  factory Location.create({
    required String id,
    required String name,
    required DateTime now,
    String? parentId,
    int sortOrder = 0,
    String? icon,
  }) => Location(
    id: id,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    rev: 1,
    name: name,
    parentId: parentId,
    sortOrder: sortOrder,
    icon: icon,
  );

  final String name;
  final String? parentId;
  final int sortOrder;
  final String? icon;

  Location copyWith({
    String? name,
    Object? parentId = keep,
    int? sortOrder,
    Object? icon = keep,
    DateTime? updatedAt,
    Object? deletedAt = keep,
    int? rev,
  }) {
    return Location(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: pick<DateTime>(deletedAt, this.deletedAt),
      rev: rev ?? this.rev,
      name: name ?? this.name,
      parentId: pick<String>(parentId, this.parentId),
      sortOrder: sortOrder ?? this.sortOrder,
      icon: pick<String>(icon, this.icon),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Location &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt &&
      other.rev == rev &&
      other.name == name &&
      other.parentId == parentId &&
      other.sortOrder == sortOrder &&
      other.icon == icon;

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    name,
    parentId,
    sortOrder,
    icon,
  );

  @override
  String toString() => 'Location($id, $name)';
}

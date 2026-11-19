import '../../../core/copy_with.dart';
import '../../../core/entity.dart';

/// A free-form label attached to books.
final class Tag extends Entity {
  const Tag({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
    required super.rev,
    required this.name,
  });

  factory Tag.create({
    required String id,
    required String name,
    required DateTime now,
  }) => Tag(
    id: id,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    rev: 1,
    name: name,
  );

  final String name;

  Tag copyWith({
    String? name,
    DateTime? updatedAt,
    Object? deletedAt = keep,
    int? rev,
  }) {
    return Tag(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: pick<DateTime>(deletedAt, this.deletedAt),
      rev: rev ?? this.rev,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Tag &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt &&
      other.rev == rev &&
      other.name == name;

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, rev, name);

  @override
  String toString() => 'Tag($name)';
}

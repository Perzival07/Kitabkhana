/// Shared metadata of every synced row: id, timestamps, soft delete and
/// revision counter.
abstract class Entity {
  const Entity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.rev,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Incremented on every write.
  final int rev;

  bool get isDeleted => deletedAt != null;
}

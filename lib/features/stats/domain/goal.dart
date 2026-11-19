import '../../../core/copy_with.dart';
import '../../../core/entity.dart';

/// A yearly reading goal: how many books to finish.
final class Goal extends Entity {
  const Goal({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
    required super.rev,
    required this.year,
    required this.targetBooks,
  });

  factory Goal.create({
    required String id,
    required int year,
    required int targetBooks,
    required DateTime now,
  }) => Goal(
    id: id,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    rev: 1,
    year: year,
    targetBooks: targetBooks,
  );

  final int year;
  final int targetBooks;

  Goal copyWith({
    int? targetBooks,
    DateTime? updatedAt,
    Object? deletedAt = keep,
    int? rev,
  }) {
    return Goal(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: pick<DateTime>(deletedAt, this.deletedAt),
      rev: rev ?? this.rev,
      year: year,
      targetBooks: targetBooks ?? this.targetBooks,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Goal &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt &&
      other.rev == rev &&
      other.year == year &&
      other.targetBooks == targetBooks;

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, rev, year, targetBooks);

  @override
  String toString() => 'Goal($year: $targetBooks)';
}

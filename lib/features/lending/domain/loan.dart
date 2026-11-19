import '../../../core/copy_with.dart';
import '../../../core/entity.dart';
import 'loan_direction.dart';

/// A book lent to, or borrowed from, a person.
final class Loan extends Entity {
  const Loan({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
    required super.rev,
    required this.bookId,
    required this.direction,
    required this.personName,
    required this.startedOn,
    this.personPhone,
    this.dueOn,
    this.returnedOn,
    this.previousLocationId,
    this.note,
  });

  factory Loan.create({
    required String id,
    required String bookId,
    required LoanDirection direction,
    required String personName,
    required DateTime startedOn,
    required DateTime now,
    String? personPhone,
    DateTime? dueOn,
    String? previousLocationId,
    String? note,
  }) => Loan(
    id: id,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    rev: 1,
    bookId: bookId,
    direction: direction,
    personName: personName,
    startedOn: startedOn,
    personPhone: personPhone,
    dueOn: dueOn,
    previousLocationId: previousLocationId,
    note: note,
  );

  final String bookId;
  final LoanDirection direction;
  final String personName;
  final String? personPhone;
  final DateTime startedOn;
  final DateTime? dueOn;
  final DateTime? returnedOn;

  /// Where the book sat before it was lent, to restore on return.
  final String? previousLocationId;
  final String? note;

  /// Not yet returned.
  bool get isActive => returnedOn == null && deletedAt == null;

  /// Past its due date as of [today] (a date at local midnight).
  bool isOverdue(DateTime today) {
    final due = dueOn;
    return isActive && due != null && due.isBefore(today);
  }

  Loan copyWith({
    LoanDirection? direction,
    String? personName,
    DateTime? startedOn,
    Object? personPhone = keep,
    Object? dueOn = keep,
    Object? returnedOn = keep,
    Object? previousLocationId = keep,
    Object? note = keep,
    DateTime? updatedAt,
    Object? deletedAt = keep,
    int? rev,
  }) {
    return Loan(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: pick<DateTime>(deletedAt, this.deletedAt),
      rev: rev ?? this.rev,
      bookId: bookId,
      direction: direction ?? this.direction,
      personName: personName ?? this.personName,
      startedOn: startedOn ?? this.startedOn,
      personPhone: pick<String>(personPhone, this.personPhone),
      dueOn: pick<DateTime>(dueOn, this.dueOn),
      returnedOn: pick<DateTime>(returnedOn, this.returnedOn),
      previousLocationId: pick<String>(
        previousLocationId,
        this.previousLocationId,
      ),
      note: pick<String>(note, this.note),
    );
  }

  List<Object?> get _props => <Object?>[
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    bookId,
    direction,
    personName,
    personPhone,
    startedOn,
    dueOn,
    returnedOn,
    previousLocationId,
    note,
  ];

  @override
  bool operator ==(Object other) {
    if (other is! Loan) return false;
    final a = _props;
    final b = other._props;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_props);

  @override
  String toString() => 'Loan($id, $bookId, ${direction.name})';
}

import 'failure.dart';

/// The outcome of an operation: a value ([Ok]) or a [Failure] ([Err]).
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// Collapses to a single value.
  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr);

  /// Transforms the success value; failures pass through.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => Ok<R>(transform(value)),
    Err<T>(:final failure) => Err<R>(failure),
  };

  /// Chains another fallible step.
  Result<R> flatMap<R>(Result<R> Function(T value) next) => switch (this) {
    Ok<T>(:final value) => next(value),
    Err<T>(:final failure) => Err<R>(failure),
  };

  /// The value, or null on failure.
  T? getOrNull() => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  /// The failure, or null on success.
  Failure? failureOrNull() => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) =>
      onOk(value);

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Ok, value);

  @override
  String toString() => 'Ok($value)';
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) =>
      onErr(failure);

  @override
  bool operator ==(Object other) => other is Err<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(Err, failure);

  @override
  String toString() => 'Err($failure)';
}

/// Runs [body] and converts any thrown error into an [UnexpectedFailure], so
/// no raw exception reaches the UI.
Future<Result<T>> guardAsync<T>(Future<T> Function() body) async {
  try {
    return Ok<T>(await body());
  } on Object catch (error, stack) {
    return Err<T>(UnexpectedFailure(error, stack));
  }
}

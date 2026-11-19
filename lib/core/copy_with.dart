/// Sentinel for nullable `copyWith` arguments, so callers can tell "leave
/// unchanged" (the default) from an explicit `null`.
const Object keep = _Keep();

final class _Keep {
  const _Keep();
}

/// Resolves a `copyWith` argument: [current] when [arg] is [keep], else [arg].
T? pick<T>(Object? arg, T? current) =>
    identical(arg, keep) ? current : arg as T?;

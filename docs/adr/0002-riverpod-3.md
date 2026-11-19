# ADR 0002: Riverpod 3 with code generation

**Status:** accepted

State and dependency injection use Riverpod 3 with `riverpod_annotation`/`riverpod_generator` and
`riverpod_lint`. Platform services are injected as providers so tests and web can swap
implementations. Automatic retry is disabled for database providers so failures surface immediately.

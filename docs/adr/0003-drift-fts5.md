# ADR 0003: Drift with FTS5

**Status:** accepted

Drift gives typed SQLite on native and WASM on web. Search uses an FTS5 virtual table over
title, subtitle and authors, kept in sync by triggers. If FTS5 is unavailable on web, search falls
back to `LIKE` on `titleKey` behind the same repository method.

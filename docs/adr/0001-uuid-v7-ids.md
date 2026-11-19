# ADR 0001: UUIDv7 text IDs

**Status:** accepted

All rows use UUIDv7 text primary keys, generated on the client. They are time-ordered (good index
locality) and collision-free across devices, which keeps backup merge and any future sync simple.
Integer autoincrement IDs would collide when merging backups from two devices.

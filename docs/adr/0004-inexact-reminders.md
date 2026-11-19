# ADR 0004: Inexact loan reminders

**Status:** accepted

Reminders are scheduled inexactly (around 10:00 local on the due date), so the app needs no
exact-alarm permission. A day-level nudge is sufficient for lending a book, and avoiding
`SCHEDULE_EXACT_ALARM` keeps the permission list and store review simple.

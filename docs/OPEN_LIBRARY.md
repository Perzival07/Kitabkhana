# Open Library lookups

The only network traffic the app makes. Only an ISBN or a title/author query is ever sent.

## Approach

ISBN lookup: `GET /isbn/{isbn13}.json` (redirects to the edition) -> `GET /works/{key}.json` **only
if the edition lists no authors** -> `GET /authors/{key}.json` for up to three authors.

Why not `/api/books?jscmd=data`: it returns author names in one call, but omits the **work key**,
which the ownership matcher uses to recognise a different edition of a book you own. Real editions
also often have no `authors` field at all (the data lives on the work), so the work call is needed
anyway. If the work or an author call fails the book is still returned, marked `isComplete: false`,
and is not cached.

Title search: `GET /search.json?title=&author=&limit=&fields=key,title,author_name,isbn,cover_i,number_of_pages_median,first_publish_year`.

## Resilience (`OpenLibraryClient`)

- Shared token bucket: 1 request/second, burst 3.
- 8 s timeout. Up to 2 retries (3 attempts) with exponential backoff (500 ms, 1 s) plus jitter, for
  timeouts and 5xx only. 4xx is never retried.
- 429: returns `NetworkFailure.rateLimited`, honours `Retry-After` (default 30 s, max 300 s), and
  sends nothing during the cool-down.
- 404: `NotFoundFailure` (counts as a healthy response).
- Connection errors map to `NetworkFailure.offline` immediately, with no retry.
- Circuit breaker: 5 consecutive failures open it for 2 minutes (calls return offline without
  touching the network). After the cool-down one trial call decides whether it closes or reopens.
  404 and 429 do not count as failures.
- `User-Agent: Kitabkhana/<version> (<contact>)` on mobile only; browsers forbid setting it. The
  contact address comes from `--dart-define=CONTACT_EMAIL=...` and is omitted when unset, so no
  personal address is ever compiled in.

## Caching (`BookLookupService`)

Cache first, then network, then store. Successes live 30 days, not-found 7 days (`lookup_cache`
table). Network trouble never gets cached. An expired success is still served when the network is
down, so a book you looked up once keeps working offline. Title searches are not cached.

## Web

The API, its redirects and `covers.openlibrary.org` all send `Access-Control-Allow-Origin: *`, so
the browser can call them directly.

## Trying it

Dev flavor only: open `/dev/lookup` (a debug screen showing results, failures and timings).

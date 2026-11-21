# Web / PWA release

Hosted on **Cloudflare Pages** (static files, free HTTPS and CDN; it reads the
`_headers` and `_redirects` files that Flutter copies from `web/` into the
build). Netlify reads the same two files, so moving host means only the deploy
command changes. Hosting is **not set up yet**: create the Pages project
`kitabkhana` (or `npx wrangler pages project create kitabkhana`), then deploy.

## Build

```
flutter build web --wasm --release --no-web-resources-cdn -t lib/main_prod.dart
```

- `--no-web-resources-cdn` bundles CanvasKit instead of loading it from
  gstatic.com, which keeps the "no third party" promise and the CSP true.
- `--wasm`: **use the WebAssembly build.** A trial build succeeded, so every
  plugin in use compiles to it. A wasm build also contains the JavaScript
  build (`main.dart.js`) and the loader picks one at runtime: browsers with
  WasmGC (Chrome 119+, Firefox 120+, Safari 18.2+) run the faster wasm, older
  ones silently run JS. So wasm costs nothing in reach. Size: about 5.2 MB wasm
  next to 5.7 MB JS, plus 36 MB of CanvasKit files of which a browser downloads
  only the variant it needs.
  Catch: wasm needs the browser to allow `'wasm-unsafe-eval'`, which the CSP
  already does and scripts are otherwise locked to `'self'`.
- CI builds the same way (`ci.yml`). It was not tested in browsers here (no browser available): open the build in
  Chrome and Safari and watch for CSP errors in the console before announcing it.

## Deploy

```
npx wrangler pages deploy
```

(`wrangler.toml` points at `build/web`.) From CI this is the release workflow's
job (docs/RELEASING.md) with `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.
A custom domain is set in the Pages dashboard.

## What the headers and redirects do

`web/_redirects`: every path that isn't a file serves `index.html`, so reloading
or sharing `/book/123` works (go_router handles routes in the browser).

`web/_headers`:
- Security headers and the CSP (docs/PRIVACY.md).
- `application/wasm` for `.wasm` and a JavaScript type for `.mjs`. Browsers
  refuse wasm served as another type. Drift's `sqlite3.wasm` and
  `drift_worker.js` are plain files in the root and need nothing else.
- **No cross-origin isolation (COEP) on purpose.** Drift's best web storage
  mode uses `SharedArrayBuffer`, which needs both COOP and COEP, but it picks
  its mode by what the browser offers and falls back to OPFS in a dedicated
  worker, then IndexedDB. The app needs neither SharedArrayBuffer nor
  isolation: COEP would block the cover images from Open Library unless they
  sent CORP headers. COOP `same-origin` is set and is harmless.
- Caching: `no-cache` (revalidate with ETag) for everything except the icons,
  which get a day. Flutter doesn't content-hash file names, so long `max-age`
  would strand visitors on stale or mismatched files (the app's `sqlite3.wasm`
  must match its Dart code). An unchanged file costs a 304.
- **Barcode scanning on the web** (`mobile_scanner` 7.5, read from its source,
  not run in a browser): it uses the browser's built-in `BarcodeDetector`
  where there is one (Chrome, Edge, Safari), which needs no download. Where
  there isn't one (notably Firefox), the plugin tries to load a ZXing script
  from `unpkg.com` / `cdn.jsdelivr.net`. The CSP (`script-src 'self'`) **blocks
  that on purpose**, so on those browsers camera scanning will not start and
  people must type the ISBN or search by title. That keeps the "no third-party
  requests" promise. To support them, vendor the ZXing script into `web/`
  and serve it from the same origin; the plugin has no option to point at it,
  so that means a plugin fork or a patch. Check the scan screen's error state
  in Firefox before release.

## Install to home screen: manual checks

I could not run these:
- **Android Chrome**: open the site, menu > Install app (or the install banner).
  The icon should be the maskable book on terracotta, with the splash on ivory.
  Open it offline once after a first visit.
- **iOS Safari**: Share > Add to Home Screen. iOS uses `icons/Icon-192.png`
  (and `apple-touch-icon` if the page declares one; check `web/index.html`).
  The app opens full screen without Safari's bar.
- **Lighthouse** (Chrome DevTools > Lighthouse > PWA/Installable) to see why
  an install prompt isn't offered. Note Flutter's service worker is gone in
  current Flutter, so offline start relies on the browser cache and storage;
  check what you get with the network off.

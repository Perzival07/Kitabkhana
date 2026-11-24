# Releasing Kitabkhana

A release is a tag. `.github/workflows/release.yml` then checks, builds, uploads
and publishes. **The workflow has never run**: it was written without access to
Android, Xcode, Play, App Store Connect or Cloudflare, so expect a few fixes on
the first tag. Try it first with a throwaway tag such as `v0.0.1` before 1.0.0.

## One-time setup

Only the Android signing key is required. The Play upload, the iOS job and the
Cloudflare deploy each **skip themselves when their secrets are missing**, so a
tag always produces a GitHub Release with a signed APK
(`releases/latest/download/kitabkhana.apk`, linked from the README). The upload
key was created on 2026-11-24 and its four `ANDROID_*` secrets are set; the
keystore must be backed up outside the repository, because every future APK
and AAB has to be signed with it.

Do these once; the details are in the linked files.

1. **Android**: upload keystore and Play Console app (docs/ANDROID_RELEASE.md).
   Do the first upload by hand in the Play Console; the API can only update an
   app that already exists. Create a Google Cloud service account with Play
   Console access ("Release manager") and download its JSON key.
2. **iOS**: Apple Developer account, App Store Connect app record, Xcode
   flavors and the `prod` scheme, App Store Connect API key (docs/IOS_RELEASE.md,
   docs/IOS_FLAVORS.md).
3. **Web**: a Cloudflare Pages project named `kitabkhana` (docs/WEB_RELEASE.md).
4. **Privacy policy** hosted at a public URL (docs/privacy/index.html).
5. GitHub repository secrets (Settings > Secrets and variables > Actions):

| Secret | What |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `base64 < kitabkhana-upload.jks` |
| `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | the keystore's values |
| `PLAY_SERVICE_ACCOUNT_JSON` | the service account's JSON, as plain text |
| `ASC_KEY_ID`, `ASC_ISSUER_ID` | from App Store Connect > Integrations |
| `ASC_KEY_CONTENT` | `base64 < AuthKey_XXXX.p8` |
| `APPLE_TEAM_ID` | Developer team ID |
| `CLOUDFLARE_API_TOKEN` | token with "Cloudflare Pages: Edit" |
| `CLOUDFLARE_ACCOUNT_ID` | the account's ID |

Keep the real keystore and `.p8` out of the repository and back them up
separately. Use a GitHub **environment** with required reviewers for `release`
if more than one person can push tags.

## Cutting a release

1. **Is main ready?** CI is green on `main`. Run the manual regression
   (docs/QA.md, and the release regression in prompt.txt Part E) on a low-end
   and a recent Android phone and, if you have one, an iPhone. A release build
   (R8) can break what debug builds don't, so test a **release** build.
2. **Version**: edit `version:` in `pubspec.yaml` to `X.Y.Z+N`. The workflow
   sets the name from the tag and the build number from the run number
   (always rising), so the `+N` there only matters for local builds.
3. **Store text**: update `docs/store/release_notes.md` (the "What's new") and
   regenerate screenshots if the UI changed (docs/store/README.md).
4. **Commit and tag**:

   ```
   git commit -am "chore(release): 1.0.0"
   git tag v1.0.0
   git push origin main v1.0.0
   ```
5. **Watch the workflow.** Order: `ci` (format, analyze, all tests, builds), then
   `android`, `ios` and `web` in parallel, then `github-release`. Any failure
   stops the GitHub Release; the other jobs may already have shipped (web is
   live as soon as its job is done), so check which ones ran.
6. **Result**: the signed AAB is on the Play **internal** track, the IPA is in
   TestFlight (processing takes some minutes), the web app is live, and a GitHub
   Release has the changelog, `kitabkhana.apk` (signed, installable),
   the AAB and `kitabkhana-web.zip`. The changelog is
   from conventional commits (`tool/changelog.sh`): `feat`, `fix` and `perf`
   become sections, `test` and `docs` are left out.
7. **Test the uploaded builds** from the Play internal link and TestFlight on
   real devices. Check scan, quote capture, backup and restore, a notification.
8. **Promote** (below), writing the store "What's new" from the changelog.

If you push a tag by mistake: delete it (`git push --delete origin v1.0.0`,
`git tag -d v1.0.0`) and the GitHub Release; uploaded Play and TestFlight builds
cannot be removed, only superseded, which is why a new tag needs a new build
number (automatic).

## Staged rollout

**Android (Play Console)**
1. Test on internal, then promote the same bundle to **closed testing** (a new
   personal account must keep 12 testers for 14 days before production:
   docs/ANDROID_RELEASE.md).
2. Production > Create release (or promote) > set **rollout 10%**.
3. Watch Android vitals and crashes (Play Console > Quality) and reviews for
   2 to 3 days. Look at crash-free users and ANR rate against the thresholds
   shown there; fix the ones you can before widening.
4. Production > Manage release > **Update rollout** to 50%, watch again, then 100%.

**iOS**: after review passes, use **Phased Release for Automatic Updates** (App
Store Connect > the version > Phased Release): 7 days, 1% to 100%. You can pause
it for up to 30 days, or release to everyone at any point.

**Web**: it is deployed immediately to everyone; Cloudflare keeps each
deployment, so a bad one is fixed by rolling back (below).

## Halting and rolling back

- **Android, stop a staged rollout**: Play Console > Production > Releases >
  **Halt rollout**. People who already updated keep the new version; nobody new
  gets it. Fix forward: build a new version with a higher build number (a new
  tag) and roll it out. You can't make Google go back to the older bundle for
  people who have the new one, so a fix is a new, higher-numbered release.
- **iOS**: App Store Connect > Phased Release > **Pause**. To stop people
  getting a bad version altogether, remove the version from sale, then submit a
  fixed build. There is no "roll back" for already updated users either.
- **Web**: Cloudflare Pages > the project > Deployments > pick the last good
  deployment > **Rollback**. Users get it on their next load (files revalidate).
- **Data safety**: the app only changes local data on a user's device. Before
  shipping a database migration, the app takes a safety backup. If a release
  ever corrupts data, say so in the store listing and the Release page and
  point people to the `.kitab` backup restore.
- Record what happened in `BUILD_LOG.md` and, if it's a lesson, add a test.

## Not verified yet

The workflow YAML parses and the changelog script runs; nothing else here has
been executed. The first real run will tell. Likely snags: the iOS `prod`
scheme not existing yet, the `r0adkll/upload-google-play` inputs, R8 keep rules
(see docs/ANDROID_RELEASE.md), and Play rejecting an AAB uploaded through the
API before an initial manual upload.

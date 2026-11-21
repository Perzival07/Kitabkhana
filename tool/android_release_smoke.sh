#!/usr/bin/env bash
# Installs the minified release APK on the running emulator, launches it, and
# fails if it crashes. R8 can break reflection-based plugins in ways debug
# builds never show, so this is the first check that the shrunk app starts.
#   tool/android_release_smoke.sh build/app/outputs/flutter-apk/app-prod-release.apk
set -uo pipefail

apk="${1:?path to the release apk}"
pkg="com.kitabkhana.kitabkhana"

adb install -r "$apk" || { echo "install failed"; exit 1; }
adb logcat -c
adb shell pm grant "$pkg" android.permission.POST_NOTIFICATIONS 2>/dev/null || true
adb shell monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 >/dev/null

# Give start-up (database open, migrations, onboarding) time to finish.
sleep 25

status=0
if [ -z "$(adb shell pidof "$pkg" | tr -d '\r')" ]; then
  echo "FAIL: the app is not running after launch"
  status=1
fi

adb logcat -d > release-smoke-logcat.txt
if grep -E "FATAL EXCEPTION|AndroidRuntime: Process: $pkg|ClassNotFoundException|NoSuchMethodError|NoSuchFieldError|Missing type parameter|UnsatisfiedLinkError" release-smoke-logcat.txt; then
  echo "FAIL: crash or missing class in the log (see release-smoke-logcat.txt)"
  status=1
fi

adb shell screencap -p /sdcard/smoke.png && adb pull /sdcard/smoke.png release-smoke.png >/dev/null 2>&1 || true
[ $status -eq 0 ] && echo "release smoke test passed"
exit $status

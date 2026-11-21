# R8 / ProGuard rules for release builds. Flutter's own rules are added by the
# Flutter Gradle plugin; these cover what the plugins need.

# ML Kit text recognition. The Latin recognizer is the only one bundled, but
# the plugin's Java code references the optional Chinese, Japanese, Korean and
# Devanagari option classes. They are absent on purpose, so R8 must not fail on
# the missing references.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ML Kit and Google Play services find their components by name at runtime.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_latin.** { *; }

# Keep readable stack traces in the Play Console's crash reports; the mapping
# file is uploaded with the bundle.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# sqlite3 (Drift) loads its native library through JNI.
-keep class org.sqlite.** { *; }

# flutter_local_notifications keeps scheduled reminders as JSON through Gson
# and reads them back by reflection (also after a reboot). The plugin ships no
# rules of its own, and R8 renaming its classes or stripping generic type
# information breaks scheduling in release builds ("Missing type parameter").
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload-key signing: android/key.properties is gitignored (see docs/RELEASING.md
// for the keytool command). CI writes it from secrets. Without it, release
// builds are signed with the debug key so `flutter run --release` still works
// locally, but they are not uploadable; the release check below refuses them.
val keyProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val hasReleaseKey = keyProperties.containsKey("storeFile")

android {
    namespace = "com.kitabkhana.kitabkhana"
    // Plugins (notifications, permissions) and AndroidX 1.19 require compiling
    // against Android 37, newer than Flutter's default; targetSdk is unchanged.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.kitabkhana.kitabkhana"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        resValues = true
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Kitabkhana Dev")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Kitabkhana")
        }
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // R8 code shrinking and obfuscation, and resource shrinking.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    // Snap-a-Quote reads Hindi and other Devanagari text (the plugin only
    // declares it compileOnly). The model is bundled, so it works offline.
    implementation("com.google.mlkit:text-recognition-devanagari:16.0.1")
}

// A production bundle must carry the upload key. Fail early rather than let a
// debug-signed bundle reach the Play Console, which rejects it late.
tasks.matching { it.name.startsWith("bundleProd") && it.name.endsWith("Release") }
    .configureEach {
        doFirst {
            check(hasReleaseKey) {
                "android/key.properties is missing: create the upload keystore first (docs/RELEASING.md)."
            }
        }
    }

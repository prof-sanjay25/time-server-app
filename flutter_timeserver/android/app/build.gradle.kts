plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "app.timeserver"
    compileSdk = flutter.compileSdkVersion
    // Pinned to the highest NDK required by the plugins (backward compatible).
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "app.timeserver"
        // minSdk 24 — matches the original app (new time/location APIs).
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = 10
        versionName = "1.0.30"
    }

    buildTypes {
        release {
            // Debug signing so `flutter run --release` works out of the box.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

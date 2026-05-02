import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.interslavic.interslavic_learn"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.interslavic.interslavic_learn"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias") ?: ""
                keyPassword = keystoreProperties.getProperty("keyPassword") ?: ""
                storePassword = keystoreProperties.getProperty("storePassword") ?: ""
                val storePath = keystoreProperties.getProperty("storeFile")
                if (!storePath.isNullOrBlank()) {
                    storeFile = file(storePath)
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

// После release-сборки: app-release.apk → learn_interslavic_<versionName>.apk (versionName из pubspec.yaml).
afterEvaluate {
    tasks.named("assembleRelease").configure {
        doLast {
            val flutterRoot = rootProject.projectDir.parentFile!!
            val apkDir = File(flutterRoot, "build/app/outputs/flutter-apk")
            val pubspec = File(flutterRoot, "pubspec.yaml")
            if (!pubspec.exists()) return@doLast
            val versionLine =
                pubspec.readLines().firstOrNull { it.trimStart().startsWith("version:") }
                    ?: return@doLast
            val versionName =
                versionLine.substringAfter(":").trim().substringBefore("+").trim()
            if (versionName.isEmpty()) return@doLast
            val from = File(apkDir, "app-release.apk")
            val to = File(apkDir, "learn_interslavic_${versionName}.apk")
            if (from.exists()) {
                if (to.exists()) to.delete()
                check(from.renameTo(to)) {
                    "Не удалось переименовать APK в ${to.name}"
                }
            }
        }
    }
}

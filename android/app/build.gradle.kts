plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hedon_haven.viewer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.hedon_haven.viewer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("debug") {
            // 使用 Android 默认的 debug.keystore，无需任何私有密钥
            signingConfig = signingConfigs.getByName("debug")
            applicationIdSuffix = ".debug"
            manifestPlaceholders["appName"] = "享乐港湾（调试）"
        }
        getByName("release") {
            // 使用 Android 默认的 debug.keystore 签名，任何人都能本地构建安装。
            // 注意：这是调试签名，不能用于 Google Play 上架；自用安装完全没问题。
            signingConfig = signingConfigs.getByName("debug")
            manifestPlaceholders["appName"] = "享乐港湾"
        }
        getByName("profile") {
            manifestPlaceholders["appName"] = "享乐港湾（Profile）"
        }
    }

    // Disable Google's encrypted dependency metadata blob
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
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

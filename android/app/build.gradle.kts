plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin Android + Kotlin’den sonra gelmeli
    id("dev.flutter.flutter-gradle-plugin")
    // ✅ Firebase Google Services plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.mioteays"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.mioteays" // ✅ Firebase ile aynı olmalı
        minSdk = 23 // ✅ minSdk en az 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Kendi imza ayarlarını ekle (şu an debug ile imzalıyor)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

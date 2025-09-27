plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter SIEMPRE después de los de Android/Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.kavid.kavid"

    // Toma compileSdk/ndk de Flutter (están definidos por el plugin)
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Java/Kotlin 11
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.kavid.kavid"

        // ⚠️ Forzamos 21 para MLKit + camera
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // Lee versión desde pubspec.yaml (flutter.versionCode/name lo rellena el plugin)
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Si usas multidex más adelante:
        // multiDexEnabled = true
    }

    buildTypes {
        release {
            // Usa firma debug por ahora para que `flutter run --release` funcione
            signingConfig = signingConfigs.getByName("debug")
            // Si necesitas shrinker:
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

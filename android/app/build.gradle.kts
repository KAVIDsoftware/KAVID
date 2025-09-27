plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter SIEMPRE después de los de Android/Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.kavid.kavid"

    // Toma compileSdk/ndk de Flutter (definidos por el plugin)
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // === Java/Kotlin 17 + Desugaring ===
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.kavid.kavid"

        // Min/Target desde Flutter (asegura minSdk >= 21)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // Lee versión desde pubspec.yaml (lo rellena el plugin)
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Si en el futuro necesitas multidex:
        // multiDexEnabled = true
    }

    buildTypes {
        release {
            // Firma debug para poder ejecutar release local
            signingConfig = signingConfigs.getByName("debug")
            // Si algún día activas shrinker:
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// === Desugar JDK libs para Java APIs usadas por plugins como flutter_local_notifications ===
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

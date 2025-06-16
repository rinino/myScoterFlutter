plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myscoterflutter"
    compileSdk = flutter.compileSdkVersion
    // FIX: Specifica la versione NDK richiesta dai tuoi plugin.
    // L'errore ha indicato "27.0.12077973" come la versione più alta richiesta.
    ndkVersion = "27.0.12077973" // <--- RIGA CORRETTA

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.myscoterflutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // NUOVO: Definizione dei signingConfigs in Kotlin DSL
    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("FLUTTER_KEYSTORE") ?: (project.properties["storeFile"] as String?))
            storePassword = System.getenv("FLUTTER_KEYSTORE_PASSWORD") ?: (project.properties["storePassword"] as String?)
            keyAlias = System.getenv("FLUTTER_KEY_ALIAS") ?: (project.properties["keyAlias"] as String?)
            keyPassword = System.getenv("FLUTTER_KEY_PASSWORD") ?: (project.properties["keyPassword"] as String?)
        }
    }

    buildTypes {
        release {
            // FIX: Associa la configurazione di firma 'release' a questo build type.
            signingConfig = signingConfigs.getByName("release") // Usa getByName("nome_config")
            // Queste ottimizzazioni sono consigliate per i build di release
            isShrinkResources = true // In Kotlin DSL si usa 'is' per i booleani
            isMinifyEnabled = true   // In Kotlin DSL si usa 'is' per i booleani
            // Il file proguard-rules.pro serve per configurare la minificazione (se necessaria per librerie specifiche)
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro") // Parentesi per la funzione e virgola
        }
    }
}

flutter {
    source = "../.."
}
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// CARICAMENTO PROPRIETÀ
val keystoreProperties = Properties()
// rootProject.file punta alla cartella /android del tuo progetto
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    println("DEBUG: File key.properties trovato in: ${keystorePropertiesFile.absolutePath}")
} else {
    println("DEBUG: ATTENZIONE! File key.properties NON TROVATO in: ${keystorePropertiesFile.absolutePath}")
}

android {
    namespace = "it.adr.myscooter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "it.adr.myscooter"

        minSdk = flutter.minSdkVersion // Android 6.0 (Garantisce massima compatibilità con Firebase e NDK)
        targetSdk = 34 // Requisito obbligatorio Google Play Store per i rilasci

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val sFile = keystoreProperties.getProperty("storeFile")
            if (sFile != null) {
                val keystoreFile = file(sFile)
                if (keystoreFile.exists()) {
                    storeFile = keystoreFile
                    storePassword = keystoreProperties.getProperty("storePassword")?.trim()
                    keyAlias = keystoreProperties.getProperty("keyAlias")?.trim()
                    keyPassword = keystoreProperties.getProperty("keyPassword")?.trim()
                    println("DEBUG: Keystore caricato correttamente: ${keystoreFile.absolutePath}")
                } else {
                    println("DEBUG: ERRORE! Il file .jks non esiste al percorso: ${keystoreFile.absolutePath}")
                }
            } else {
                println("DEBUG: ERRORE! La proprietà 'storeFile' è assente nel file key.properties")
            }
        }
    }

    buildTypes {
        release {
            // Associa la firma creata sopra
            signingConfig = signingConfigs.getByName("release")

            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

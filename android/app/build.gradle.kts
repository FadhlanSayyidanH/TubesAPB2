import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// UNTUK APA: mengambil kunci Google Maps dari file local.properties. Kunci tidak
// ditulis langsung di sini supaya tidak ikut terunggah ke git (rahasia).
val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val mapsApiKey: String = localProperties.getProperty("MAPS_API_KEY") ?: ""

// UNTUK APA: mengambil data keystore (kunci penanda tangan APK rilis) dari file
// key.properties. File ini berisi password sehingga sengaja tidak masuk git.
// hasReleaseSigning = penanda apakah file kunci tersedia di komputer ini.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseSigning = rootProject.file("key.properties").exists()

android {
    namespace = "com.smartattendance.smart_attendance"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // UNTUK APA: notifikasi terjadwal (reminder absen) memakai fitur tanggal/
        // waktu Java modern. Baris ini membuatnya tetap jalan di Android lama (minSdk 23).
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Identitas unik aplikasi di Play Store / perangkat. Jangan diubah setelah rilis.
        applicationId = "com.smartattendance.smart_attendance"
        // minSdk dipaksa minimal 23 karena Firebase Auth tidak jalan di bawah itu.
        minSdk = maxOf(23, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        // Nomor versi aplikasi diambil dari pubspec.yaml (mis. 1.0.0+1).
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Menyisipkan kunci Google Maps ke AndroidManifest saat build.
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    // UNTUK APA: mendaftarkan kunci penanda tangan APK rilis (dari key.properties).
    // Hanya didaftarkan bila file kuncinya ada di komputer ini.
    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // UNTUK APA: memilih kunci penanda tangan untuk build rilis. Jika kunci
            // rilis tersedia pakai itu; jika tidak, pakai kunci debug agar build tetap
            // bisa jalan di komputer lain yang belum punya keystore.
            signingConfig = if (hasReleaseSigning) {
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

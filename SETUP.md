# Setup — Smart Absen

Panduan menyiapkan Firebase agar aplikasi (login email/NIK, absen, admin) bisa langsung
dijalankan.

## 1. Hubungkan project ke Firebase

```bash
# Sekali saja di mesin Anda
dart pub global activate flutterfire_cli
npm install -g firebase-tools   # jika belum ada
firebase login

# Di root project ini — akan men-generate lib/firebase_options.dart
flutterfire configure
```

Pilih/buat Firebase project, centang platform **Android** (dan iOS bila perlu).
Perintah ini menimpa `lib/firebase_options.dart` placeholder dengan kredensial asli
dan menaruh `google-services.json` di `android/app/`.

## 2. Aktifkan layanan di Firebase Console

- **Authentication → Sign-in method → Email/Password**: aktifkan.
- **Firestore Database**: buat database (mode production).
- Deploy aturan keamanan dari `firestore.rules`:

```bash
firebase deploy --only firestore:rules
```

## 3. Buat akun uji

Login butuh user di Firebase Auth **dan** dokumen profil di `/users/{uid}`.

1. Authentication → Users → **Add user** (mis. `budi@perusahaan.com` / `rahasia123`).
   Salin **UID** yang dihasilkan.
2. Firestore → koleksi `users` → buat dokumen dengan **ID = UID tadi**:

```jsonc
// /users/{uid}  — karyawan
{
  "uid": "<uid-dari-langkah-1>",
  "name": "Budi Santoso",
  "email": "budi@perusahaan.com",
  "nik": "3273012501900001",
  "role": "employee",
  "department": "Operasional",
  "photoUrl": ""
}
```

Untuk akun admin, ulangi dengan `"role": "admin"`.

## 4. Jalankan

```bash
flutter run
```

- Login dengan **email** `budi@perusahaan.com` atau **NIK** `3273012501900001`.
- `role: employee` → diarahkan ke `/dashboard`; `role: admin` → `/admin`.
- "Ingat saya" menyimpan identifier terakhir (bukan password) untuk pre-fill.

## 5. Buat dokumen kantor (untuk validasi radius GPS)

Absen masuk/pulang memvalidasi posisi terhadap kantor. Buat satu dokumen di koleksi
`offices` (ID bebas, mis. `kantor-pusat`):

```jsonc
// /offices/{id}
{
  "name": "Telkom University",
  "address": "Jl. Telekomunikasi No. 1, Terusan Buah Batu, Bojongsoang, Bandung",
  "location": { "_latitude": -6.974028, "_longitude": 107.630529 }, // GeoPoint
  "radius": 500   // meter
}
```

Sesuaikan `location` & `radius` ke lokasi Anda agar status "Dalam Area" muncul saat
pengujian.

## Build rilis (opsional)

Untuk menandatangani APK rilis sendiri, buat keystore lalu isi `android/key.properties`
(keduanya **tidak** ikut di repo):

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

```properties
# android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=upload-keystore.jks
```

Tanpa file ini, `flutter build apk --release` jatuh ke debug signing agar tetap jalan.

## Catatan konfigurasi

- `android/app/build.gradle.kts`: `minSdk` dinaikkan ke **23** (syarat Firebase Auth 6.x).
- Status "telat" bila clock-in setelah **08:30** (lihat `AppConfig`).
- Peta Google dinonaktifkan secara default (`AppConfig.mapsEnabled = false`); aktifkan
  Maps SDK for Android di GCP lalu set `true` bila ingin peta tampil.

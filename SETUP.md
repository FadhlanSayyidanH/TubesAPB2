# Setup — Smart Attendance (Hari 1–2)

Panduan menyiapkan Firebase agar login (email/NIK) bisa langsung didemo.

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

## Catatan konfigurasi

- `android/app/build.gradle.kts`: `minSdk` dinaikkan ke 23 (syarat Firebase Auth 5.x).
- Koordinat kantor default untuk modul GPS (Hari 3): **-6.2088, 106.8456** (Jakarta),
  radius **500 m**. Status "telat" bila clock-in setelah **08:30**.
- Buat dokumen `/offices/{id}` dengan field `location` (GeoPoint), `radius` (500),
  `name`, `address` saat mulai Hari 3.

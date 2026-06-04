# Smart Absen

Aplikasi absensi karyawan berbasis lokasi (radius kantor via GPS) dengan verifikasi
wajah, riwayat, notifikasi, dan panel admin real-time. Dibangun dengan Flutter +
Firebase mengikuti Clean Architecture.

## Fitur

- **Autentikasi** — login email atau NIK, "Ingat saya", lupa sandi, routing per peran
  (karyawan / admin) + guard rute.
- **Absen masuk/pulang** — validasi radius kantor (Haversine), status telat (> 08:30),
  durasi kerja otomatis, gerbang verifikasi wajah saat absen masuk (ML Kit).
- **Dashboard karyawan** — kartu hari ini, ringkasan mingguan (ring % + tile), pengajuan
  izin/cuti.
- **Riwayat** — filter status, paginasi, detail + selfie.
- **Profil** — ubah nama & foto, ganti sandi, kartu karyawan.
- **Notifikasi** — token FCM tersimpan + notifikasi lokal (sukses absen, reminder 08:00
  & 17:00 WIB).
- **Panel admin** — KPI kehadiran real-time (stream Firestore), grafik tren & distribusi
  jam (fl_chart), kelola karyawan + ubah peran, ekspor laporan CSV.
- **Lain-lain** — mode gelap, dwibahasa (Indonesia/Inggris), banner offline global.

## Stack

- **Flutter** (stable) / **Dart**, target utama Android.
- **Firebase**: Auth (Email/Password), Cloud Firestore, Messaging.
- **State**: flutter_bloc · **DI**: get_it · **Navigasi**: go_router.
- Lain: geolocator, google_maps_flutter, camera + google_mlkit_face_detection,
  dartz (`Either`), intl, fl_chart, shimmer, google_fonts.

## Struktur proyek

```
lib/
├── core/                  # lintas-fitur: konstanta, error, network, router,
│   │                      #   services, settings, utils, widgets
│   ├── constants/         #   warna, teks, tema, string (i18n), konfigurasi
│   ├── errors/            #   Exception (data) & Failure (siap-tampil)
│   ├── network/           #   ConnectivityCubit, NetworkInfo
│   ├── router/            #   go_router + guard peran
│   ├── services/          #   notifikasi lokal, FCM token, ekspor CSV
│   ├── settings/          #   SettingsCubit (tema & bahasa, persist)
│   ├── utils/             #   haversine, validators, image_encoder, dst.
│   └── widgets/           #   widget bersama (banner offline, tombol)
├── features/              # per-fitur, Clean Architecture
│   └── <fitur>/           #   auth · attendance · face · profile · admin
│       ├── data/          #     datasources, models, repositories (impl)
│       ├── domain/        #     entities, repositories (abstrak), usecases
│       └── presentation/  #     bloc, pages, widgets
├── injection_container.dart   # registrasi dependency (get_it)
└── main.dart

test/                      # cermin struktur lib (core/ + features/<fitur>/)
tool/                      # skrip dev (generator ikon)
assets/                    # ikon & animasi Lottie
```

**Pola error:** datasource lempar `Exception` → repository tangkap & map ke `Failure`
→ kembalikan `Either<Failure, T>` (dartz) ke presentation. Pesan `Failure` sudah
siap-tampil dalam Bahasa Indonesia.

## Dokumentasi teknis

Detail arsitektur, skema data, dan kontrak API ada di folder **[docs/](docs/)**:

- **[Arsitektur](docs/ARSITEKTUR.md)** — lapisan, aliran data, state, DI, navigasi.
- **[ER Diagram](docs/ER_DIAGRAM.md)** — skema Firestore & relasi antar koleksi.
- **[API & Kontrak Data](docs/API.md)** — repository contract, operasi Firestore, keamanan.

## Mulai

Lihat **[SETUP.md](SETUP.md)** untuk menyambungkan Firebase, mengaktifkan layanan, dan
membuat akun uji. Ringkasnya:

```bash
flutter pub get
flutter run            # jalankan di perangkat/emulator
flutter test           # unit test
flutter analyze        # analisis statis
```

Prasyarat: Flutter SDK (channel stable) & Android SDK terpasang. Jalankan
`flutter doctor` untuk memastikan toolchain siap.

## Pengujian

Logika inti diuji sebagai fungsi murni (tanpa Firebase): validator input, jarak
Haversine, ringkasan mingguan, kualitas wajah, statistik admin, baris CSV, dan
paginasi/filter riwayat.

```bash
flutter test
```

## Build rilis

```bash
flutter build apk --release
```

Penandatanganan rilis membaca `android/key.properties` (tidak masuk repo). Bila file
tidak ada, build jatuh ke debug signing agar tetap jalan di mesin lain. Lihat
[SETUP.md](SETUP.md) untuk membuat keystore rilis sendiri.

## Catatan & batasan

Proyek ini berjalan di Firebase paket **Spark (gratis)**, jadi beberapa keputusan
desain menyesuaikan:

- **Selfie disimpan base64 di Firestore**, bukan Firebase Storage (Storage butuh paket
  Blaze). Foto dikompres (sisi terpanjang ≤ 800px, JPEG q70 → ~40KB) ke field
  `selfieUrl`. Untuk pindah ke Storage: aktifkan Storage lalu ganti pemanggil
  `ImageEncoder` di repository menjadi upload Storage.
- **Peta Google dinonaktifkan** (`AppConfig.mapsEnabled = false`) karena Maps SDK belum
  diaktifkan di GCP. Halaman absen memakai fallback `MapUnavailableView`. Lihat SETUP
  untuk mengaktifkan.
- **Push notification** masih lokal di perangkat. Token FCM sudah disimpan di Firestore;
  push terjadwal dari server (Cloud Functions) butuh paket Blaze.

### Kredensial Firebase di repo

`lib/firebase_options.dart` dan `android/app/google-services.json` sengaja ikut di repo
agar bisa langsung di-clone & dijalankan. API key di dalamnya adalah konfigurasi klien
Firebase — **bukan rahasia**; keamanan ditegakkan lewat aturan Firestore
(`firestore.rules`), bukan dengan menyembunyikan key. Keystore rilis & password
(`android/key.properties`, `*.jks`) tetap di-_gitignore_ dan tidak diunggah.

## Lisensi

Dirilis di bawah Lisensi **MIT** — lihat [LICENSE](LICENSE).

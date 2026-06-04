# API & Kontrak Data — Smart Absen

Aplikasi ini **tidak punya REST API kustom**. "API"-nya terdiri dari dua lapis:

1. **Kontrak domain (repository)** — antarmuka yang dipakai presentation lewat
   usecase. Semua mengembalikan `Either<Failure, T>` (atau `Stream`).
2. **Operasi data Firestore** — query/mutasi konkret yang dijalankan datasource,
   diatur oleh **aturan keamanan Firestore**.

Konvensi:
- Sukses → `Right(T)`. Gagal → `Left(Failure)` dengan pesan **siap-tampil
  (Bahasa Indonesia)**.
- Datasource melempar `Exception` (`core/errors/exceptions.dart`); repository
  memetakannya ke `Failure` (`core/errors/failures.dart`).

---

## 1. Auth API (`AuthRepository`)

| Method | Signature | Keterangan |
|---|---|---|
| Login | `login({String identifier, String password}) → Either<Failure, UserEntity>` | `identifier` = email **atau** NIK. NIK ditukar ke email via query `/users` sebelum sign-in Firebase Auth. |
| Logout | `logout() → Either<Failure, void>` | Akhiri sesi Firebase Auth. |
| User aktif | `getCurrentUser() → Either<Failure, UserEntity?>` | `null` bila belum login. |
| Lupa sandi | `sendPasswordResetEmail(String email) → Either<Failure, void>` | Email reset dari Firebase Auth. |
| Ubah profil | `updateProfile({String uid, String name, String? photoPath}) → Either<Failure, UserEntity>` | Foto (bila ada) dikompres → data URI base64 → field `photoUrl`. Mengembalikan profil terbaru. |
| Ganti sandi | `changePassword({String currentPassword, String newPassword}) → Either<Failure, void>` | Re-autentikasi dgn sandi lama dulu (syarat Firebase untuk operasi sensitif). |
| Stream auth | `authStateChanges → Stream<String?>` | Emit `uid` saat login, `null` saat logout. |

**Firestore/Auth yang disentuh:** Firebase Auth (signIn/signOut/reset/reauth/
updatePassword) + read/write `/users/{uid}`.

**Failure khusus:** kredensial salah, user tak ditemukan, sandi lama salah,
sandi lemah, `requires-recent-login`, tidak ada internet.

---

## 2. Attendance API (`AttendanceRepository`)

| Method | Signature | Keterangan |
|---|---|---|
| Kantor utama | `getPrimaryOffice() → Either<Failure, OfficeEntity>` | Baca office acuan radius. |
| Status lokasi | `getLocationStatus(OfficeEntity office) → Either<Failure, LocationStatus>` | Posisi GPS + jarak (Haversine) + dalam/luar radius. |
| Absen hari ini | `getTodayAttendance(String userId) → Either<Failure, AttendanceEntity?>` | `null` bila belum absen. |
| Absen masuk | `clockIn({UserEntity user, LocationStatus location, String selfiePath}) → Either<Failure, AttendanceEntity>` | Selfie diproses **dulu** → base64, lalu tulis dokumen. Status hadir/telat dari jam. |
| Absen pulang | `clockOut({AttendanceEntity today, LocationStatus location}) → Either<Failure, AttendanceEntity>` | Isi `clockOut`, lokasi pulang, `workDuration`. |
| Riwayat minggu | `getWeekAttendance(String userId) → Either<Failure, List<AttendanceEntity>>` | Senin–Minggu, untuk weekly stats. |
| Riwayat penuh | `getAttendanceHistory(String userId) → Either<Failure, List<AttendanceEntity>>` | Urut terbaru; difilter/dipaginasi di klien. |
| Ajukan izin | `submitLeave({UserEntity user, DateTime date, String reason}) → Either<Failure, AttendanceEntity>` | Langsung tercatat `izin`. Gagal bila tanggal sudah ada catatan. |

**Operasi Firestore konkret:**

| Aksi | Operasi |
|---|---|
| Baca absen hari ini | `get(/attendance/{uid}_{date})` |
| Tulis clock-in | `set(/attendance/{uid}_{date}, toClockInMap())` (cek belum ada) |
| Update clock-out | `update(/attendance/{uid}_{date}, {clockOut, clockOutLocation, workDuration})` |
| Riwayat | `where('userId', isEqualTo: uid)` → sort `clockIn` desc (klien) |
| Izin | `set(/attendance/{uid}_{date}, toLeaveMap())` (cek bentrok → `AttendanceAlreadyExistsException`) |

---

## 3. Admin API (`AdminRepository`)

| Method | Signature | Keterangan |
|---|---|---|
| Pantau absensi | `watchAttendanceSince(String fromDate) → Stream<List<AttendanceEntity>>` | Real-time `snapshots()`; error stream diteruskan ke bloc. |
| Hitung karyawan | `getEmployeeCount() → Either<Failure, int>` | Aggregate `.count()` user role employee. |
| Absen rentang | `getAttendanceBetween(String fromDate, String toDate) → Either<Failure, List<AttendanceEntity>>` | Untuk laporan/ekspor CSV. |
| Semua user | `getAllUsers() → Either<Failure, List<UserEntity>>` | Manajemen karyawan. |
| Ubah peran | `updateUserRole(String uid, UserRole role) → Either<Failure, void>` | Set `role`. Self-block di UI. |

**Operasi Firestore konkret:**

| Aksi | Operasi |
|---|---|
| Stream monitoring | `where('date', isGreaterThanOrEqualTo: fromDate).snapshots()` |
| Hitung karyawan | `where('role', ==, 'employee').count()` |
| Laporan rentang | `where('date', >=, from).where('date', <=, to)` |
| Daftar user | `get(/users)` |
| Ubah peran | `update(/users/{uid}, {role})` |

`AdminRepositoryImpl` mengecek koneksi (`NetworkInfo`) di depan → offline
balikan `NetworkFailure` konsisten.

> **Catatan agregasi:** KPI dihitung oleh fungsi murni `computeAdminStats(records,
> totalEmployees, now)` di domain (di luar Firestore) — bukan endpoint server.

---

## 4. Model keamanan Firestore

Sumber kebenaran: [`firestore.rules`](../firestore.rules). Prinsip: **karyawan
hanya datanya sendiri; admin penuh.**

| Koleksi | read | create | update | delete |
|---|---|---|---|---|
| `/users/{uid}` | login (perlu untuk lookup NIK→email) | pemilik / admin | pemilik / admin | admin |
| `/attendance/{id}` | admin **atau** pemilik (`userId == auth.uid`) | login & `userId == auth.uid` | admin **atau** pemilik | admin |
| `/offices/{id}` | login | admin | admin | admin |

Helper rules: `isSignedIn()`, `isOwner(userId)`, `isAdmin()` (cek
`/users/{uid}.role == 'admin'`).

**Implikasi:** dokumen absensi hanya bisa **dibuat oleh pemiliknya** — admin tak
bisa membuat absen atas nama karyawan (hanya membaca/mengubah/menghapus).

---

## 5. Layanan eksternal & on-device

| Layanan | Dipakai untuk | Catatan |
|---|---|---|
| **Firebase Auth** | login email/NIK, reset, ganti sandi | Email/Password aktif |
| **Cloud Firestore** | seluruh data (users/attendance/offices) | Spark tier |
| **Cloud Messaging (FCM)** | simpan `fcmToken` ke `/users` | push server butuh Blaze |
| **Geolocator (GPS)** | posisi & validasi radius | refresh tiap 5 dtk di clock-in |
| **Camera + ML Kit Face Detection** | gerbang selfie clock-in | validasi wajah→pencahayaan→blur |
| **Local Notifications** | sukses absen + reminder 08:00 & 17:00 WIB | tz Asia/Jakarta |

---

## 6. Tipe & enum domain

```dart
enum UserRole { employee, admin }
enum AttendanceStatus { hadir, telat, izin, alpha }  // wireValue = name

// LocationStatus: userLatitude, userLongitude, distanceMeters, isWithinOfficeRadius
// AdminStats (fields): totalEmployees, clockedInToday, onTimeToday, lateToday,
//             onLeaveToday, last7Days[DailyAttendance{present, late}],
//             clockInHourCounts[24]
//   getter:   alphaToday, attendanceRate
```

`Failure` (abstract, `Equatable`) — pesan sudah Bahasa Indonesia siap-tampil:
`AuthFailure`, `NetworkFailure`, `ServerFailure`, `ProfileFailure`,
`LocationFailure`, `CameraFailure`, `FaceQualityFailure`.

Exception data layer (dipetakan ke Failure): `AuthException`,
`ProfileNotFoundException`, `NikNotFoundException`, `NoInternetException`,
`ServerException`, `LocationServiceDisabledException`,
`LocationPermissionDeniedException`, `OfficeNotConfiguredException`,
`AttendanceAlreadyExistsException`, `CameraPermissionDeniedException`,
`CameraUnavailableException`, dll.

Lihat juga: [ARSITEKTUR.md](ARSITEKTUR.md) · [ER_DIAGRAM.md](ER_DIAGRAM.md).

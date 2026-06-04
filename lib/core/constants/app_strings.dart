// Part of: Core - Constants

import 'app_locale.dart';

/// Semua teks UI dan pesan error dikumpulkan di sini sebagai getter
/// locale-aware via [AppLocale.pick] (ID default, EN bila aktif). Karena getter
/// (bukan const), teks ikut berganti saat bahasa diubah — termasuk di data
/// layer yang tak punya BuildContext. Widget memakai `Text(AppStrings.x)`
/// (tanpa const) agar selalu membaca bahasa terkini.
class AppStrings {
  const AppStrings._();

  // Identitas aplikasi
  static String get appName => 'Smart Attendance';
  static String get appTagline => AppLocale.pick(
    'Absensi cerdas berbasis lokasi & wajah',
    'Smart location & face based attendance',
  );

  // Login
  static String get loginTitle =>
      AppLocale.pick('Masuk ke akun Anda', 'Sign in to your account');
  static String get loginSubtitle => AppLocale.pick(
    'Gunakan email atau NIK yang terdaftar di HRD',
    'Use the email or ID number registered with HR',
  );
  static String get fieldIdentifierLabel =>
      AppLocale.pick('Email atau NIK', 'Email or ID number');
  static String get fieldIdentifierHint => AppLocale.pick(
    'nama@perusahaan.com atau 16 digit NIK',
    'name@company.com or 16-digit ID number',
  );
  static String get fieldPasswordLabel =>
      AppLocale.pick('Kata Sandi', 'Password');
  static String get fieldPasswordHint =>
      AppLocale.pick('Masukkan kata sandi', 'Enter your password');
  static String get rememberMe => AppLocale.pick('Ingat saya', 'Remember me');
  static String get forgotPassword =>
      AppLocale.pick('Lupa kata sandi?', 'Forgot password?');
  static String get loginButton => AppLocale.pick('Masuk', 'Sign In');
  static String get loginLoading =>
      AppLocale.pick('Memverifikasi akun...', 'Verifying your account...');

  // Forgot password
  static String get forgotPasswordTitle =>
      AppLocale.pick('Atur ulang kata sandi', 'Reset your password');
  static String get forgotPasswordSubtitle => AppLocale.pick(
    'Masukkan email terdaftar. Kami kirim tautan untuk membuat kata sandi baru.',
    'Enter your registered email. We will send a link to create a new password.',
  );
  static String get sendResetLink =>
      AppLocale.pick('Kirim Tautan Reset', 'Send Reset Link');
  static String get resetLinkSent => AppLocale.pick(
    'Tautan reset sudah dikirim. Cek inbox dan folder spam email Anda.',
    'A reset link has been sent. Check your inbox and spam folder.',
  );

  // Validasi form
  static String get identifierRequired => AppLocale.pick(
    'Email atau NIK wajib diisi',
    'Email or ID number is required',
  );
  static String get identifierInvalid => AppLocale.pick(
    'Format tidak dikenali. Masukkan email yang benar atau NIK 16 digit.',
    'Unrecognized format. Enter a valid email or a 16-digit ID number.',
  );
  static String get emailRequired =>
      AppLocale.pick('Email wajib diisi', 'Email is required');
  static String get emailInvalid => AppLocale.pick(
    'Format email tidak valid. Contoh: nama@perusahaan.com',
    'Invalid email format. Example: name@company.com',
  );
  static String get passwordRequired =>
      AppLocale.pick('Kata sandi wajib diisi', 'Password is required');
  static String get passwordTooShort => AppLocale.pick(
    'Kata sandi minimal 6 karakter',
    'Password must be at least 6 characters',
  );

  // Pesan error auth (actionable, bukan teknis)
  static String get errNikNotFound => AppLocale.pick(
    'NIK tidak terdaftar. Hubungi HRD untuk pendaftaran akun.',
    'ID number not registered. Contact HR to register an account.',
  );
  static String get errUserNotFound => AppLocale.pick(
    'Akun tidak ditemukan. Pastikan email atau NIK sudah benar.',
    'Account not found. Make sure the email or ID number is correct.',
  );
  static String get errWrongPassword => AppLocale.pick(
    'Kata sandi salah. Coba lagi atau gunakan "Lupa kata sandi?".',
    'Incorrect password. Try again or use "Forgot password?".',
  );
  static String get errInvalidEmail => AppLocale.pick(
    'Format email salah. Periksa kembali email Anda.',
    'Invalid email format. Please check your email.',
  );
  static String get errUserDisabled => AppLocale.pick(
    'Akun Anda dinonaktifkan. Hubungi HRD untuk info lebih lanjut.',
    'Your account is disabled. Contact HR for more information.',
  );
  static String get errTooManyRequests => AppLocale.pick(
    'Terlalu banyak percobaan. Tunggu beberapa menit lalu coba lagi.',
    'Too many attempts. Wait a few minutes and try again.',
  );
  static String get errNoInternet => AppLocale.pick(
    'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.',
    'No internet connection. Check your network and try again.',
  );
  static String get errProfileMissing => AppLocale.pick(
    'Data karyawan tidak ditemukan. Hubungi HRD untuk verifikasi akun.',
    'Employee data not found. Contact HR to verify your account.',
  );
  static String get errUnknown => AppLocale.pick(
    'Terjadi kesalahan. Coba lagi beberapa saat.',
    'Something went wrong. Please try again shortly.',
  );

  // Splash
  static String get splashLoading =>
      AppLocale.pick('Menyiapkan aplikasi...', 'Preparing the app...');

  // Umum
  static String get tryAgain => AppLocale.pick('Coba Lagi', 'Try Again');
  static String get cancel => AppLocale.pick('Batal', 'Cancel');
  static String get ok => AppLocale.pick('Oke', 'OK');

  // Konektivitas (banner global Hari 13)
  static String get offlineBanner => AppLocale.pick(
    'Tidak ada koneksi internet. Data mungkin belum diperbarui.',
    'No internet connection. Data may be out of date.',
  );

  // Lokasi & clock-in (Hari 3)
  static String get clockInTitle => AppLocale.pick('Absen Masuk', 'Clock In');
  static String get locating =>
      AppLocale.pick('Mencari lokasi Anda...', 'Finding your location...');
  static String get insideRadius =>
      AppLocale.pick('Dalam Area Kantor', 'Inside Office Area');
  static String get outsideRadius =>
      AppLocale.pick('Di Luar Area Kantor', 'Outside Office Area');
  static String get distanceToOffice =>
      AppLocale.pick('Jarak ke kantor', 'Distance to office');
  static String get openSettings =>
      AppLocale.pick('Buka Pengaturan', 'Open Settings');
  static String get enableGps => AppLocale.pick('Aktifkan GPS', 'Enable GPS');
  static String get clockInButton =>
      AppLocale.pick('Absen Sekarang', 'Clock In Now');
  static String get refreshLocation =>
      AppLocale.pick('Perbarui Lokasi', 'Refresh Location');

  static String get errLocationServiceOff => AppLocale.pick(
    'GPS tidak aktif. Nyalakan lokasi di pengaturan perangkat lalu coba lagi.',
    'GPS is off. Turn on location in your device settings and try again.',
  );
  static String get errLocationDenied => AppLocale.pick(
    'Izin lokasi ditolak. Aplikasi butuh lokasi untuk memverifikasi kehadiran.',
    'Location permission denied. The app needs location to verify attendance.',
  );
  static String get errLocationDeniedForever => AppLocale.pick(
    'Izin lokasi diblokir permanen. Buka Pengaturan aplikasi dan izinkan akses lokasi.',
    'Location permission permanently blocked. Open app Settings and allow location access.',
  );
  static String get errLocationTimeout => AppLocale.pick(
    'GPS tidak mendapatkan sinyal. Pastikan berada di ruang terbuka lalu coba lagi.',
    'GPS could not get a signal. Make sure you are in an open area and try again.',
  );
  static String get errOfficeNotConfigured => AppLocale.pick(
    'Lokasi kantor belum diatur. Hubungi admin untuk mengatur titik kantor.',
    'Office location has not been set. Contact the admin to configure the office point.',
  );
  static String get errServerUnreachable => AppLocale.pick(
    'Tidak dapat terhubung ke server. Periksa internet (coba ganti ke data seluler) lalu coba lagi.',
    'Cannot reach the server. Check your internet (try switching to mobile data) and try again.',
  );

  static String outsideRadiusDialog(String distance) => AppLocale.pick(
    'Anda berada $distance dari kantor, di luar radius yang diizinkan. '
        'Mendekatlah ke area kantor untuk bisa absen.',
    'You are $distance from the office, outside the allowed radius. '
        'Move closer to the office area to clock in.',
  );

  // Verifikasi wajah (Hari 6)
  static String get faceCaptureTitle =>
      AppLocale.pick('Verifikasi Wajah', 'Face Verification');
  static String get facePreparingCamera =>
      AppLocale.pick('Menyiapkan kamera...', 'Preparing the camera...');
  static String get faceGuide => AppLocale.pick(
    'Posisikan wajah di dalam bingkai oval, lalu ambil foto',
    'Position your face inside the oval frame, then take a photo',
  );
  static String get faceCheckingQuality =>
      AppLocale.pick('Memeriksa kualitas foto...', 'Checking photo quality...');

  // Alasan selfie ditolak (spesifik & actionable)
  static String get faceNotDetected => AppLocale.pick(
    'Wajah tidak terdeteksi. Posisikan wajah Anda di dalam bingkai oval lalu ambil ulang.',
    'No face detected. Position your face inside the oval frame and retake.',
  );
  static String get faceMultipleDetected => AppLocale.pick(
    'Terdeteksi lebih dari satu wajah. Pastikan hanya Anda di dalam bingkai lalu ambil ulang.',
    'More than one face detected. Make sure only you are in the frame and retake.',
  );
  static String get faceTooDark => AppLocale.pick(
    'Pencahayaan terlalu gelap. Cari tempat yang lebih terang lalu ambil ulang.',
    'Lighting is too dark. Move to a brighter spot and retake.',
  );
  static String get faceTooBright => AppLocale.pick(
    'Cahaya terlalu terang/silau. Hindari cahaya langsung ke kamera lalu ambil ulang.',
    'Lighting is too bright/glaring. Avoid direct light on the camera and retake.',
  );
  static String get faceTooBlurry => AppLocale.pick(
    'Foto buram. Tahan ponsel agar stabil dan pastikan wajah fokus lalu ambil ulang.',
    'Photo is blurry. Hold the phone steady and keep your face in focus, then retake.',
  );

  // Riwayat absensi (Hari 8)
  static String get historyTitle =>
      AppLocale.pick('Riwayat Absensi', 'Attendance History');
  static String get historyFilterAll => AppLocale.pick('Semua', 'All');
  static String get historyEmpty =>
      AppLocale.pick('Belum ada riwayat absensi', 'No attendance history yet');
  static String get historyEmptyHint => AppLocale.pick(
    'Catatan kehadiran Anda akan muncul di sini setelah mulai absen.',
    'Your attendance records will appear here once you start clocking in.',
  );
  static String get historyEmptyFiltered => AppLocale.pick(
    'Tidak ada catatan untuk filter ini.',
    'No records for this filter.',
  );
  static String get detailTitle =>
      AppLocale.pick('Detail Absensi', 'Attendance Detail');
  static String get labelClockIn =>
      AppLocale.pick('Jam Masuk', 'Clock In Time');
  static String get labelClockOut =>
      AppLocale.pick('Jam Pulang', 'Clock Out Time');
  static String get labelDuration =>
      AppLocale.pick('Durasi Kerja', 'Work Duration');
  static String get labelLocationStatus =>
      AppLocale.pick('Status Lokasi', 'Location Status');
  static String get labelCoordIn =>
      AppLocale.pick('Koordinat Masuk', 'Clock-In Coordinates');
  static String get labelCoordOut =>
      AppLocale.pick('Koordinat Pulang', 'Clock-Out Coordinates');
  static String get notClockedOutYet =>
      AppLocale.pick('Belum absen pulang', 'Not clocked out yet');
  static String get inRadiusYes =>
      AppLocale.pick('Dalam radius kantor', 'Within office radius');
  static String get inRadiusNo =>
      AppLocale.pick('Di luar radius kantor', 'Outside office radius');

  // Verifikasi wajah saat clock-in (Hari 7)
  static String get faceGateBeforeClockIn => AppLocale.pick(
    'Verifikasi wajah dulu untuk menyelesaikan absen masuk.',
    'Verify your face to complete clocking in.',
  );
  static String get clockInSuccessTitle =>
      AppLocale.pick('Absen masuk berhasil', 'Clocked in successfully');
  static String get clockOutSuccessTitle =>
      AppLocale.pick('Absen pulang berhasil', 'Clocked out successfully');

  static String get errSelfieUploadFailed => AppLocale.pick(
    'Gagal memproses foto selfie. Coba ambil ulang dengan pencahayaan yang cukup.',
    'Failed to process the selfie. Retake it with adequate lighting.',
  );

  // Pengajuan izin/cuti
  static String get leaveTitle =>
      AppLocale.pick('Ajukan Izin', 'Request Leave');
  static String get leaveButton =>
      AppLocale.pick('Ajukan Izin', 'Request Leave');
  static String get leaveSubtitle => AppLocale.pick(
    'Pilih tanggal dan tuliskan alasan. Izin langsung tercatat pada riwayat absensi Anda.',
    'Pick a date and write a reason. The leave is recorded immediately in your attendance history.',
  );
  static String get leaveDateLabel =>
      AppLocale.pick('Tanggal Izin', 'Leave Date');
  static String get leaveDatePick =>
      AppLocale.pick('Pilih tanggal', 'Pick a date');
  static String get leaveReasonLabel =>
      AppLocale.pick('Alasan Izin', 'Leave Reason');
  static String get leaveReasonHint => AppLocale.pick(
    'Contoh: sakit, ada urusan keluarga, dll.',
    'Example: sick, family matters, etc.',
  );
  static String get leaveReasonRequired =>
      AppLocale.pick('Alasan izin wajib diisi', 'Leave reason is required');
  static String get leaveReasonTooShort => AppLocale.pick(
    'Alasan minimal 5 karakter',
    'Reason must be at least 5 characters',
  );
  static String get leaveSubmitButton =>
      AppLocale.pick('Kirim Pengajuan', 'Submit Request');
  static String get leaveSuccess => AppLocale.pick(
    'Izin berhasil diajukan dan tercatat.',
    'Leave submitted and recorded successfully.',
  );
  static String get labelReason =>
      AppLocale.pick('Alasan Izin', 'Leave Reason');
  static String get errLeaveAlreadyExists => AppLocale.pick(
    'Sudah ada catatan absensi pada tanggal itu. Pilih tanggal lain.',
    'There is already an attendance record on that date. Pick another date.',
  );

  // Pengaturan (tema & bahasa)
  static String get settingsSection => AppLocale.pick('Pengaturan', 'Settings');
  static String get darkModeTitle => AppLocale.pick('Mode Gelap', 'Dark Mode');
  static String get darkModeSubtitle => AppLocale.pick(
    'Tampilan gelap, nyaman di mata saat cahaya redup.',
    'Dark theme, easy on the eyes in low light.',
  );
  static String get languageTitle =>
      AppLocale.pick('Bahasa Inggris', 'English');
  static String get languageSubtitle => AppLocale.pick(
    'Tampilkan teks aplikasi dalam Bahasa Inggris.',
    'Show the app text in English.',
  );

  // Profil (Hari 9)
  static String get profileTitle => AppLocale.pick('Profil Saya', 'My Profile');
  static String get profileIdCardTitle =>
      AppLocale.pick('Kartu Karyawan', 'Employee Card');
  static String get profileRoleEmployee =>
      AppLocale.pick('Karyawan', 'Employee');
  static String get profileRoleAdmin => AppLocale.pick('Admin', 'Admin');
  static String get labelName => AppLocale.pick('Nama Lengkap', 'Full Name');
  static String get labelEmail => AppLocale.pick('Email', 'Email');
  static String get labelNik => AppLocale.pick('NIK', 'ID Number');
  static String get labelDepartment =>
      AppLocale.pick('Departemen', 'Department');
  static String get labelRole => AppLocale.pick('Peran', 'Role');
  static String get fieldNameHint =>
      AppLocale.pick('Masukkan nama lengkap Anda', 'Enter your full name');
  static String get nameRequired =>
      AppLocale.pick('Nama wajib diisi', 'Name is required');
  static String get nameTooShort => AppLocale.pick(
    'Nama minimal 3 karakter',
    'Name must be at least 3 characters',
  );
  static String get editProfileSection =>
      AppLocale.pick('Ubah Profil', 'Edit Profile');
  static String get saveProfile =>
      AppLocale.pick('Simpan Perubahan', 'Save Changes');
  static String get profileSaved => AppLocale.pick(
    'Profil berhasil diperbarui.',
    'Profile updated successfully.',
  );
  static String get changePhoto => AppLocale.pick('Ubah foto', 'Change photo');
  static String get pickFromCamera =>
      AppLocale.pick('Ambil dari Kamera', 'Take from Camera');
  static String get pickFromGallery =>
      AppLocale.pick('Pilih dari Galeri', 'Choose from Gallery');
  static String get errPickImage => AppLocale.pick(
    'Gagal mengambil gambar. Coba lagi atau pilih foto lain.',
    'Failed to get the image. Try again or pick another photo.',
  );
  static String get errProfilePhotoFailed => AppLocale.pick(
    'Gagal memproses foto profil. Pilih foto lain dengan ukuran wajar lalu coba lagi.',
    'Failed to process the profile photo. Choose a reasonably sized photo and try again.',
  );

  static String get changePasswordSection =>
      AppLocale.pick('Ganti Kata Sandi', 'Change Password');
  static String get fieldCurrentPasswordLabel =>
      AppLocale.pick('Kata Sandi Saat Ini', 'Current Password');
  static String get fieldCurrentPasswordHint => AppLocale.pick(
    'Masukkan kata sandi sekarang',
    'Enter your current password',
  );
  static String get fieldNewPasswordLabel =>
      AppLocale.pick('Kata Sandi Baru', 'New Password');
  static String get fieldNewPasswordHint =>
      AppLocale.pick('Minimal 6 karakter', 'At least 6 characters');
  static String get fieldConfirmPasswordLabel =>
      AppLocale.pick('Ulangi Kata Sandi Baru', 'Repeat New Password');
  static String get fieldConfirmPasswordHint =>
      AppLocale.pick('Ketik ulang kata sandi baru', 'Re-type the new password');
  static String get confirmPasswordMismatch => AppLocale.pick(
    'Kata sandi baru tidak sama',
    'New passwords do not match',
  );
  static String get newPasswordSameAsOld => AppLocale.pick(
    'Kata sandi baru harus berbeda dari yang sekarang',
    'New password must differ from the current one',
  );
  static String get changePasswordButton =>
      AppLocale.pick('Ganti Kata Sandi', 'Change Password');
  static String get passwordChanged => AppLocale.pick(
    'Kata sandi berhasil diganti. Gunakan kata sandi baru saat masuk berikutnya.',
    'Password changed successfully. Use the new password next time you sign in.',
  );
  static String get errCurrentPasswordWrong => AppLocale.pick(
    'Kata sandi saat ini salah. Periksa kembali lalu coba lagi.',
    'Current password is incorrect. Please check and try again.',
  );
  static String get errWeakPassword => AppLocale.pick(
    'Kata sandi baru terlalu lemah. Gunakan minimal 6 karakter.',
    'New password is too weak. Use at least 6 characters.',
  );
  static String get errRequiresRecentLogin => AppLocale.pick(
    'Demi keamanan, keluar lalu masuk kembali sebelum mengganti kata sandi.',
    'For security, sign out and sign back in before changing your password.',
  );

  // Panel Admin (Hari 11)
  static String get adminTitle => AppLocale.pick('Panel Admin', 'Admin Panel');
  static String get adminTodaySection =>
      AppLocale.pick('Kehadiran Hari Ini', "Today's Attendance");
  static String get adminClockedIn =>
      AppLocale.pick('Sudah Masuk', 'Clocked In');
  static String get adminOnTime => AppLocale.pick('Hadir', 'Present');
  static String get adminLate => AppLocale.pick('Telat', 'Late');
  static String get adminAlpha =>
      AppLocale.pick('Belum Absen', 'Not Clocked In');
  static String get adminOfTotal =>
      AppLocale.pick('dari %d karyawan', 'of %d employees');
  static String get adminTrendSection =>
      AppLocale.pick('Tren Kehadiran 7 Hari', '7-Day Attendance Trend');
  static String get adminLatenessSection =>
      AppLocale.pick('Keterlambatan 7 Hari', '7-Day Lateness');
  static String get adminClockInDistSection =>
      AppLocale.pick('Distribusi Jam Masuk', 'Clock-In Time Distribution');
  static String get adminClockInDistEmpty => AppLocale.pick(
    'Belum ada data jam masuk untuk ditampilkan.',
    'No clock-in data to display yet.',
  );
  static String get adminEmptyTrend => AppLocale.pick(
    'Belum ada data absensi dalam 7 hari terakhir.',
    'No attendance data in the last 7 days.',
  );
  static String get adminLiveBadge => AppLocale.pick('LANGSUNG', 'LIVE');

  // Manajemen karyawan (Hari 12)
  static String get employeesTitle =>
      AppLocale.pick('Kelola Karyawan', 'Manage Employees');
  static String get employeesEmpty =>
      AppLocale.pick('Belum ada data karyawan.', 'No employee data yet.');
  static String get employeeSearchHint => AppLocale.pick(
    'Cari nama, NIK, atau departemen',
    'Search name, ID number, or department',
  );
  static String get employeeSearchEmpty => AppLocale.pick(
    'Tidak ada karyawan yang cocok dengan pencarian.',
    'No employees match your search.',
  );
  static String get employeeDetailTitle =>
      AppLocale.pick('Detail Karyawan', 'Employee Detail');
  static String get employeeInfoSection =>
      AppLocale.pick('Informasi', 'Information');
  static String get employeeHistorySection =>
      AppLocale.pick('Riwayat Absensi', 'Attendance History');
  static String get employeeHistoryEmpty => AppLocale.pick(
    'Karyawan ini belum punya catatan absensi.',
    'This employee has no attendance records yet.',
  );
  static String get historyDateFilterButton =>
      AppLocale.pick('Filter Tanggal', 'Date Filter');
  static String get historyDateFilterAll =>
      AppLocale.pick('Semua tanggal', 'All dates');
  static String get historyDateFilterEmpty => AppLocale.pick(
    'Tidak ada absensi pada rentang tanggal ini.',
    'No attendance in this date range.',
  );
  static String get changeRole => AppLocale.pick('Ubah Peran', 'Change Role');
  static String get promoteToAdmin =>
      AppLocale.pick('Jadikan Admin', 'Make Admin');
  static String get demoteToEmployee =>
      AppLocale.pick('Jadikan Karyawan', 'Make Employee');
  static String get roleChangedToAdmin => AppLocale.pick(
    'Peran diubah menjadi Admin. Pengguna kini punya akses panel admin.',
    'Role changed to Admin. The user now has admin panel access.',
  );
  static String get roleChangedToEmployee => AppLocale.pick(
    'Peran diubah menjadi Karyawan.',
    'Role changed to Employee.',
  );
  static String get roleChangeSelfBlocked => AppLocale.pick(
    'Anda tidak dapat mengubah peran akun sendiri.',
    'You cannot change the role of your own account.',
  );
  static String confirmRoleChange(
    String name,
    String targetRole,
  ) => AppLocale.pick(
    'Ubah peran $name menjadi $targetRole? Akses aplikasi mereka akan menyesuaikan.',
    "Change $name's role to $targetRole? Their app access will adjust accordingly.",
  );

  // Export CSV (Hari 12 lanjutan)
  static String get exportTitle =>
      AppLocale.pick('Ekspor Laporan', 'Export Report');
  static String get exportPreparing =>
      AppLocale.pick('Menyiapkan laporan CSV...', 'Preparing CSV report...');
  static String get exportShareText =>
      AppLocale.pick('Laporan Absensi (CSV)', 'Attendance Report (CSV)');
  static String get exportEmpty => AppLocale.pick(
    'Tidak ada catatan absensi pada rentang tanggal itu.',
    'No attendance records in that date range.',
  );
  static String get exportFailed => AppLocale.pick(
    'Gagal membuat file laporan. Coba lagi beberapa saat.',
    'Failed to create the report file. Please try again shortly.',
  );
  static String exportSuccess(int count) => AppLocale.pick(
    'Laporan berisi $count catatan siap dibagikan.',
    'Report with $count records ready to share.',
  );

  // Notifikasi lokal (Hari 10)
  static String get notifClockInTitle =>
      AppLocale.pick('Absen masuk tercatat', 'Clock-in recorded');
  static String notifClockInBody(String time) => AppLocale.pick(
    'Kehadiran Anda pukul $time sudah tersimpan. Selamat bekerja!',
    'Your attendance at $time has been saved. Have a great day!',
  );
  static String get notifReminderTitle =>
      AppLocale.pick('Waktunya absen masuk', 'Time to clock in');
  static String get notifReminderBody => AppLocale.pick(
    'Jangan lupa absen masuk hari ini sebelum pukul 08:30 agar tidak telat.',
    "Don't forget to clock in today before 08:30 to avoid being late.",
  );
  static String get notifClockOutReminderTitle =>
      AppLocale.pick('Waktunya absen pulang', 'Time to clock out');
  static String get notifClockOutReminderBody => AppLocale.pick(
    'Sebelum meninggalkan kantor, jangan lupa absen pulang hari ini.',
    "Before leaving the office, don't forget to clock out today.",
  );

  // Error kamera
  static String get errCameraPermissionDenied => AppLocale.pick(
    'Izin kamera ditolak. Aplikasi butuh kamera untuk verifikasi wajah saat absen.',
    'Camera permission denied. The app needs the camera for face verification when clocking in.',
  );
  static String get errCameraPermissionForever => AppLocale.pick(
    'Izin kamera diblokir permanen. Buka Pengaturan aplikasi dan izinkan akses kamera.',
    'Camera permission permanently blocked. Open app Settings and allow camera access.',
  );
  static String get errCameraUnavailable => AppLocale.pick(
    'Kamera tidak dapat diakses. Pastikan tidak sedang dipakai aplikasi lain lalu coba lagi.',
    'Camera cannot be accessed. Make sure no other app is using it and try again.',
  );

  // Status absensi (badge, tile, CSV) — sumber tunggal label terlokalisasi
  static String get statusHadir => AppLocale.pick('Hadir', 'Present');
  static String get statusTelat => AppLocale.pick('Telat', 'Late');
  static String get statusIzin => AppLocale.pick('Izin', 'Leave');
  static String get statusAlpha => AppLocale.pick('Alpha', 'Absent');

  // Dashboard karyawan & kartu hari ini
  static String get greeting => AppLocale.pick('Halo,', 'Hi,');
  static String greetingNamed(String name) =>
      AppLocale.pick('Halo, $name', 'Hi, $name');
  static String departmentNik(String department, String nik) =>
      AppLocale.pick('$department • NIK $nik', '$department • ID $nik');
  static String get weeklySummaryTitle =>
      AppLocale.pick('Ringkasan Minggu Ini', "This Week's Summary");
  static String get notClockedInTitle =>
      AppLocale.pick('Belum absen hari ini', 'Not clocked in today');
  static String get clockInRadiusHint => AppLocale.pick(
    'Pastikan Anda berada dalam radius kantor saat absen.',
    'Make sure you are within the office radius when clocking in.',
  );
  static String clockedInAt(String time) =>
      AppLocale.pick('Sudah masuk $time', 'Clocked in $time');
  static String get clockOutHint => AppLocale.pick(
    'Jangan lupa absen pulang sebelum meninggalkan kantor.',
    "Don't forget to clock out before leaving the office.",
  );
  static String get clockOutButton =>
      AppLocale.pick('Absen Pulang', 'Clock Out');
  static String get attendanceCompleteTitle => AppLocale.pick(
    'Absensi hari ini selesai',
    "Today's attendance is complete",
  );
  static String get weeklyEmptyTitle =>
      AppLocale.pick('Belum ada data minggu ini', 'No data this week yet');
  static String get weeklyEmptyHint => AppLocale.pick(
    'Rekap hadir, telat, dan alpha muncul setelah Anda mulai absen.',
    'Your present, late, and absent recap appears once you start clocking in.',
  );
  static String get clockInShort => AppLocale.pick('Masuk', 'In');
  static String get clockOutShort => AppLocale.pick('Pulang', 'Out');

  // Halaman clock-in
  static String alreadyClockedInAt(String time) => AppLocale.pick(
    'Sudah absen masuk pukul $time',
    'Already clocked in at $time',
  );
  static String clockInAtLabel(String time) =>
      AppLocale.pick('Masuk pukul $time', 'Clocked in at $time');
  static String clockOutAtLabel(String time) =>
      AppLocale.pick('Pulang pukul $time', 'Clocked out at $time');
  static String workDurationValue(String duration) =>
      AppLocale.pick('Durasi kerja: $duration', 'Work duration: $duration');
  static String historyTileTimes(String inTime, String outTime) =>
      AppLocale.pick(
        'Masuk $inTime • Pulang $outTime',
        'In $inTime • Out $outTime',
      );
  static String durationMinutes(int m) => AppLocale.pick('$m menit', '$m min');
  static String durationHourMinute(int h, int m) =>
      AppLocale.pick('$h jam $m menit', '$h h $m min');

  // Kartu mingguan & kartu admin hari ini
  static String get weeklyAttendanceTitle =>
      AppLocale.pick('Kehadiran minggu ini', 'Attendance this week');
  static String presentOfWorkdays(int present, int total) => AppLocale.pick(
    '$present dari $total hari kerja',
    '$present of $total workdays',
  );
  static String get adminTodayAttendanceTitle =>
      AppLocale.pick('Kehadiran hari ini', 'Attendance today');

  // Logout (konfirmasi)
  static String get logoutConfirmTitle =>
      AppLocale.pick('Keluar dari akun?', 'Sign out of your account?');
  static String get logoutConfirmBody => AppLocale.pick(
    'Anda perlu masuk lagi dengan email/NIK untuk mengakses absensi.',
    'You will need to sign in again with your email/ID number to access attendance.',
  );
  static String get logout => AppLocale.pick('Keluar', 'Sign Out');

  // Peta (fallback info)
  static String get mapRadiusLabel =>
      AppLocale.pick('Radius absen', 'Attendance radius');
  static String get mapYourPosition =>
      AppLocale.pick('Posisi Anda', 'Your position');

  // Kolom CSV laporan absensi
  static String get csvColName => AppLocale.pick('Nama', 'Name');
  static String get csvColNik => AppLocale.pick('NIK', 'ID Number');
  static String get csvColDate => AppLocale.pick('Tanggal', 'Date');
  static String get csvColClockIn => AppLocale.pick('Jam Masuk', 'Clock In');
  static String get csvColClockOut => AppLocale.pick('Jam Pulang', 'Clock Out');
  static String get csvColStatus => AppLocale.pick('Status', 'Status');
  static String get csvColDuration =>
      AppLocale.pick('Durasi (menit)', 'Duration (minutes)');
  static String get csvColLocation => AppLocale.pick('Lokasi', 'Location');
  static String get csvColCoordIn =>
      AppLocale.pick('Koordinat Masuk', 'Clock-In Coordinates');
  static String get csvInRadius =>
      AppLocale.pick('Dalam radius', 'Within radius');
  static String get csvOutRadius =>
      AppLocale.pick('Luar radius', 'Outside radius');
}

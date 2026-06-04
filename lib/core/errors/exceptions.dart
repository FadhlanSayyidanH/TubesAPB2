// Part of: Core - Errors
//
// Exception dilempar dari data layer (datasource). Repository menangkapnya
// dan menerjemahkan jadi Failure yang aman dibawa ke presentation.

/// Kegagalan dari Firebase Auth / Firestore. [code] adalah kode mentah Firebase
/// (mis. 'wrong-password') supaya repository bisa memetakan ke pesan spesifik.
class AuthException implements Exception {
  final String code;
  final String? rawMessage;
  const AuthException(this.code, [this.rawMessage]);
}

/// Dokumen user ada di Auth tapi tidak ada di Firestore (data karyawan hilang).
class ProfileNotFoundException implements Exception {
  const ProfileNotFoundException();
}

/// NIK dimasukkan saat login tapi tidak ada padanannya di koleksi /users.
class NikNotFoundException implements Exception {
  const NikNotFoundException();
}

/// Operasi gagal karena tidak ada koneksi internet.
class NoInternetException implements Exception {
  const NoInternetException();
}

/// Kegagalan baca/tulis Firestore yang tidak terkait auth.
class ServerException implements Exception {
  final String? rawMessage;
  const ServerException([this.rawMessage]);
}

/// GPS/Location Services perangkat dimatikan.
class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
}

/// User menolak izin lokasi (masih bisa diminta lagi).
class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();
}

/// User menolak izin lokasi permanen ("Jangan tanya lagi") — harus ke Settings.
class LocationPermissionPermanentlyDeniedException implements Exception {
  const LocationPermissionPermanentlyDeniedException();
}

/// GPS tidak mendapatkan fix lokasi dalam batas waktu.
class LocationTimeoutException implements Exception {
  const LocationTimeoutException();
}

/// Belum ada dokumen kantor di Firestore untuk dijadikan acuan radius.
class OfficeNotConfiguredException implements Exception {
  const OfficeNotConfiguredException();
}

/// Sudah ada catatan absensi pada tanggal tersebut (cegah izin ganda / bentrok
/// dengan absen masuk yang sudah ada).
class AttendanceAlreadyExistsException implements Exception {
  const AttendanceAlreadyExistsException();
}

/// User menolak izin kamera (masih bisa diminta lagi).
class CameraPermissionDeniedException implements Exception {
  const CameraPermissionDeniedException();
}

/// User menolak izin kamera permanen — harus diaktifkan lewat Settings.
class CameraPermissionPermanentlyDeniedException implements Exception {
  const CameraPermissionPermanentlyDeniedException();
}

/// Kamera tidak bisa diakses/diinisialisasi (tidak ada, dipakai app lain, dll).
class CameraUnavailableException implements Exception {
  const CameraUnavailableException();
}

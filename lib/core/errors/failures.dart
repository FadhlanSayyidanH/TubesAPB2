// Part of: Core - Errors

import 'package:equatable/equatable.dart';

/// Failure dibawa lewat `Either<Failure, T>` ke presentation. [message] sudah
/// berupa kalimat siap-tampil ke user (Bahasa Indonesia, actionable).
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Gagal autentikasi (kredensial salah, akun tidak ada, NIK tidak terdaftar).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Tidak ada koneksi internet.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Kegagalan server/Firestore di luar konteks auth.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Data profil karyawan tidak ditemukan di Firestore.
class ProfileFailure extends Failure {
  const ProfileFailure(super.message);
}

/// Kegagalan terkait GPS/izin lokasi. [openSettings] menandai kasus di mana UI
/// sebaiknya menawarkan tombol "Buka Pengaturan" (izin ditolak permanen).
class LocationFailure extends Failure {
  final bool openSettings;
  const LocationFailure(super.message, {this.openSettings = false});

  @override
  List<Object?> get props => [message, openSettings];
}

/// Kegagalan terkait kamera (izin/akses). [openSettings] menandai izin diblokir
/// permanen sehingga UI menawarkan tombol "Buka Pengaturan".
class CameraFailure extends Failure {
  final bool openSettings;
  const CameraFailure(super.message, {this.openSettings = false});

  @override
  List<Object?> get props => [message, openSettings];
}

/// Selfie tertangkap tapi gagal validasi kualitas (tidak ada wajah, buram,
/// pencahayaan buruk, dll). Bersifat sementara — user tinggal ambil ulang.
class FaceQualityFailure extends Failure {
  const FaceQualityFailure(super.message);
}

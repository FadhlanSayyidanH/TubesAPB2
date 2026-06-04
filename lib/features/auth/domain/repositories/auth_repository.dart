// Part of: Auth - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Kontrak auth yang dipakai usecases. Implementasi konkret (Firebase) hidup
/// di data layer, sehingga domain & presentation tidak tergantung Firebase.
abstract class AuthRepository {
  /// Login dengan email ATAU NIK. Bila [identifier] berupa NIK, implementasi
  /// menukarnya jadi email lewat Firestore sebelum login ke Firebase Auth.
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  /// User yang sedang aktif (sesi tersimpan), atau null bila belum login.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Perbarui nama (dan opsional foto profil) karyawan di Firestore. Bila
  /// [photoPath] diisi, foto dikompres jadi data URI base64 dulu (lihat
  /// CLAUDE.md §6 — belum pakai Storage). Mengembalikan profil terbaru.
  Future<Either<Failure, UserEntity>> updateProfile({
    required String uid,
    required String name,
    String? photoPath,
  });

  /// Ganti kata sandi user yang sedang login. Implementasi melakukan
  /// re-autentikasi dengan [currentPassword] dulu (Firebase mensyaratkannya
  /// untuk operasi sensitif) sebelum menyetel [newPassword].
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Stream perubahan status auth untuk dipantau AuthBloc. Emit uid saat login,
  /// null saat logout/sesi berakhir.
  Stream<String?> get authStateChanges;
}

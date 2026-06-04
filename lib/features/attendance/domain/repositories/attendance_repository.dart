// Part of: Attendance - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/attendance_entity.dart';
import '../entities/location_status.dart';
import '../entities/office_entity.dart';

/// Kontrak fitur absensi: validasi lokasi (Hari 3) + clock-in/out (Hari 4).
abstract class AttendanceRepository {
  /// Titik kantor acuan untuk validasi radius.
  Future<Either<Failure, OfficeEntity>> getPrimaryOffice();

  /// Posisi user saat ini + jarak ke [office] + apakah masih dalam radius.
  Future<Either<Failure, LocationStatus>> getLocationStatus(
    OfficeEntity office,
  );

  /// Catatan absensi user untuk hari ini, atau null bila belum absen.
  Future<Either<Failure, AttendanceEntity?>> getTodayAttendance(String userId);

  /// Simpan clock-in. [selfiePath] = file selfie lokal yang sudah lolos
  /// verifikasi wajah; diunggah ke Storage lalu URL-nya disimpan ke `selfieUrl`.
  /// Status hadir/telat ditentukan dari jam saat ini.
  Future<Either<Failure, AttendanceEntity>> clockIn({
    required UserEntity user,
    required LocationStatus location,
    required String selfiePath,
  });

  /// Lengkapi catatan hari ini dengan waktu pulang + durasi kerja.
  Future<Either<Failure, AttendanceEntity>> clockOut({
    required AttendanceEntity today,
    required LocationStatus location,
  });

  /// Catatan absensi user untuk minggu berjalan (Senin–Minggu), urut terbaru.
  Future<Either<Failure, List<AttendanceEntity>>> getWeekAttendance(
    String userId,
  );

  /// Seluruh riwayat absensi user, urut terbaru dulu (untuk halaman Riwayat).
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceHistory(
    String userId,
  );

  /// Ajukan izin pada [date] dengan [reason] → langsung tercatat status izin.
  /// Gagal bila tanggal itu sudah punya catatan absensi (cegah bentrok/ganda).
  Future<Either<Failure, AttendanceEntity>> submitLeave({
    required UserEntity user,
    required DateTime date,
    required String reason,
  });
}

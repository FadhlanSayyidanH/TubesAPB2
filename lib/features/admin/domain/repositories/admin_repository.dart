// Part of: Admin - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../attendance/domain/entities/attendance_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class AdminRepository {
  /// Stream catatan absensi sejak [fromDate] untuk monitoring real-time.
  /// Error stream dibiarkan mengalir agar bloc bisa menampilkan state error.
  Stream<List<AttendanceEntity>> watchAttendanceSince(String fromDate);

  Future<Either<Failure, int>> getEmployeeCount();

  /// Catatan absensi dalam rentang tanggal (untuk laporan/ekspor CSV).
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceBetween(
    String fromDate,
    String toDate,
  );

  /// Daftar seluruh user (untuk manajemen karyawan).
  Future<Either<Failure, List<UserEntity>>> getAllUsers();

  Future<Either<Failure, void>> updateUserRole(String uid, UserRole role);
}

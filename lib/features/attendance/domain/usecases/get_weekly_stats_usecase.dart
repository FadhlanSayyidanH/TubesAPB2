// Part of: Attendance - Domain

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failures.dart';
import '../entities/attendance_entity.dart';
import '../entities/weekly_stats.dart';
import '../repositories/attendance_repository.dart';

class GetWeeklyStatsUseCase {
  final AttendanceRepository _repository;

  GetWeeklyStatsUseCase(this._repository);

  Future<Either<Failure, WeeklyStats>> call(String userId) async {
    final result = await _repository.getWeekAttendance(userId);
    return result.map((records) => computeWeeklyStats(records, DateTime.now()));
  }
}

/// Hitung rekap mingguan murni dari [weekRecords] (catatan minggu ini) dan [now].
/// Hanya hari kerja (Sen–Jum) dari Senin sampai hari ini yang diperhitungkan;
/// hari kerja tanpa catatan dihitung alpha. Fungsi top-level agar gampang diuji.
WeeklyStats computeWeeklyStats(
  List<AttendanceEntity> weekRecords,
  DateTime now,
) {
  final dateFmt = DateFormat('yyyy-MM-dd');
  final monday = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: now.weekday - 1));
  final statusByDate = {for (final r in weekRecords) r.date: r.status};

  var hadir = 0, telat = 0, izin = 0, alpha = 0, workdays = 0;

  // Iterasi Senin (index 0) sampai hari ini (index now.weekday - 1), inklusif.
  for (var i = 0; i <= now.weekday - 1; i++) {
    final day = monday.add(Duration(days: i));
    if (day.weekday > DateTime.friday) continue; // lewati Sabtu & Minggu
    workdays++;

    switch (statusByDate[dateFmt.format(day)]) {
      case AttendanceStatus.hadir:
        hadir++;
      case AttendanceStatus.telat:
        telat++;
      case AttendanceStatus.izin:
        izin++;
      case AttendanceStatus.alpha:
      case null:
        alpha++;
    }
  }

  return WeeklyStats(
    hadir: hadir,
    telat: telat,
    izin: izin,
    alpha: alpha,
    workdaysElapsed: workdays,
  );
}

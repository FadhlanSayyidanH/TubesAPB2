// Part of: Attendance - Domain

import 'package:equatable/equatable.dart';

/// Rekap kehadiran karyawan untuk minggu berjalan (Senin–Minggu), dihitung
/// hanya atas hari kerja (Senin–Jumat) yang sudah lewat sampai hari ini.
class WeeklyStats extends Equatable {
  final int hadir;
  final int telat;
  final int izin;
  final int alpha;

  /// Jumlah hari kerja (Sen–Jum) dari awal minggu sampai hari ini, inklusif.
  final int workdaysElapsed;

  const WeeklyStats({
    required this.hadir,
    required this.telat,
    required this.izin,
    required this.alpha,
    required this.workdaysElapsed,
  });

  const WeeklyStats.empty()
    : hadir = 0,
      telat = 0,
      izin = 0,
      alpha = 0,
      workdaysElapsed = 0;

  int get present => hadir + telat;

  /// Persentase kehadiran = (hadir + telat) / hari kerja berjalan.
  int get attendancePercentage {
    if (workdaysElapsed == 0) return 0;
    return ((present / workdaysElapsed) * 100).round();
  }

  @override
  List<Object?> get props => [hadir, telat, izin, alpha, workdaysElapsed];
}

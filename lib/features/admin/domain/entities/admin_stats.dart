// Part of: Admin - Domain

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../../../attendance/domain/entities/attendance_entity.dart';

/// Hitungan absensi satu hari untuk grafik tren (7 hari terakhir).
class DailyAttendance extends Equatable {
  final DateTime day;
  final int present; // hadir + telat (benar-benar absen masuk)
  final int late; // telat saja

  const DailyAttendance({
    required this.day,
    required this.present,
    required this.late,
  });

  @override
  List<Object?> get props => [day, present, late];
}

/// Ringkasan untuk dashboard admin: kondisi hari ini + tren 7 hari.
class AdminStats extends Equatable {
  final int totalEmployees;
  final int clockedInToday; // jumlah karyawan yang sudah absen masuk hari ini
  final int onTimeToday; // status hadir
  final int lateToday; // status telat
  final int onLeaveToday; // status izin hari ini
  final List<DailyAttendance> last7Days; // urut lama → baru, hari ini di akhir
  final List<int> clockInHourCounts; // jumlah absen masuk per jam (index 0–23)

  const AdminStats({
    required this.totalEmployees,
    required this.clockedInToday,
    required this.onTimeToday,
    required this.lateToday,
    required this.onLeaveToday,
    required this.last7Days,
    required this.clockInHourCounts,
  });

  /// Karyawan yang belum absen hari ini — tidak termasuk yang izin, dan tidak
  /// pernah negatif.
  int get alphaToday =>
      (totalEmployees - clockedInToday - onLeaveToday).clamp(0, totalEmployees);

  /// Persentase kehadiran hari ini (0–100).
  int get attendanceRate => totalEmployees == 0
      ? 0
      : ((clockedInToday / totalEmployees) * 100).round();

  @override
  List<Object?> get props => [
        totalEmployees,
        clockedInToday,
        onTimeToday,
        lateToday,
        onLeaveToday,
        last7Days,
        clockInHourCounts,
      ];
}

/// Hitung [AdminStats] murni dari [records] (semua absensi 7 hari terakhir),
/// [totalEmployees], dan [now]. Top-level + tanpa I/O agar gampang diuji.
AdminStats computeAdminStats(
  List<AttendanceEntity> records,
  int totalEmployees,
  DateTime now,
) {
  final dateFmt = DateFormat('yyyy-MM-dd');
  final todayKey = dateFmt.format(now);

  final todayRecords = records.where((r) => r.date == todayKey).toList();
  final onTime =
      todayRecords.where((r) => r.status == AttendanceStatus.hadir).length;
  final late =
      todayRecords.where((r) => r.status == AttendanceStatus.telat).length;
  final onLeave =
      todayRecords.where((r) => r.status == AttendanceStatus.izin).length;

  final base = DateTime(now.year, now.month, now.day);
  final days = <DailyAttendance>[];
  for (var i = 6; i >= 0; i--) {
    final day = base.subtract(Duration(days: i));
    final key = dateFmt.format(day);
    final dayRecords = records.where((r) => r.date == key);
    final present = dayRecords
        .where((r) =>
            r.status == AttendanceStatus.hadir ||
            r.status == AttendanceStatus.telat)
        .length;
    final dayLate =
        dayRecords.where((r) => r.status == AttendanceStatus.telat).length;
    days.add(DailyAttendance(day: day, present: present, late: dayLate));
  }

  return AdminStats(
    totalEmployees: totalEmployees,
    // "Sudah masuk" = kehadiran fisik (hadir+telat), izin tidak dihitung.
    clockedInToday: onTime + late,
    onTimeToday: onTime,
    lateToday: late,
    onLeaveToday: onLeave,
    last7Days: days,
    clockInHourCounts: computeClockInHourCounts(records),
  );
}

/// Distribusi jumlah absen masuk per jam (0–23) dari [records] — hanya yang
/// benar-benar hadir/telat (punya jam kedatangan nyata), bukan izin/alpha.
/// Index = jam clock-in, nilai = jumlah. Untuk melihat pola jam kedatangan.
List<int> computeClockInHourCounts(List<AttendanceEntity> records) {
  final counts = List<int>.filled(24, 0);
  for (final record in records) {
    if (record.status == AttendanceStatus.hadir ||
        record.status == AttendanceStatus.telat) {
      counts[record.clockIn.hour]++;
    }
  }
  return counts;
}

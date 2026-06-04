// Part of: Attendance - Domain (test)

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_attendance/features/attendance/domain/usecases/get_weekly_stats_usecase.dart';

AttendanceEntity _rec(String date, AttendanceStatus status) => AttendanceEntity(
      id: 'u_$date',
      userId: 'u',
      userName: 'Budi',
      date: date,
      clockIn: DateTime.parse('$date 08:00:00'),
      clockInLat: 0,
      clockInLon: 0,
      selfieUrl: '',
      status: status,
      isInRadius: true,
    );

void main() {
  // 2024-01-01 adalah hari Senin — acuan awal minggu yang stabil untuk tes.
  final monday = DateTime(2024, 1, 1);
  final wednesday = DateTime(2024, 1, 3);

  group('computeWeeklyStats', () {
    test('hadir Senin + telat Rabu, Selasa kosong → alpha 1', () {
      final stats = computeWeeklyStats([
        _rec('2024-01-01', AttendanceStatus.hadir),
        _rec('2024-01-03', AttendanceStatus.telat),
      ], wednesday);

      expect(stats.hadir, 1);
      expect(stats.telat, 1);
      expect(stats.izin, 0);
      expect(stats.alpha, 1); // Selasa tidak ada catatan
      expect(stats.workdaysElapsed, 3); // Sen, Sel, Rab
      expect(stats.attendancePercentage, 67); // 2/3
    });

    test('tanpa catatan sama sekali → semua hari kerja jadi alpha', () {
      final stats = computeWeeklyStats([], wednesday);
      expect(stats.alpha, 3);
      expect(stats.present, 0);
      expect(stats.attendancePercentage, 0);
    });

    test('hanya hari Senin yang dihitung saat now = Senin', () {
      final stats = computeWeeklyStats(
        [_rec('2024-01-01', AttendanceStatus.hadir)],
        monday,
      );
      expect(stats.workdaysElapsed, 1);
      expect(stats.hadir, 1);
      expect(stats.attendancePercentage, 100);
    });

    test('catatan akhir pekan tidak memengaruhi hari kerja', () {
      final saturday = DateTime(2024, 1, 6);
      final stats = computeWeeklyStats([
        _rec('2024-01-01', AttendanceStatus.hadir),
        _rec('2024-01-06', AttendanceStatus.hadir), // Sabtu, harus diabaikan
      ], saturday);

      // Hari kerja Sen–Jum = 5; hanya Senin yang hadir, sisanya alpha.
      expect(stats.workdaysElapsed, 5);
      expect(stats.hadir, 1);
      expect(stats.alpha, 4);
    });

    test('izin dihitung terpisah dari alpha', () {
      final stats = computeWeeklyStats([
        _rec('2024-01-01', AttendanceStatus.izin),
        _rec('2024-01-02', AttendanceStatus.hadir),
      ], wednesday);
      expect(stats.izin, 1);
      expect(stats.hadir, 1);
      expect(stats.alpha, 1); // Rabu kosong
    });
  });
}

// Part of: Admin - Domain (test)

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_attendance/features/admin/domain/entities/admin_stats.dart';
import 'package:smart_attendance/features/attendance/domain/entities/attendance_entity.dart';

AttendanceEntity _rec(
  String userId,
  String date,
  AttendanceStatus status,
) =>
    AttendanceEntity(
      id: '${userId}_$date',
      userId: userId,
      userName: userId,
      date: date,
      clockIn: DateTime.parse('$date 08:00:00'),
      clockInLat: 0,
      clockInLon: 0,
      selfieUrl: '',
      status: status,
      isInRadius: true,
    );

void main() {
  // Acuan "hari ini" yang stabil untuk tes.
  final now = DateTime(2026, 6, 4, 10, 0);
  const today = '2026-06-04';

  group('computeAdminStats — hari ini', () {
    test('hitung sudah-masuk, hadir, telat, dan belum-absen', () {
      final stats = computeAdminStats([
        _rec('a', today, AttendanceStatus.hadir),
        _rec('b', today, AttendanceStatus.telat),
      ], 5, now);

      expect(stats.totalEmployees, 5);
      expect(stats.clockedInToday, 2);
      expect(stats.onTimeToday, 1);
      expect(stats.lateToday, 1);
      expect(stats.alphaToday, 3); // 5 - 2 belum absen
      expect(stats.attendanceRate, 40); // 2/5
    });

    test('tanpa karyawan → rate 0 dan tidak error pembagian nol', () {
      final stats = computeAdminStats([], 0, now);
      expect(stats.attendanceRate, 0);
      expect(stats.alphaToday, 0);
    });

    test('absen masuk melebihi data karyawan → alpha tidak negatif', () {
      final stats = computeAdminStats([
        _rec('a', today, AttendanceStatus.hadir),
        _rec('b', today, AttendanceStatus.hadir),
      ], 1, now);
      expect(stats.clockedInToday, 2);
      expect(stats.alphaToday, 0); // di-clamp, bukan -1
    });

    test('catatan hari lain tidak masuk hitungan hari ini', () {
      final stats = computeAdminStats([
        _rec('a', today, AttendanceStatus.hadir),
        _rec('a', '2026-06-03', AttendanceStatus.telat),
      ], 3, now);
      expect(stats.clockedInToday, 1);
      expect(stats.lateToday, 0);
    });

    test('izin tidak dihitung sebagai sudah-masuk maupun alpha', () {
      final stats = computeAdminStats([
        _rec('a', today, AttendanceStatus.hadir),
        _rec('b', today, AttendanceStatus.izin),
      ], 3, now);
      expect(stats.clockedInToday, 1); // hanya yang hadir/telat
      expect(stats.onLeaveToday, 1);
      expect(stats.alphaToday, 1); // 3 - 1 masuk - 1 izin
    });
  });

  group('computeAdminStats — tren 7 hari', () {
    test('selalu 7 titik, urut lama → baru, hari ini di akhir', () {
      final stats = computeAdminStats([], 3, now);
      expect(stats.last7Days.length, 7);
      expect(stats.last7Days.last.day, DateTime(2026, 6, 4));
      expect(stats.last7Days.first.day, DateTime(2026, 5, 29));
    });

    test('present = hadir + telat, late = telat saja per hari', () {
      final stats = computeAdminStats([
        _rec('a', today, AttendanceStatus.hadir),
        _rec('b', today, AttendanceStatus.telat),
        _rec('c', '2026-06-02', AttendanceStatus.telat),
      ], 3, now);

      final todayBucket = stats.last7Days.last;
      expect(todayBucket.present, 2); // hadir + telat
      expect(todayBucket.late, 1);

      final june2 = stats.last7Days.firstWhere(
        (d) => d.day == DateTime(2026, 6, 2),
      );
      expect(june2.present, 1);
      expect(june2.late, 1);
    });
  });

  group('computeClockInHourCounts', () {
    AttendanceEntity recAt(int hour, AttendanceStatus status) =>
        AttendanceEntity(
          id: 'r$hour',
          userId: 'u',
          userName: 'u',
          date: today,
          clockIn: DateTime(2026, 6, 4, hour, 15),
          clockInLat: 0,
          clockInLon: 0,
          selfieUrl: '',
          status: status,
          isInRadius: true,
        );

    test('panjang selalu 24 dan menghitung per jam clock-in', () {
      final counts = computeClockInHourCounts([
        recAt(8, AttendanceStatus.hadir),
        recAt(8, AttendanceStatus.hadir),
        recAt(9, AttendanceStatus.telat),
      ]);
      expect(counts.length, 24);
      expect(counts[8], 2);
      expect(counts[9], 1);
      expect(counts[7], 0);
    });

    test('izin & alpha tidak dihitung (tak ada jam kedatangan nyata)', () {
      final counts = computeClockInHourCounts([
        recAt(8, AttendanceStatus.hadir),
        recAt(8, AttendanceStatus.izin),
        recAt(8, AttendanceStatus.alpha),
      ]);
      expect(counts[8], 1); // hanya yang hadir
    });

    test('data kosong → semua nol', () {
      final counts = computeClockInHourCounts([]);
      expect(counts.every((c) => c == 0), isTrue);
    });
  });
}

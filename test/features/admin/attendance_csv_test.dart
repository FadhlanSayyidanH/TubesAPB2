// Part of: Admin - Domain (test)

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_attendance/features/admin/domain/attendance_csv.dart';
import 'package:smart_attendance/features/attendance/domain/entities/attendance_entity.dart';

AttendanceEntity _rec(
  String userId,
  String name,
  String date,
  AttendanceStatus status, {
  DateTime? clockOut,
  int? durasi,
  bool inRadius = true,
}) => AttendanceEntity(
  id: '${userId}_$date',
  userId: userId,
  userName: name,
  date: date,
  clockIn: DateTime.parse('$date 08:05:00'),
  clockOut: clockOut,
  clockInLat: -6.2088,
  clockInLon: 106.8456,
  selfieUrl: '',
  status: status,
  isInRadius: inRadius,
  workDurationMinutes: durasi,
);

void main() {
  group('buildAttendanceCsvRows', () {
    test('baris pertama adalah header kolom', () {
      final rows = buildAttendanceCsvRows([], const {});
      expect(rows.first, [
        'Nama',
        'NIK',
        'Tanggal',
        'Jam Masuk',
        'Jam Pulang',
        'Status',
        'Durasi (menit)',
        'Lokasi',
        'Koordinat Masuk',
      ]);
      expect(rows.length, 1); // hanya header bila tak ada data
    });

    test('NIK diambil dari peta, fallback "-" bila tak ada', () {
      final rows = buildAttendanceCsvRows(
        [_rec('u1', 'Budi', '2026-06-04', AttendanceStatus.hadir)],
        {'u1': '3273012501900001'},
      );
      expect(rows[1][0], 'Budi');
      expect(rows[1][1], '3273012501900001');

      final rowsNoNik = buildAttendanceCsvRows([
        _rec('u2', 'Sari', '2026-06-04', AttendanceStatus.hadir),
      ], const {});
      expect(rowsNoNik[1][1], '-');
    });

    test('jam pulang & durasi "-" saat belum absen pulang', () {
      final rows = buildAttendanceCsvRows([
        _rec('u1', 'Budi', '2026-06-04', AttendanceStatus.telat),
      ], const {});
      expect(rows[1][3], '08:05'); // jam masuk
      expect(rows[1][4], '-'); // jam pulang
      expect(rows[1][5], 'Telat');
      expect(rows[1][6], '-'); // durasi
    });

    test('lokasi & koordinat terformat', () {
      final rows = buildAttendanceCsvRows([
        _rec(
          'u1',
          'Budi',
          '2026-06-04',
          AttendanceStatus.hadir,
          clockOut: DateTime.parse('2026-06-04 17:00:00'),
          durasi: 535,
          inRadius: false,
        ),
      ], const {});
      expect(rows[1][4], '17:00');
      expect(rows[1][6], '535');
      expect(rows[1][7], 'Luar radius');
      expect(rows[1][8], '-6.20880, 106.84560');
    });

    test('diurut berdasarkan tanggal lalu nama', () {
      final rows = buildAttendanceCsvRows([
        _rec('u2', 'Sari', '2026-06-04', AttendanceStatus.hadir),
        _rec('u1', 'Budi', '2026-06-04', AttendanceStatus.hadir),
        _rec('u3', 'Andi', '2026-06-03', AttendanceStatus.hadir),
      ], const {});

      // Baris data (lewati header): 03 Andi, 04 Budi, 04 Sari.
      expect(rows[1][2], '2026-06-03');
      expect(rows[1][0], 'Andi');
      expect(rows[2][0], 'Budi');
      expect(rows[3][0], 'Sari');
    });
  });
}

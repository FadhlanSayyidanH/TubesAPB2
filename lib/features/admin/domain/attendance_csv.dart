// Part of: Admin - Domain

import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../attendance/domain/entities/attendance_entity.dart';

/// Bangun baris-baris CSV laporan absensi dari [records], dengan NIK diambil
/// dari [nikByUid] (userId → NIK). Fungsi murni (tanpa I/O) agar gampang diuji;
/// konversi ke string CSV & penulisan file ditangani service di luar.
///
/// Baris pertama = header. Data diurut tanggal lalu nama supaya laporan rapi.
List<List<String>> buildAttendanceCsvRows(
  List<AttendanceEntity> records,
  Map<String, String> nikByUid,
) {
  final timeFmt = DateFormat('HH:mm');

  final rows = <List<String>>[
    [
      AppStrings.csvColName,
      AppStrings.csvColNik,
      AppStrings.csvColDate,
      AppStrings.csvColClockIn,
      AppStrings.csvColClockOut,
      AppStrings.csvColStatus,
      AppStrings.csvColDuration,
      AppStrings.csvColLocation,
      AppStrings.csvColCoordIn,
    ],
  ];

  final sorted = [...records]
    ..sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0
          ? byDate
          : a.userName.toLowerCase().compareTo(b.userName.toLowerCase());
    });

  for (final r in sorted) {
    rows.add([
      r.userName,
      nikByUid[r.userId] ?? '-',
      r.date,
      timeFmt.format(r.clockIn),
      r.hasClockedOut ? timeFmt.format(r.clockOut!) : '-',
      r.status.label,
      r.workDurationMinutes?.toString() ?? '-',
      r.isInRadius ? AppStrings.csvInRadius : AppStrings.csvOutRadius,
      '${r.clockInLat.toStringAsFixed(5)}, ${r.clockInLon.toStringAsFixed(5)}',
    ]);
  }

  return rows;
}

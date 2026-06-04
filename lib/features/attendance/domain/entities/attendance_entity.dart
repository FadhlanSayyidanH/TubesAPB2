// Part of: Attendance - Domain

import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_strings.dart';

enum AttendanceStatus { hadir, telat, izin, alpha }

extension AttendanceStatusX on AttendanceStatus {
  String get label => switch (this) {
        AttendanceStatus.hadir => AppStrings.statusHadir,
        AttendanceStatus.telat => AppStrings.statusTelat,
        AttendanceStatus.izin => AppStrings.statusIzin,
        AttendanceStatus.alpha => AppStrings.statusAlpha,
      };

  String get wireValue => name; // 'hadir' | 'telat' | 'izin' | 'alpha'

  static AttendanceStatus fromWire(String? value) => switch (value) {
        'telat' => AttendanceStatus.telat,
        'izin' => AttendanceStatus.izin,
        'alpha' => AttendanceStatus.alpha,
        _ => AttendanceStatus.hadir,
      };
}

/// Satu catatan absensi harian. Dokumen Firestore di /attendance.
class AttendanceEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String date; // yyyy-MM-dd
  final DateTime clockIn;
  final DateTime? clockOut;
  final double clockInLat;
  final double clockInLon;
  final double? clockOutLat;
  final double? clockOutLon;
  final String selfieUrl;
  final AttendanceStatus status;
  final bool isInRadius;
  final int? workDurationMinutes;
  final String? reason; // alasan izin (hanya terisi untuk status izin)

  const AttendanceEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.clockIn,
    this.clockOut,
    required this.clockInLat,
    required this.clockInLon,
    this.clockOutLat,
    this.clockOutLon,
    required this.selfieUrl,
    required this.status,
    required this.isInRadius,
    this.workDurationMinutes,
    this.reason,
  });

  bool get hasClockedOut => clockOut != null;

  /// Catatan ini berupa pengajuan izin (bukan absen masuk fisik).
  bool get isLeave => status == AttendanceStatus.izin;

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        clockIn,
        clockOut,
        status,
        isInRadius,
        workDurationMinutes,
        reason,
      ];
}

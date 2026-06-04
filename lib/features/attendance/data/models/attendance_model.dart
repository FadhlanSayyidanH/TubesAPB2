// Part of: Attendance - Data

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.date,
    required super.clockIn,
    super.clockOut,
    required super.clockInLat,
    required super.clockInLon,
    super.clockOutLat,
    super.clockOutLon,
    required super.selfieUrl,
    required super.status,
    required super.isInRadius,
    super.workDurationMinutes,
    super.reason,
  });

  factory AttendanceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    final clockInLoc = data['clockInLocation'] as GeoPoint?;
    final clockOutLoc = data['clockOutLocation'] as GeoPoint?;
    return AttendanceModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      date: data['date'] as String? ?? '',
      clockIn: (data['clockIn'] as Timestamp).toDate(),
      clockOut: (data['clockOut'] as Timestamp?)?.toDate(),
      clockInLat: clockInLoc?.latitude ?? 0,
      clockInLon: clockInLoc?.longitude ?? 0,
      clockOutLat: clockOutLoc?.latitude,
      clockOutLon: clockOutLoc?.longitude,
      selfieUrl: data['selfieUrl'] as String? ?? '',
      status: AttendanceStatusX.fromWire(data['status'] as String?),
      isInRadius: data['isInRadius'] as bool? ?? false,
      workDurationMinutes: (data['workDuration'] as num?)?.toInt(),
      reason: data['reason'] as String?,
    );
  }

  /// Payload pengajuan izin. Tak ada lokasi/selfie/clock-out; [clockIn] dipatok
  /// ke tanggal izin agar urut riwayat tetap konsisten. Menyimpan [reason].
  Map<String, dynamic> toLeaveMap() => {
    'userId': userId,
    'userName': userName,
    'date': date,
    'clockIn': Timestamp.fromDate(clockIn),
    'clockInLocation': null,
    'clockOut': null,
    'clockOutLocation': null,
    'selfieUrl': '',
    'status': AttendanceStatus.izin.wireValue,
    'isInRadius': false,
    'workDuration': null,
    'reason': reason,
  };

  /// Payload saat clock-in (dokumen baru). clockOut & durasi belum ada.
  Map<String, dynamic> toClockInMap() => {
    'userId': userId,
    'userName': userName,
    'date': date,
    'clockIn': Timestamp.fromDate(clockIn),
    'clockInLocation': GeoPoint(clockInLat, clockInLon),
    'clockOut': null,
    'clockOutLocation': null,
    'selfieUrl': selfieUrl,
    'status': status.wireValue,
    'isInRadius': isInRadius,
    'workDuration': null,
  };
}

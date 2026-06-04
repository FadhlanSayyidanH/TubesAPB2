// Part of: Attendance - Data

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  /// Catatan absensi user untuk [date] (yyyy-MM-dd), atau null bila belum absen.
  Future<AttendanceModel?> getTodayAttendance(String userId, String date);

  /// Buat catatan clock-in. Id dokumen deterministik ({userId}_{date}) sehingga
  /// satu hari hanya bisa satu catatan — mencegah absen ganda.
  Future<AttendanceModel> createClockIn(AttendanceModel attendance);

  /// Lengkapi catatan dengan waktu & lokasi pulang + durasi kerja (menit).
  Future<void> clockOut({
    required String attendanceId,
    required DateTime clockOutTime,
    required double latitude,
    required double longitude,
    required int workDurationMinutes,
  });

  /// Semua catatan absensi milik user. Sengaja query equality tunggal (userId)
  /// agar tidak butuh composite index; pengurutan/penyaringan dilakukan di Dart.
  Future<List<AttendanceModel>> getUserAttendance(String userId);

  /// Buat catatan izin (status izin). Doc id deterministik {userId}_{date};
  /// bila sudah ada catatan tanggal itu → [AttendanceAlreadyExistsException].
  Future<AttendanceModel> createLeave(AttendanceModel leave);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirebaseFirestore _firestore;

  AttendanceRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _attendance =>
      _firestore.collection('attendance');

  String _docId(String userId, String date) => '${userId}_$date';

  @override
  Future<AttendanceModel?> getTodayAttendance(
    String userId,
    String date,
  ) async {
    final doc = await _attendance.doc(_docId(userId, date)).get();
    if (!doc.exists) {
      if (doc.metadata.isFromCache) throw const ServerException();
      return null;
    }
    return AttendanceModel.fromFirestore(doc);
  }

  @override
  Future<AttendanceModel> createClockIn(AttendanceModel attendance) async {
    final id = _docId(attendance.userId, attendance.date);
    await _attendance.doc(id).set(attendance.toClockInMap());
    final saved = await _attendance.doc(id).get();
    return AttendanceModel.fromFirestore(saved);
  }

  @override
  Future<void> clockOut({
    required String attendanceId,
    required DateTime clockOutTime,
    required double latitude,
    required double longitude,
    required int workDurationMinutes,
  }) async {
    await _attendance.doc(attendanceId).update({
      'clockOut': Timestamp.fromDate(clockOutTime),
      'clockOutLocation': GeoPoint(latitude, longitude),
      'workDuration': workDurationMinutes,
    });
  }

  @override
  Future<List<AttendanceModel>> getUserAttendance(String userId) async {
    final snapshot = await _attendance.where('userId', isEqualTo: userId).get();
    if (snapshot.docs.isEmpty && snapshot.metadata.isFromCache) {
      throw const ServerException();
    }
    return snapshot.docs.map(AttendanceModel.fromFirestore).toList();
  }

  @override
  Future<AttendanceModel> createLeave(AttendanceModel leave) async {
    final id = _docId(leave.userId, leave.date);
    final existing = await _attendance.doc(id).get();
    if (existing.exists) throw const AttendanceAlreadyExistsException();
    await _attendance.doc(id).set(leave.toLeaveMap());
    final saved = await _attendance.doc(id).get();
    return AttendanceModel.fromFirestore(saved);
  }
}

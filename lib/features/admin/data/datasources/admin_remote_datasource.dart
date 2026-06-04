// Part of: Admin - Data

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../../auth/data/models/user_model.dart';

/// Akses Firestore untuk monitoring admin. Query absensi sengaja memakai filter
/// rentang pada SATU field (`date`) sehingga tidak butuh composite index.
abstract class AdminRemoteDataSource {
  /// Stream semua catatan absensi dengan `date >= fromDate` (yyyy-MM-dd),
  /// memancar ulang setiap ada perubahan (real-time monitoring).
  Stream<List<AttendanceModel>> watchAttendanceSince(String fromDate);

  /// Jumlah karyawan (role == 'employee') sebagai penyebut kehadiran.
  Future<int> getEmployeeCount();

  /// Catatan absensi dengan `fromDate <= date <= toDate` (yyyy-MM-dd) untuk
  /// laporan/ekspor. Filter rentang pada satu field → tanpa composite index.
  Future<List<AttendanceModel>> getAttendanceBetween(
    String fromDate,
    String toDate,
  );

  /// Semua dokumen /users (karyawan & admin) untuk manajemen karyawan.
  Future<List<UserModel>> getAllUsers();

  /// Ubah peran user. [role] = 'employee' | 'admin'.
  Future<void> updateUserRole(String uid, String role);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore _firestore;

  AdminRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<AttendanceModel>> watchAttendanceSince(String fromDate) {
    return _firestore
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: fromDate)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(AttendanceModel.fromFirestore).toList());
  }

  @override
  Future<int> getEmployeeCount() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'employee')
          .count()
          .get();
      return snapshot.count ?? 0;
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendanceBetween(
    String fromDate,
    String toDate,
  ) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: fromDate)
        .where('date', isLessThanOrEqualTo: toDate)
        .get();
    if (snapshot.docs.isEmpty && snapshot.metadata.isFromCache) {
      throw const ServerException();
    }
    return snapshot.docs.map(AttendanceModel.fromFirestore).toList();
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    if (snapshot.docs.isEmpty && snapshot.metadata.isFromCache) {
      throw const ServerException();
    }
    return snapshot.docs.map(UserModel.fromFirestore).toList();
  }

  @override
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': role});
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }
}

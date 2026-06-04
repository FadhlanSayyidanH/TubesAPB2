// Part of: Auth - Data

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

/// Jembatan antara dokumen Firestore /users/{uid} dan UserEntity domain.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.nik,
    required super.role,
    required super.department,
    required super.photoUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return UserModel(
      uid: data['uid'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      nik: data['nik'] as String? ?? '',
      role: _roleFromString(data['role'] as String?),
      department: data['department'] as String? ?? '-',
      photoUrl: data['photoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'name': name,
    'email': email,
    'nik': nik,
    'role': role == UserRole.admin ? 'admin' : 'employee',
    'department': department,
    'photoUrl': photoUrl,
  };

  static UserRole _roleFromString(String? value) =>
      value == 'admin' ? UserRole.admin : UserRole.employee;
}

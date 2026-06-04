// Part of: Auth - Domain

import 'package:equatable/equatable.dart';

enum UserRole { employee, admin }

/// Representasi karyawan yang dipakai presentation & domain. Bersih dari
/// detail Firebase — pemetaan dari/ke Firestore ada di UserModel.
class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String nik;
  final UserRole role;
  final String department;
  final String photoUrl;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.nik,
    required this.role,
    required this.department,
    required this.photoUrl,
  });

  bool get isAdmin => role == UserRole.admin;

  UserEntity copyWith({
    String? name,
    UserRole? role,
    String? department,
    String? photoUrl,
  }) {
    return UserEntity(
      uid: uid,
      name: name ?? this.name,
      email: email,
      nik: nik,
      role: role ?? this.role,
      department: department ?? this.department,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    nik,
    role,
    department,
    photoUrl,
  ];
}

// Part of: Admin - Presentation

part of 'employee_list_bloc.dart';

enum EmployeeListStatus { initial, loading, loaded, error }

class EmployeeListState extends Equatable {
  final EmployeeListStatus status;
  final List<UserEntity> users;
  final String query; // kata kunci pencarian; '' = tampil semua
  final String? message;

  const EmployeeListState({
    this.status = EmployeeListStatus.initial,
    this.users = const [],
    this.query = '',
    this.message,
  });

  /// User yang cocok dengan [query] (nama/NIK/departemen, tanpa peduli kapital).
  List<UserEntity> get visibleUsers {
    if (query.trim().isEmpty) return users;
    final q = query.trim().toLowerCase();
    return users
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.nik.toLowerCase().contains(q) ||
              u.department.toLowerCase().contains(q),
        )
        .toList();
  }

  EmployeeListState copyWith({
    EmployeeListStatus? status,
    List<UserEntity>? users,
    String? query,
    String? message,
  }) {
    return EmployeeListState(
      status: status ?? this.status,
      users: users ?? this.users,
      query: query ?? this.query,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, users, query, message];
}

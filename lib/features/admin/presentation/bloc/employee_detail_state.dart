// Part of: Admin - Presentation

part of 'employee_detail_bloc.dart';

enum RoleChangeStatus { idle, saving, success, error }

class EmployeeDetailState extends Equatable {
  final UserEntity user;
  final RoleChangeStatus status;
  final String? message;

  const EmployeeDetailState({
    required this.user,
    this.status = RoleChangeStatus.idle,
    this.message,
  });

  EmployeeDetailState copyWith({
    UserEntity? user,
    RoleChangeStatus? status,
    String? message,
  }) {
    return EmployeeDetailState(
      user: user ?? this.user,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [user, status, message];
}

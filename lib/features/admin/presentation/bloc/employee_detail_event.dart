// Part of: Admin - Presentation

part of 'employee_detail_bloc.dart';

sealed class EmployeeDetailEvent extends Equatable {
  const EmployeeDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Balik peran: karyawan ↔ admin.
class EmployeeRoleToggleRequested extends EmployeeDetailEvent {
  const EmployeeRoleToggleRequested();
}

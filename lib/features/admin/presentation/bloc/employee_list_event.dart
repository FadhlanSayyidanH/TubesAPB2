// Part of: Admin - Presentation

part of 'employee_list_bloc.dart';

sealed class EmployeeListEvent extends Equatable {
  const EmployeeListEvent();

  @override
  List<Object?> get props => [];
}

class EmployeeListRequested extends EmployeeListEvent {
  const EmployeeListRequested();
}

/// Ubah kata kunci pencarian (filter client-side atas nama/NIK/departemen).
class EmployeeSearchChanged extends EmployeeListEvent {
  final String query;
  const EmployeeSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

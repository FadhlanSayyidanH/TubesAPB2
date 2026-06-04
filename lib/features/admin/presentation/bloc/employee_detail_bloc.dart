// Part of: Admin - Presentation

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/update_user_role_usecase.dart';

part 'employee_detail_event.dart';
part 'employee_detail_state.dart';

/// Mengelola perubahan peran satu user di halaman detail karyawan.
class EmployeeDetailBloc
    extends Bloc<EmployeeDetailEvent, EmployeeDetailState> {
  final UpdateUserRoleUseCase _updateRole;

  EmployeeDetailBloc({
    required UpdateUserRoleUseCase updateRole,
    required UserEntity user,
  }) : _updateRole = updateRole,
       super(EmployeeDetailState(user: user)) {
    on<EmployeeRoleToggleRequested>(_onToggle);
  }

  Future<void> _onToggle(
    EmployeeRoleToggleRequested event,
    Emitter<EmployeeDetailState> emit,
  ) async {
    final current = state.user;
    final newRole = current.isAdmin ? UserRole.employee : UserRole.admin;

    emit(state.copyWith(status: RoleChangeStatus.saving));
    final result = await _updateRole(uid: current.uid, role: newRole);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RoleChangeStatus.error,
          message: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: RoleChangeStatus.success,
          user: current.copyWith(role: newRole),
        ),
      ),
    );
  }
}

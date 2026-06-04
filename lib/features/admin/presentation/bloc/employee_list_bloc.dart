// Part of: Admin - Presentation

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/get_all_users_usecase.dart';

part 'employee_list_event.dart';
part 'employee_list_state.dart';

/// Memuat daftar seluruh user untuk halaman manajemen karyawan.
class EmployeeListBloc extends Bloc<EmployeeListEvent, EmployeeListState> {
  final GetAllUsersUseCase _getAllUsers;

  EmployeeListBloc({required GetAllUsersUseCase getAllUsers})
      : _getAllUsers = getAllUsers,
        super(const EmployeeListState()) {
    on<EmployeeListRequested>(_onRequested);
    on<EmployeeSearchChanged>(_onSearchChanged);
  }

  void _onSearchChanged(
    EmployeeSearchChanged event,
    Emitter<EmployeeListState> emit,
  ) {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onRequested(
    EmployeeListRequested event,
    Emitter<EmployeeListState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeListStatus.loading));
    final result = await _getAllUsers();
    result.fold(
      (failure) => emit(state.copyWith(
        status: EmployeeListStatus.error,
        message: failure.message,
      )),
      (users) {
        // Admin di atas, lalu urut nama — daftar yang stabil & enak dibaca.
        final sorted = [...users]..sort((a, b) {
            if (a.isAdmin != b.isAdmin) return a.isAdmin ? -1 : 1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
        emit(state.copyWith(status: EmployeeListStatus.loaded, users: sorted));
      },
    );
  }
}

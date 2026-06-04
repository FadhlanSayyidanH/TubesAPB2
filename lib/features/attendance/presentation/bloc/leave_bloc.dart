// Part of: Attendance - Presentation

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/submit_leave_usecase.dart';

part 'leave_event.dart';
part 'leave_state.dart';

/// Menangani pengajuan izin: kirim ke repository → langsung tercatat status izin.
class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final SubmitLeaveUseCase _submitLeave;

  LeaveBloc({required SubmitLeaveUseCase submitLeave})
    : _submitLeave = submitLeave,
      super(const LeaveState()) {
    on<LeaveSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    LeaveSubmitted event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(status: LeaveStatus.submitting));
    final result = await _submitLeave(
      user: event.user,
      date: event.date,
      reason: event.reason,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: LeaveStatus.error, message: failure.message),
      ),
      (_) => emit(state.copyWith(status: LeaveStatus.success)),
    );
  }
}

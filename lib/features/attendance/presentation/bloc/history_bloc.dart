// Part of: Attendance - Presentation

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_config.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/usecases/get_attendance_history_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetAttendanceHistoryUseCase _getHistory;

  HistoryBloc({required GetAttendanceHistoryUseCase getHistory})
      : _getHistory = getHistory,
        super(const HistoryState()) {
    on<HistoryLoadRequested>(_onLoad);
    on<HistoryFilterChanged>(_onFilterChanged);
    on<HistoryLoadMoreRequested>(_onLoadMore);
    on<HistoryDateRangeChanged>(_onDateRangeChanged);
  }

  void _onDateRangeChanged(
    HistoryDateRangeChanged event,
    Emitter<HistoryState> emit,
  ) {
    final clear = event.from == null && event.to == null;
    emit(state.copyWith(
      fromDate: event.from,
      toDate: event.to,
      clearDateRange: clear,
      visibleCount: AppConfig.historyPageSize, // kembali ke halaman pertama
    ));
  }

  Future<void> _onLoad(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    // Saat refresh (sudah ada data), jangan kembalikan ke shimmer.
    if (state.status != HistoryStatus.loaded) {
      emit(state.copyWith(status: HistoryStatus.loading));
    }
    final result = await _getHistory(event.userId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: HistoryStatus.error,
        message: failure.message,
      )),
      // Muat ulang → kembali ke halaman pertama (visibleCount reset).
      (records) => emit(state.copyWith(
        status: HistoryStatus.loaded,
        records: records,
        visibleCount: AppConfig.historyPageSize,
      )),
    );
  }

  void _onFilterChanged(
    HistoryFilterChanged event,
    Emitter<HistoryState> emit,
  ) {
    // Ganti filter → reset ke halaman pertama agar tak menampilkan sisa scroll
    // dari filter sebelumnya.
    final reset = AppConfig.historyPageSize;
    emit(event.filter == null
        ? state.copyWith(clearFilter: true, visibleCount: reset)
        : state.copyWith(filter: event.filter, visibleCount: reset));
  }

  void _onLoadMore(
    HistoryLoadMoreRequested event,
    Emitter<HistoryState> emit,
  ) {
    if (!state.hasMore) return;
    emit(state.copyWith(
      visibleCount: state.visibleCount + AppConfig.historyPageSize,
    ));
  }
}

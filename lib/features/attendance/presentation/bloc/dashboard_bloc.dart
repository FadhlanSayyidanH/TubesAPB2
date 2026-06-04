// Part of: Attendance - Presentation

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/weekly_stats.dart';
import '../../domain/usecases/get_today_attendance_usecase.dart';
import '../../domain/usecases/get_weekly_stats_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetTodayAttendanceUseCase _getToday;
  final GetWeeklyStatsUseCase _getWeeklyStats;

  DashboardBloc({
    required GetTodayAttendanceUseCase getToday,
    required GetWeeklyStatsUseCase getWeeklyStats,
  }) : _getToday = getToday,
       _getWeeklyStats = getWeeklyStats,
       super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Saat refresh (sudah ada data), pertahankan tampilan lama tanpa shimmer.
    if (state.status != DashboardStatus.loaded) {
      emit(state.copyWith(status: DashboardStatus.loading));
    }

    final todayResult = await _getToday(event.userId);
    final statsResult = await _getWeeklyStats(event.userId);

    final failure =
        todayResult.fold((f) => f, (_) => null) ??
        statsResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(status: DashboardStatus.error, message: failure.message),
      );
      return;
    }

    emit(
      DashboardState(
        status: DashboardStatus.loaded,
        todayAttendance: todayResult.fold((_) => null, (a) => a),
        weeklyStats: statsResult.fold((_) => null, (s) => s),
      ),
    );
  }
}

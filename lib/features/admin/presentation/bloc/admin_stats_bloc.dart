// Part of: Admin - Presentation

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../attendance/domain/entities/attendance_entity.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/usecases/get_employee_count_usecase.dart';
import '../../domain/usecases/watch_attendance_usecase.dart';

part 'admin_stats_event.dart';
part 'admin_stats_state.dart';

/// Memantau absensi 7 hari terakhir secara real-time (stream Firestore) lalu
/// menurunkan statistik admin. Jumlah karyawan diambil sekali (jarang berubah)
/// dan disegarkan lewat pull-to-refresh.
class AdminStatsBloc extends Bloc<AdminStatsEvent, AdminStatsState> {
  final WatchAttendanceUseCase _watchAttendance;
  final GetEmployeeCountUseCase _getEmployeeCount;

  int _employeeCount = 0;
  List<AttendanceEntity> _records = const [];

  AdminStatsBloc({
    required WatchAttendanceUseCase watchAttendance,
    required GetEmployeeCountUseCase getEmployeeCount,
  }) : _watchAttendance = watchAttendance,
       _getEmployeeCount = getEmployeeCount,
       super(const AdminStatsState()) {
    on<AdminDashboardStarted>(_onStarted);
    on<AdminCountRefreshRequested>(_onCountRefresh);
  }

  Future<void> _onStarted(
    AdminDashboardStarted event,
    Emitter<AdminStatsState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    final countResult = await _getEmployeeCount();
    final failure = countResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: AdminStatus.error, message: failure.message));
      return;
    }
    _employeeCount = countResult.getOrElse(() => 0);

    // 7 hari terakhir termasuk hari ini → mundur 6 hari dari hari ini.
    final fromDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().subtract(const Duration(days: 6)));

    await emit.forEach<List<AttendanceEntity>>(
      _watchAttendance(fromDate),
      onData: (records) {
        _records = records;
        return state.copyWith(
          status: AdminStatus.loaded,
          stats: computeAdminStats(records, _employeeCount, DateTime.now()),
        );
      },
      onError: (_, _) => state.copyWith(
        status: AdminStatus.error,
        message: AppStrings.errServerUnreachable,
      ),
    );
  }

  /// Pull-to-refresh: stream absensi sudah real-time, jadi yang perlu disegarkan
  /// hanya jumlah karyawan (penyebut kehadiran) lalu hitung ulang.
  Future<void> _onCountRefresh(
    AdminCountRefreshRequested event,
    Emitter<AdminStatsState> emit,
  ) async {
    final countResult = await _getEmployeeCount();
    countResult.fold((_) {}, (count) {
      _employeeCount = count;
      emit(
        state.copyWith(
          status: AdminStatus.loaded,
          stats: computeAdminStats(_records, count, DateTime.now()),
        ),
      );
    });
  }
}

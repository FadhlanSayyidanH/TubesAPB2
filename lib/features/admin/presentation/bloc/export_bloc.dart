// Part of: Admin - Presentation

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/csv_export_service.dart';
import '../../domain/attendance_csv.dart';
import '../../domain/usecases/get_all_users_usecase.dart';
import '../../domain/usecases/get_attendance_between_usecase.dart';

part 'export_event.dart';
part 'export_state.dart';

/// Membangun laporan absensi CSV untuk rentang tanggal: ambil catatan absensi +
/// peta NIK, susun baris (fungsi murni), tulis file temp, kembalikan path-nya
/// agar halaman bisa membuka share sheet.
class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final GetAttendanceBetweenUseCase _getAttendanceBetween;
  final GetAllUsersUseCase _getAllUsers;
  final CsvExportService _csvService;

  ExportBloc({
    required GetAttendanceBetweenUseCase getAttendanceBetween,
    required GetAllUsersUseCase getAllUsers,
    required CsvExportService csvService,
  }) : _getAttendanceBetween = getAttendanceBetween,
       _getAllUsers = getAllUsers,
       _csvService = csvService,
       super(const ExportState()) {
    on<ExportRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ExportRequested event,
    Emitter<ExportState> emit,
  ) async {
    emit(state.copyWith(status: ExportStatus.loading, clearFilePath: true));

    final fmt = DateFormat('yyyy-MM-dd');
    final fromKey = fmt.format(event.from);
    final toKey = fmt.format(event.to);

    final recordsResult = await _getAttendanceBetween(
      fromDate: fromKey,
      toDate: toKey,
    );
    final failure = recordsResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(status: ExportStatus.failure, message: failure.message),
      );
      return;
    }
    final records = recordsResult.getOrElse(() => const []);
    if (records.isEmpty) {
      emit(
        state.copyWith(
          status: ExportStatus.failure,
          message: AppStrings.exportEmpty,
        ),
      );
      return;
    }

    // NIK opsional: kalau gagal ambil user, lanjut dengan peta kosong (NIK '-').
    final usersResult = await _getAllUsers();
    final nikByUid = <String, String>{};
    usersResult.fold((_) {}, (users) {
      for (final u in users) {
        nikByUid[u.uid] = u.nik;
      }
    });

    try {
      final rows = buildAttendanceCsvRows(records, nikByUid);
      final fileName = 'laporan_absensi_${fromKey}_sd_$toKey.csv';
      final path = await _csvService.writeCsv(rows, fileName);
      emit(
        state.copyWith(
          status: ExportStatus.success,
          filePath: path,
          recordCount: records.length,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ExportStatus.failure,
          message: AppStrings.exportFailed,
        ),
      );
    }
  }
}

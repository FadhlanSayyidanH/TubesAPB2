// Part of: Attendance - Presentation

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/location_status.dart';
import '../../domain/entities/office_entity.dart';
import '../../domain/usecases/clock_in_usecase.dart';
import '../../domain/usecases/clock_out_usecase.dart';
import '../../domain/usecases/get_location_status_usecase.dart';
import '../../domain/usecases/get_primary_office_usecase.dart';
import '../../domain/usecases/get_today_attendance_usecase.dart';

part 'clock_in_event.dart';
part 'clock_in_state.dart';

class ClockInBloc extends Bloc<ClockInEvent, ClockInState> {
  final GetPrimaryOfficeUseCase _getOffice;
  final GetLocationStatusUseCase _getLocationStatus;
  final GetTodayAttendanceUseCase _getToday;
  final ClockInUseCase _clockIn;
  final ClockOutUseCase _clockOut;

  Timer? _pollTimer;

  ClockInBloc({
    required GetPrimaryOfficeUseCase getOffice,
    required GetLocationStatusUseCase getLocationStatus,
    required GetTodayAttendanceUseCase getToday,
    required ClockInUseCase clockIn,
    required ClockOutUseCase clockOut,
  })  : _getOffice = getOffice,
        _getLocationStatus = getLocationStatus,
        _getToday = getToday,
        _clockIn = clockIn,
        _clockOut = clockOut,
        super(const ClockInState()) {
    on<ClockInStarted>(_onStarted);
    on<LocationRefreshRequested>(_onRefreshRequested);
    on<AttendanceSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(
    ClockInStarted event,
    Emitter<ClockInState> emit,
  ) async {
    emit(state.copyWith(status: ClockInStatus.loadingOffice, user: event.user));

    final officeResult = await _getOffice();
    final office = officeResult.fold((_) => null, (o) => o);
    if (office == null) {
      emit(state.copyWith(
        status: ClockInStatus.officeError,
        message: officeResult.fold((f) => f.message, (_) => null),
      ));
      return;
    }

    // Absensi hari ini menentukan apakah tombol jadi "masuk" atau "pulang".
    final todayResult = await _getToday(event.user.uid);
    final today = todayResult.fold((_) => null, (a) => a);

    emit(state.copyWith(
      status: ClockInStatus.locating,
      office: office,
      todayAttendance: today,
    ));
    await _refreshLocation(emit, office, isManual: false);
    _startPolling();
  }

  Future<void> _onRefreshRequested(
    LocationRefreshRequested event,
    Emitter<ClockInState> emit,
  ) async {
    final office = state.office;
    if (office == null) return;
    await _refreshLocation(emit, office, isManual: event.isManual);
  }

  Future<void> _refreshLocation(
    Emitter<ClockInState> emit,
    OfficeEntity office, {
    required bool isManual,
  }) async {
    if (isManual || state.location == null) {
      emit(state.copyWith(isRefreshing: true));
    }

    final result = await _getLocationStatus(office);
    result.fold(
      (failure) {
        _pollTimer?.cancel();
        emit(state.copyWith(
          status: ClockInStatus.locationError,
          message: failure.message,
          canOpenSettings:
              failure is LocationFailure ? failure.openSettings : false,
          isRefreshing: false,
        ));
      },
      (location) => emit(state.copyWith(
        status: ClockInStatus.ready,
        location: location,
        isRefreshing: false,
      )),
    );
  }

  Future<void> _onSubmitted(
    AttendanceSubmitted event,
    Emitter<ClockInState> emit,
  ) async {
    final user = state.user;
    final location = state.location;
    if (user == null || location == null) return;

    // Gerbang radius: tolak absen bila di luar area, dengan pesan jaraknya.
    if (!location.isWithinOfficeRadius) {
      emit(state.copyWith(
        action: ClockInAction.failed,
        message: AppStrings.outsideRadiusDialog(location.readableDistance),
      ));
      emit(state.copyWith(action: ClockInAction.idle));
      return;
    }

    final today = state.todayAttendance;
    // Clock-in wajib disertai selfie hasil verifikasi wajah (gerbang Hari 7).
    if (today == null && event.selfiePath == null) {
      emit(state.copyWith(
        action: ClockInAction.failed,
        message: AppStrings.faceGateBeforeClockIn,
      ));
      emit(state.copyWith(action: ClockInAction.idle));
      return;
    }

    emit(state.copyWith(action: ClockInAction.submitting));

    if (today == null) {
      final result = await _clockIn(
        user: user,
        location: location,
        selfiePath: event.selfiePath!,
      );
      result.fold(
        (failure) => emit(state.copyWith(
          action: ClockInAction.failed,
          message: failure.message,
        )),
        (record) => emit(state.copyWith(
          action: ClockInAction.clockedIn,
          todayAttendance: record,
        )),
      );
    } else {
      final result = await _clockOut(today: today, location: location);
      result.fold(
        (failure) => emit(state.copyWith(
          action: ClockInAction.failed,
          message: failure.message,
        )),
        (record) => emit(state.copyWith(
          action: ClockInAction.clockedOut,
          todayAttendance: record,
        )),
      );
    }
    // Kembalikan ke idle agar BlocListener bisa menangkap aksi berikutnya.
    emit(state.copyWith(action: ClockInAction.idle));
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => add(const LocationRefreshRequested()),
    );
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}

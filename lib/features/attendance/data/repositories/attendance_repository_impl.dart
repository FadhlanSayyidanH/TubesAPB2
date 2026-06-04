// Part of: Attendance - Data

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/haversine.dart';
import '../../../../core/utils/image_encoder.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/location_status.dart';
import '../../domain/entities/office_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../datasources/location_datasource.dart';
import '../datasources/office_remote_datasource.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final OfficeRemoteDataSource _officeRemote;
  final AttendanceRemoteDataSource _attendanceRemote;
  final LocationDataSource _location;
  final ImageEncoder _imageEncoder;
  final NetworkInfo _networkInfo;

  AttendanceRepositoryImpl(
    this._officeRemote,
    this._attendanceRemote,
    this._location,
    this._imageEncoder,
    this._networkInfo,
  );

  static final DateFormat _dateKey = DateFormat('yyyy-MM-dd');

  @override
  Future<Either<Failure, OfficeEntity>> getPrimaryOffice() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    try {
      return Right(await _officeRemote.getPrimaryOffice());
    } on OfficeNotConfiguredException {
      return Left(LocationFailure(AppStrings.errOfficeNotConfigured));
    } on ServerException {
      return Left(NetworkFailure(AppStrings.errServerUnreachable));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, LocationStatus>> getLocationStatus(
    OfficeEntity office,
  ) async {
    try {
      final position = await _location.getCurrentPosition();
      final distance = calculateDistanceMeters(
        position.latitude,
        position.longitude,
        office.latitude,
        office.longitude,
      );
      return Right(
        LocationStatus(
          userLatitude: position.latitude,
          userLongitude: position.longitude,
          distanceMeters: distance,
          isWithinOfficeRadius: distance <= office.radiusMeters,
        ),
      );
    } on LocationServiceDisabledException {
      return Left(LocationFailure(AppStrings.errLocationServiceOff));
    } on LocationPermissionDeniedException {
      return Left(LocationFailure(AppStrings.errLocationDenied));
    } on LocationPermissionPermanentlyDeniedException {
      return Left(
        LocationFailure(
          AppStrings.errLocationDeniedForever,
          openSettings: true,
        ),
      );
    } on LocationTimeoutException {
      return Left(LocationFailure(AppStrings.errLocationTimeout));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity?>> getTodayAttendance(
    String userId,
  ) async {
    try {
      final today = _dateKey.format(DateTime.now());
      return Right(await _attendanceRemote.getTodayAttendance(userId, today));
    } on ServerException {
      return Left(NetworkFailure(AppStrings.errServerUnreachable));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> clockIn({
    required UserEntity user,
    required LocationStatus location,
    required String selfiePath,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    final now = DateTime.now();
    final date = _dateKey.format(now);

    // Siapkan selfie (kompres → data URI base64) lebih dulu; kegagalan di sini
    // tidak boleh menyisakan catatan absen tanpa foto, jadi tahan sebelum tulis.
    final String selfieUrl;
    try {
      selfieUrl = await _imageEncoder.encodeToDataUri(selfiePath);
    } catch (_) {
      return Left(ServerFailure(AppStrings.errSelfieUploadFailed));
    }

    try {
      final record = AttendanceModel(
        id: '${user.uid}_$date',
        userId: user.uid,
        userName: user.name,
        date: date,
        clockIn: now,
        clockInLat: location.userLatitude,
        clockInLon: location.userLongitude,
        selfieUrl: selfieUrl,
        status: _statusForClockIn(now),
        isInRadius: location.isWithinOfficeRadius,
      );
      return Right(await _attendanceRemote.createClockIn(record));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> clockOut({
    required AttendanceEntity today,
    required LocationStatus location,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    try {
      final now = DateTime.now();
      final duration = now.difference(today.clockIn).inMinutes;
      await _attendanceRemote.clockOut(
        attendanceId: today.id,
        clockOutTime: now,
        latitude: location.userLatitude,
        longitude: location.userLongitude,
        workDurationMinutes: duration,
      );
      return Right(
        AttendanceModel(
          id: today.id,
          userId: today.userId,
          userName: today.userName,
          date: today.date,
          clockIn: today.clockIn,
          clockOut: now,
          clockInLat: today.clockInLat,
          clockInLon: today.clockInLon,
          clockOutLat: location.userLatitude,
          clockOutLon: location.userLongitude,
          selfieUrl: today.selfieUrl,
          status: today.status,
          isInRadius: today.isInRadius,
          workDurationMinutes: duration,
        ),
      );
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getWeekAttendance(
    String userId,
  ) async {
    try {
      final all = await _attendanceRemote.getUserAttendance(userId);
      final (start, end) = _currentWeekRange();
      final thisWeek =
          all
              .where(
                (a) =>
                    a.date.compareTo(start) >= 0 && a.date.compareTo(end) <= 0,
              )
              .toList()
            ..sort((a, b) => b.clockIn.compareTo(a.clockIn));
      return Right(thisWeek);
    } on ServerException {
      return Left(NetworkFailure(AppStrings.errServerUnreachable));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceHistory(
    String userId,
  ) async {
    try {
      final all = await _attendanceRemote.getUserAttendance(userId);
      // Urut client-side (query equality tunggal → tak butuh composite index).
      all.sort((a, b) => b.clockIn.compareTo(a.clockIn));
      return Right(all);
    } on ServerException {
      return Left(NetworkFailure(AppStrings.errServerUnreachable));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> submitLeave({
    required UserEntity user,
    required DateTime date,
    required String reason,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    final dateKey = _dateKey.format(date);
    try {
      final leave = AttendanceModel(
        id: '${user.uid}_$dateKey',
        userId: user.uid,
        userName: user.name,
        date: dateKey,
        // clockIn dipatok tengah malam tanggal izin (bukan absen fisik).
        clockIn: DateTime(date.year, date.month, date.day),
        clockInLat: 0,
        clockInLon: 0,
        selfieUrl: '',
        status: AttendanceStatus.izin,
        isInRadius: false,
        reason: reason.trim(),
      );
      return Right(await _attendanceRemote.createLeave(leave));
    } on AttendanceAlreadyExistsException {
      return Left(ServerFailure(AppStrings.errLeaveAlreadyExists));
    } on ServerException {
      return Left(NetworkFailure(AppStrings.errServerUnreachable));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  /// Rentang tanggal (yyyy-MM-dd) Senin–Minggu untuk minggu yang memuat hari ini.
  (String, String) _currentWeekRange() {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return (_dateKey.format(monday), _dateKey.format(sunday));
  }

  /// Telat bila clock-in melewati ambang (default 08:30).
  AttendanceStatus _statusForClockIn(DateTime time) {
    final threshold = DateTime(
      time.year,
      time.month,
      time.day,
      AppConfig.lateThresholdHour,
      AppConfig.lateThresholdMinute,
    );
    return time.isAfter(threshold)
        ? AttendanceStatus.telat
        : AttendanceStatus.hadir;
  }
}

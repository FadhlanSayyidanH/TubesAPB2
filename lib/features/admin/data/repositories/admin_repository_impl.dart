// Part of: Admin - Data

import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../attendance/domain/entities/attendance_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  AdminRepositoryImpl(this._remote, this._networkInfo);

  @override
  Stream<List<AttendanceEntity>> watchAttendanceSince(String fromDate) =>
      _remote.watchAttendanceSince(fromDate);

  @override
  Future<Either<Failure, int>> getEmployeeCount() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    try {
      return Right(await _remote.getEmployeeCount());
    } catch (_) {
      return Left(ServerFailure(AppStrings.errServerUnreachable));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceBetween(
    String fromDate,
    String toDate,
  ) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    try {
      return Right(await _remote.getAttendanceBetween(fromDate, toDate));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errServerUnreachable));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    try {
      return Right(await _remote.getAllUsers());
    } catch (_) {
      return Left(ServerFailure(AppStrings.errServerUnreachable));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole(
    String uid,
    UserRole role,
  ) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    try {
      await _remote.updateUserRole(
        uid,
        role == UserRole.admin ? 'admin' : 'employee',
      );
      return const Right(null);
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }
}

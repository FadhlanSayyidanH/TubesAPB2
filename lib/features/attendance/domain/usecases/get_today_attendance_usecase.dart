// Part of: Attendance - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class GetTodayAttendanceUseCase {
  final AttendanceRepository _repository;

  GetTodayAttendanceUseCase(this._repository);

  Future<Either<Failure, AttendanceEntity?>> call(String userId) =>
      _repository.getTodayAttendance(userId);
}

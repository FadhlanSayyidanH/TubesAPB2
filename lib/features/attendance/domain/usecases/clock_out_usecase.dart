// Part of: Attendance - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/attendance_entity.dart';
import '../entities/location_status.dart';
import '../repositories/attendance_repository.dart';

class ClockOutUseCase {
  final AttendanceRepository _repository;

  ClockOutUseCase(this._repository);

  Future<Either<Failure, AttendanceEntity>> call({
    required AttendanceEntity today,
    required LocationStatus location,
  }) {
    return _repository.clockOut(today: today, location: location);
  }
}

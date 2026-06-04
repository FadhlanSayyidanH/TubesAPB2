// Part of: Attendance - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/attendance_entity.dart';
import '../entities/location_status.dart';
import '../repositories/attendance_repository.dart';

class ClockInUseCase {
  final AttendanceRepository _repository;

  ClockInUseCase(this._repository);

  Future<Either<Failure, AttendanceEntity>> call({
    required UserEntity user,
    required LocationStatus location,
    required String selfiePath,
  }) {
    return _repository.clockIn(
      user: user,
      location: location,
      selfiePath: selfiePath,
    );
  }
}

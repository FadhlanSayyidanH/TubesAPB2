// Part of: Admin - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../attendance/domain/entities/attendance_entity.dart';
import '../repositories/admin_repository.dart';

class GetAttendanceBetweenUseCase {
  final AdminRepository _repository;

  GetAttendanceBetweenUseCase(this._repository);

  Future<Either<Failure, List<AttendanceEntity>>> call({
    required String fromDate,
    required String toDate,
  }) => _repository.getAttendanceBetween(fromDate, toDate);
}

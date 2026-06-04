// Part of: Attendance - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class SubmitLeaveUseCase {
  final AttendanceRepository _repository;

  SubmitLeaveUseCase(this._repository);

  Future<Either<Failure, AttendanceEntity>> call({
    required UserEntity user,
    required DateTime date,
    required String reason,
  }) {
    return _repository.submitLeave(user: user, date: date, reason: reason);
  }
}

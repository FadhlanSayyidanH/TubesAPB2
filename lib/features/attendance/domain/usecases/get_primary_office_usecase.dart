// Part of: Attendance - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/office_entity.dart';
import '../repositories/attendance_repository.dart';

class GetPrimaryOfficeUseCase {
  final AttendanceRepository _repository;

  GetPrimaryOfficeUseCase(this._repository);

  Future<Either<Failure, OfficeEntity>> call() =>
      _repository.getPrimaryOffice();
}

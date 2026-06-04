// Part of: Attendance - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/location_status.dart';
import '../entities/office_entity.dart';
import '../repositories/attendance_repository.dart';

class GetLocationStatusUseCase {
  final AttendanceRepository _repository;

  GetLocationStatusUseCase(this._repository);

  Future<Either<Failure, LocationStatus>> call(OfficeEntity office) =>
      _repository.getLocationStatus(office);
}

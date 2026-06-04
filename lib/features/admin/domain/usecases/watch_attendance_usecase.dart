// Part of: Admin - Domain

import '../../../attendance/domain/entities/attendance_entity.dart';
import '../repositories/admin_repository.dart';

class WatchAttendanceUseCase {
  final AdminRepository _repository;

  WatchAttendanceUseCase(this._repository);

  Stream<List<AttendanceEntity>> call(String fromDate) =>
      _repository.watchAttendanceSince(fromDate);
}

// Part of: Admin - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/admin_repository.dart';

class GetEmployeeCountUseCase {
  final AdminRepository _repository;

  GetEmployeeCountUseCase(this._repository);

  Future<Either<Failure, int>> call() => _repository.getEmployeeCount();
}

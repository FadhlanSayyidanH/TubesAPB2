// Part of: Admin - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/admin_repository.dart';

class GetAllUsersUseCase {
  final AdminRepository _repository;

  GetAllUsersUseCase(this._repository);

  Future<Either<Failure, List<UserEntity>>> call() => _repository.getAllUsers();
}

// Part of: Admin - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/admin_repository.dart';

class UpdateUserRoleUseCase {
  final AdminRepository _repository;

  UpdateUserRoleUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String uid,
    required UserRole role,
  }) =>
      _repository.updateUserRole(uid, role);
}

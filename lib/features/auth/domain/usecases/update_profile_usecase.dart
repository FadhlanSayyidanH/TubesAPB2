// Part of: Auth - Domain

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String uid,
    required String name,
    String? photoPath,
  }) {
    return _repository.updateProfile(
      uid: uid,
      name: name.trim(),
      photoPath: photoPath,
    );
  }
}

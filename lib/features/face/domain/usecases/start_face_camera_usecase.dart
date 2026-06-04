// Part of: Face Detection - Domain

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/face_repository.dart';

class StartFaceCameraUseCase {
  final FaceRepository _repository;

  StartFaceCameraUseCase(this._repository);

  Future<Either<Failure, CameraController>> call() =>
      _repository.startFrontCamera();
}

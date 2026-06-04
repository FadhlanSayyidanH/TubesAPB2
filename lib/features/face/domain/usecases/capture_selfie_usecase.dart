// Part of: Face Detection - Domain

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/face_capture.dart';
import '../repositories/face_repository.dart';

class CaptureSelfieUseCase {
  final FaceRepository _repository;

  CaptureSelfieUseCase(this._repository);

  Future<Either<Failure, FaceCapture>> call(CameraController controller) =>
      _repository.captureSelfie(controller);
}

// Part of: Face Detection - Data

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/face_quality.dart';
import '../../domain/entities/face_capture.dart';
import '../../domain/repositories/face_repository.dart';
import '../datasources/face_datasource.dart';

class FaceRepositoryImpl implements FaceRepository {
  final FaceDataSource _dataSource;

  FaceRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, CameraController>> startFrontCamera() async {
    try {
      await _dataSource.ensureCameraPermission();
      return Right(await _dataSource.initFrontCamera());
    } on CameraPermissionDeniedException {
      return Left(CameraFailure(AppStrings.errCameraPermissionDenied));
    } on CameraPermissionPermanentlyDeniedException {
      return Left(CameraFailure(
        AppStrings.errCameraPermissionForever,
        openSettings: true,
      ));
    } on CameraUnavailableException {
      return Left(CameraFailure(AppStrings.errCameraUnavailable));
    } catch (_) {
      return Left(CameraFailure(AppStrings.errCameraUnavailable));
    }
  }

  @override
  Future<Either<Failure, FaceCapture>> captureSelfie(
    CameraController controller,
  ) async {
    try {
      final shot = await _dataSource.captureAndAnalyze(controller);
      final rejection = evaluateFace(shot.metrics);
      if (rejection != null) {
        // Buang file yang gagal validasi agar cache sementara tidak menumpuk.
        await _safeDelete(shot.imagePath);
        return Left(FaceQualityFailure(rejection.message));
      }
      return Right(FaceCapture(shot.imagePath));
    } on CameraUnavailableException {
      return Left(CameraFailure(AppStrings.errCameraUnavailable));
    } catch (_) {
      return Left(CameraFailure(AppStrings.errCameraUnavailable));
    }
  }

  Future<void> _safeDelete(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Gagal hapus file sementara bukan masalah kritis — abaikan.
    }
  }
}

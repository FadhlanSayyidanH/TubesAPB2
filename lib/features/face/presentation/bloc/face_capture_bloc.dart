// Part of: Face Detection - Presentation

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/capture_selfie_usecase.dart';
import '../../domain/usecases/start_face_camera_usecase.dart';

part 'face_capture_event.dart';
part 'face_capture_state.dart';

class FaceCaptureBloc extends Bloc<FaceCaptureEvent, FaceCaptureState> {
  final StartFaceCameraUseCase _startCamera;
  final CaptureSelfieUseCase _captureSelfie;

  FaceCaptureBloc({
    required StartFaceCameraUseCase startCamera,
    required CaptureSelfieUseCase captureSelfie,
  })  : _startCamera = startCamera,
        _captureSelfie = captureSelfie,
        super(const FaceCaptureState()) {
    on<FaceCameraRequested>(_onCameraRequested);
    on<FaceShutterPressed>(_onShutterPressed);
  }

  Future<void> _onCameraRequested(
    FaceCameraRequested event,
    Emitter<FaceCaptureState> emit,
  ) async {
    // Buang controller lama bila ini percobaan ulang setelah error.
    await state.controller?.dispose();
    emit(state.copyWith(
      status: FaceCaptureStatus.initializing,
      clearController: true,
    ));

    final result = await _startCamera();
    result.fold(
      (failure) => emit(state.copyWith(
        status: FaceCaptureStatus.cameraError,
        cameraErrorMessage: failure.message,
        canOpenSettings:
            failure is CameraFailure ? failure.openSettings : false,
      )),
      (controller) => emit(state.copyWith(
        status: FaceCaptureStatus.ready,
        controller: controller,
      )),
    );
  }

  Future<void> _onShutterPressed(
    FaceShutterPressed event,
    Emitter<FaceCaptureState> emit,
  ) async {
    final controller = state.controller;
    if (controller == null || state.status == FaceCaptureStatus.capturing) {
      return;
    }

    emit(state.copyWith(status: FaceCaptureStatus.capturing));
    final result = await _captureSelfie(controller);
    result.fold(
      (failure) {
        if (failure is FaceQualityFailure) {
          // Penolakan kualitas: bisa diulang. Tampilkan pesan lalu kembali siap.
          emit(state.copyWith(
            status: FaceCaptureStatus.ready,
            rejectionMessage: failure.message,
          ));
          emit(state.copyWith(status: FaceCaptureStatus.ready));
        } else {
          emit(state.copyWith(
            status: FaceCaptureStatus.cameraError,
            cameraErrorMessage: failure.message,
            canOpenSettings:
                failure is CameraFailure ? failure.openSettings : false,
          ));
        }
      },
      (capture) => emit(state.copyWith(
        status: FaceCaptureStatus.success,
        capturedPath: capture.imagePath,
      )),
    );
  }

  @override
  Future<void> close() {
    state.controller?.dispose();
    return super.close();
  }
}

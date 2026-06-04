// Part of: Face Detection - Presentation

part of 'face_capture_bloc.dart';

sealed class FaceCaptureEvent extends Equatable {
  const FaceCaptureEvent();

  @override
  List<Object?> get props => [];
}

/// Dipicu saat halaman dibuka (atau saat retry): minta izin + nyalakan kamera.
class FaceCameraRequested extends FaceCaptureEvent {
  const FaceCameraRequested();
}

/// Tombol rana ditekan: ambil foto lalu validasi kualitasnya.
class FaceShutterPressed extends FaceCaptureEvent {
  const FaceShutterPressed();
}

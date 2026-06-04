// Part of: Face Detection - Presentation

part of 'face_capture_bloc.dart';

enum FaceCaptureStatus {
  initializing, // minta izin & menyalakan kamera
  ready, // preview tampil, siap mengambil foto
  capturing, // sedang mengambil + memeriksa kualitas
  cameraError, // izin ditolak / kamera tidak tersedia (fatal layar ini)
  success, // selfie lolos verifikasi
}

class FaceCaptureState extends Equatable {
  final FaceCaptureStatus status;
  final CameraController? controller;

  /// Path selfie yang lolos verifikasi (saat [status] == success).
  final String? capturedPath;

  /// Pesan error kamera/izin (saat [status] == cameraError).
  final String? cameraErrorMessage;
  final bool canOpenSettings;

  /// Pesan penolakan kualitas — transien, ditampilkan sebagai snackbar lalu
  /// dibersihkan agar penolakan berikutnya (meski sama) tetap memicu listener.
  final String? rejectionMessage;

  const FaceCaptureState({
    this.status = FaceCaptureStatus.initializing,
    this.controller,
    this.capturedPath,
    this.cameraErrorMessage,
    this.canOpenSettings = false,
    this.rejectionMessage,
  });

  FaceCaptureState copyWith({
    FaceCaptureStatus? status,
    CameraController? controller,
    bool clearController = false,
    String? capturedPath,
    String? cameraErrorMessage,
    bool canOpenSettings = false,
    String? rejectionMessage,
  }) {
    return FaceCaptureState(
      status: status ?? this.status,
      controller: clearController ? null : (controller ?? this.controller),
      capturedPath: capturedPath,
      cameraErrorMessage: cameraErrorMessage,
      canOpenSettings: canOpenSettings,
      rejectionMessage: rejectionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    controller,
    capturedPath,
    cameraErrorMessage,
    canOpenSettings,
    rejectionMessage,
  ];
}

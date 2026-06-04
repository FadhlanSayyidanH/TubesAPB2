// Part of: Face Detection - Domain

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/face_capture.dart';

/// Kontrak verifikasi wajah: siapkan kamera depan lalu ambil + validasi selfie.
///
/// Catatan: [CameraController] (tipe dari paket `camera`) sengaja "bocor" ke
/// kontrak ini supaya widget preview bisa memakainya langsung. Pilihan pragmatis
/// agar tidak membungkus seluruh siklus hidup kamera (CLAUDE.md §3: jangan
/// over-engineer).
abstract class FaceRepository {
  /// Minta izin kamera lalu inisialisasi kamera depan.
  Future<Either<Failure, CameraController>> startFrontCamera();

  /// Ambil foto dari [controller], hitung metrik, dan validasi kualitas.
  /// Gagal validasi dikembalikan sebagai [FaceQualityFailure] (bisa diulang).
  Future<Either<Failure, FaceCapture>> captureSelfie(
    CameraController controller,
  );
}

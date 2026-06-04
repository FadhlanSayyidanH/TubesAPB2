// Part of: Face Detection - Core Util

import '../constants/app_config.dart';
import '../constants/app_strings.dart';

/// Alasan sebuah frame selfie ditolak. `null` = lolos verifikasi.
enum FaceRejection { noFace, multipleFaces, tooDark, tooBright, tooBlurry }

/// Metrik hasil analisis satu frame selfie, dipakai untuk validasi kualitas.
class FaceMetrics {
  /// Jumlah wajah yang dideteksi ML Kit.
  final int faceCount;

  /// Rata-rata luma 0–255. Rendah = gelap, tinggi = over-exposed/silau.
  final double brightness;

  /// Variance dari Laplacian. Makin kecil makin buram (kurang fokus).
  final double blurVariance;

  const FaceMetrics({
    required this.faceCount,
    required this.brightness,
    required this.blurVariance,
  });
}

/// Validasi kualitas selfie secara berurutan sesuai aturan bisnis Hari 6:
/// tepat satu wajah → pencahayaan cukup → cukup tajam (tidak buram).
///
/// Urutan disengaja: pencahayaan dicek SEBELUM blur. Frame yang terlalu gelap
/// otomatis punya variance Laplacian rendah dan akan keliru dilaporkan "buram";
/// pesan "terlalu gelap" jauh lebih actionable buat user.
FaceRejection? evaluateFace(FaceMetrics metrics) {
  if (metrics.faceCount == 0) return FaceRejection.noFace;
  if (metrics.faceCount > 1) return FaceRejection.multipleFaces;
  if (metrics.brightness < AppConfig.faceBrightnessMin) {
    return FaceRejection.tooDark;
  }
  if (metrics.brightness > AppConfig.faceBrightnessMax) {
    return FaceRejection.tooBright;
  }
  if (metrics.blurVariance < AppConfig.faceBlurMinVariance) {
    return FaceRejection.tooBlurry;
  }
  return null;
}

extension FaceRejectionMessage on FaceRejection {
  /// Pesan siap-tampil (Bahasa Indonesia, actionable) untuk tiap alasan tolak.
  String get message => switch (this) {
    FaceRejection.noFace => AppStrings.faceNotDetected,
    FaceRejection.multipleFaces => AppStrings.faceMultipleDetected,
    FaceRejection.tooDark => AppStrings.faceTooDark,
    FaceRejection.tooBright => AppStrings.faceTooBright,
    FaceRejection.tooBlurry => AppStrings.faceTooBlurry,
  };
}

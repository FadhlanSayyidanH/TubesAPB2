// Part of: Face Detection - Core Util (test)

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_attendance/core/constants/app_strings.dart';
import 'package:smart_attendance/core/utils/face_quality.dart';

void main() {
  // Metrik dasar yang lolos semua ambang; tiap test menimpa satu nilai saja.
  const ok = FaceMetrics(faceCount: 1, brightness: 120, blurVariance: 300);

  group('evaluateFace', () {
    test('selfie ideal (1 wajah, terang cukup, tajam) lolos', () {
      expect(evaluateFace(ok), isNull);
    });

    test('tanpa wajah ditolak dengan alasan noFace', () {
      final r = evaluateFace(const FaceMetrics(
          faceCount: 0, brightness: 120, blurVariance: 300));
      expect(r, FaceRejection.noFace);
    });

    test('lebih dari satu wajah ditolak', () {
      final r = evaluateFace(const FaceMetrics(
          faceCount: 2, brightness: 120, blurVariance: 300));
      expect(r, FaceRejection.multipleFaces);
    });

    test('terlalu gelap ditolak', () {
      final r = evaluateFace(const FaceMetrics(
          faceCount: 1, brightness: 30, blurVariance: 300));
      expect(r, FaceRejection.tooDark);
    });

    test('terlalu terang/silau ditolak', () {
      final r = evaluateFace(const FaceMetrics(
          faceCount: 1, brightness: 240, blurVariance: 300));
      expect(r, FaceRejection.tooBright);
    });

    test('foto buram ditolak', () {
      final r = evaluateFace(const FaceMetrics(
          faceCount: 1, brightness: 120, blurVariance: 50));
      expect(r, FaceRejection.tooBlurry);
    });

    test('pencahayaan dicek sebelum blur: frame gelap & buram → tooDark', () {
      // Frame gelap punya variance rendah; pesan "gelap" harus menang.
      final r = evaluateFace(const FaceMetrics(
          faceCount: 1, brightness: 20, blurVariance: 10));
      expect(r, FaceRejection.tooDark);
    });

    test('jumlah wajah diprioritaskan di atas pencahayaan/blur', () {
      final r = evaluateFace(const FaceMetrics(
          faceCount: 0, brightness: 20, blurVariance: 10));
      expect(r, FaceRejection.noFace);
    });
  });

  group('FaceRejectionMessage', () {
    test('tiap alasan punya pesan Bahasa Indonesia yang sesuai', () {
      expect(FaceRejection.noFace.message, AppStrings.faceNotDetected);
      expect(FaceRejection.multipleFaces.message, AppStrings.faceMultipleDetected);
      expect(FaceRejection.tooDark.message, AppStrings.faceTooDark);
      expect(FaceRejection.tooBright.message, AppStrings.faceTooBright);
      expect(FaceRejection.tooBlurry.message, AppStrings.faceTooBlurry);
    });
  });
}

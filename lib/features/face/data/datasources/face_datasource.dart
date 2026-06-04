// Part of: Face Detection - Data

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/face_quality.dart';

/// Hasil capture mentah: path file + metrik untuk divalidasi di repository.
class FaceShot {
  final String imagePath;
  final FaceMetrics metrics;

  const FaceShot({required this.imagePath, required this.metrics});
}

abstract class FaceDataSource {
  /// Pastikan izin kamera diberikan; lempar exception bila ditolak.
  Future<void> ensureCameraPermission();

  /// Buat & inisialisasi [CameraController] untuk kamera depan.
  Future<CameraController> initFrontCamera();

  /// Ambil foto dari [controller], hitung jumlah wajah + brightness + blur.
  Future<FaceShot> captureAndAnalyze(CameraController controller);
}

class FaceDataSourceImpl implements FaceDataSource {
  // Mode cepat: kita hanya butuh jumlah wajah (bukan landmark/klasifikasi),
  // jadi prioritaskan kecepatan agar capture terasa responsif.
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );

  @override
  Future<void> ensureCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      throw const CameraPermissionPermanentlyDeniedException();
    }
    if (!status.isGranted) {
      throw const CameraPermissionDeniedException();
    }
  }

  @override
  Future<CameraController> initFrontCamera() async {
    final List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } on CameraException {
      throw const CameraUnavailableException();
    }
    if (cameras.isEmpty) throw const CameraUnavailableException();

    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try {
      await controller.initialize();
    } on CameraException {
      throw const CameraUnavailableException();
    }
    return controller;
  }

  @override
  Future<FaceShot> captureAndAnalyze(CameraController controller) async {
    final XFile shot;
    try {
      shot = await controller.takePicture();
    } on CameraException {
      throw const CameraUnavailableException();
    }

    final faces = await _faceDetector.processImage(
      InputImage.fromFilePath(shot.path),
    );

    final bytes = await File(shot.path).readAsBytes();
    final (brightness, blurVariance) = _measureQuality(bytes);

    return FaceShot(
      imagePath: shot.path,
      metrics: FaceMetrics(
        faceCount: faces.length,
        brightness: brightness,
        blurVariance: blurVariance,
      ),
    );
  }

  /// Hitung rata-rata luma (brightness) dan variance Laplacian (ketajaman) dari
  /// JPEG hasil capture. Gambar dikecilkan ke lebar 320 px agar cepat & hemat.
  (double, double) _measureQuality(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const CameraUnavailableException();
    final small = img.copyResize(decoded, width: 320);
    final w = small.width;
    final h = small.height;

    // Pra-hitung luma tiap piksel; dipakai lagi untuk Laplacian.
    final gray = List<double>.filled(w * h, 0);
    var lumaSum = 0.0;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final px = small.getPixel(x, y);
        final luma = 0.299 * px.r + 0.587 * px.g + 0.114 * px.b;
        gray[y * w + x] = luma;
        lumaSum += luma;
      }
    }
    final brightness = lumaSum / (w * h);

    // Variance Laplacian (kernel 4-tetangga) = ukuran fokus. Hitung mean dan
    // mean-kuadrat dalam satu lintasan supaya tak perlu simpan semua nilai.
    var lapSum = 0.0;
    var lapSqSum = 0.0;
    var count = 0;
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final i = y * w + x;
        final lap =
            4 * gray[i] - gray[i - 1] - gray[i + 1] - gray[i - w] - gray[i + w];
        lapSum += lap;
        lapSqSum += lap * lap;
        count++;
      }
    }
    final lapMean = lapSum / count;
    final blurVariance = (lapSqSum / count) - (lapMean * lapMean);
    return (brightness, blurVariance);
  }
}

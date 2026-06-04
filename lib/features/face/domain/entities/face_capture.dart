// Part of: Face Detection - Domain

import 'package:equatable/equatable.dart';

/// Selfie yang sudah lolos verifikasi kualitas, siap diunggah ke Storage (Hari 7).
class FaceCapture extends Equatable {
  /// Path file JPEG hasil capture di penyimpanan sementara perangkat.
  final String imagePath;

  const FaceCapture(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

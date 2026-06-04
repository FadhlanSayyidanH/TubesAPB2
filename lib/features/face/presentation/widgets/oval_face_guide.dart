// Part of: Face Detection - Presentation

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Overlay panduan: meredupkan area di luar oval dan menggambar garis oval
/// (Safety Orange) sebagai tempat user menaruh wajahnya.
class OvalFaceGuide extends StatelessWidget {
  /// Warna garis oval — bisa diubah jadi hijau saat capture berhasil (Hari 7).
  final Color borderColor;

  const OvalFaceGuide({super.key, this.borderColor = AppColors.safetyOrange});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _OvalGuidePainter(borderColor)),
    );
  }
}

class _OvalGuidePainter extends CustomPainter {
  final Color borderColor;

  _OvalGuidePainter(this.borderColor);

  @override
  void paint(Canvas canvas, Size size) {
    // Oval diposisikan agak ke atas-tengah, proporsional terhadap layar.
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: size.width * 0.72,
      height: size.height * 0.5,
    );

    // Scrim gelap dengan "lubang" oval (even-odd) agar wajah tetap terang.
    final scrim = Path()
      ..addRect(Offset.zero & size)
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(scrim, Paint()..color = Colors.black.withValues(alpha: 0.55));

    canvas.drawOval(
      ovalRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = borderColor,
    );
  }

  @override
  bool shouldRepaint(covariant _OvalGuidePainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}

// Part of: Attendance - Presentation

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Menampilkan selfie absensi dari beragam sumber:
/// - data URI base64 (cara simpan sekarang — selfie ada di Firestore, CLAUDE.md §6),
/// - URL http (bila nanti pindah ke Firebase Storage),
/// - placeholder bila kosong / gagal dekode.
class SelfieImage extends StatelessWidget {
  final String selfieUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SelfieImage({
    super.key,
    required this.selfieUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (selfieUrl.isEmpty) return _placeholder();

    if (selfieUrl.startsWith('data:')) {
      try {
        final bytes = base64Decode(selfieUrl.split(',').last);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => _placeholder(),
        );
      } catch (_) {
        return _placeholder();
      }
    }

    return CachedNetworkImage(
      imageUrl: selfieUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => ColoredBox(
        color: AppColors.inputFill,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.inputFill,
      alignment: Alignment.center,
      child: Icon(Icons.person_outline, size: 56, color: AppColors.textHint),
    );
  }
}

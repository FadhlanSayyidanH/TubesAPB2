// Part of: Attendance - Presentation

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/attendance_entity.dart';

/// Badge berwarna untuk status absensi (hadir/telat/izin/alpha). Satu sumber
/// kebenaran warna+label, dipakai di dashboard, riwayat, dan dialog sukses.
class AttendanceStatusBadge extends StatelessWidget {
  final AttendanceStatus status;
  const AttendanceStatusBadge({super.key, required this.status});

  Color get _color => switch (status) {
    AttendanceStatus.hadir => AppColors.statusHadir,
    AttendanceStatus.telat => AppColors.statusTelat,
    AttendanceStatus.izin => AppColors.statusIzin,
    AttendanceStatus.alpha => AppColors.statusAlpha,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.caption.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

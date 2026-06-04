// Part of: Admin - Presentation

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/admin_stats.dart';

/// Kartu kondisi hari ini: cincin % kehadiran + empat tile hitungan
/// (sudah masuk / hadir / telat / belum absen).
class AdminTodayCard extends StatelessWidget {
  final AdminStats stats;
  const AdminTodayCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _Ring(percentage: stats.attendanceRate),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.adminTodayAttendanceTitle,
                          style: AppTextStyles.bodyBold),
                      const SizedBox(height: 4),
                      Text(
                        '${stats.clockedInToday} ${AppStrings.adminOfTotal.replaceFirst('%d', '${stats.totalEmployees}')}',
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Tile(
                    label: AppStrings.adminClockedIn,
                    value: stats.clockedInToday,
                    color: AppColors.statusIzin),
                _Tile(
                    label: AppStrings.adminOnTime,
                    value: stats.onTimeToday,
                    color: AppColors.statusHadir),
                _Tile(
                    label: AppStrings.adminLate,
                    value: stats.lateToday,
                    color: AppColors.statusTelat),
                _Tile(
                    label: AppStrings.adminAlpha,
                    value: stats.alphaToday,
                    color: AppColors.statusAlpha),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final int percentage;
  const _Ring({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final color = percentage >= 80
        ? AppColors.statusHadir
        : percentage >= 50
            ? AppColors.statusTelat
            : AppColors.statusAlpha;
    return SizedBox(
      height: 68,
      width: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 68,
            width: 68,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 6,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text('$percentage%',
              style: AppTextStyles.bodyBold.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _Tile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$value', style: AppTextStyles.title.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
                maxLines: 1),
          ],
        ),
      ),
    );
  }
}

// Part of: Attendance - Presentation

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/weekly_stats.dart';

/// Kartu rekap mingguan: cincin persentase kehadiran + empat tile hitungan
/// (hadir / telat / izin / alpha).
class WeeklyStatsCard extends StatelessWidget {
  final WeeklyStats stats;

  const WeeklyStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _PercentageRing(percentage: stats.attendancePercentage),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.weeklyAttendanceTitle,
                          style: AppTextStyles.bodyBold),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.presentOfWorkdays(
                            stats.present, stats.workdaysElapsed),
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
                _StatTile(
                    label: AppStrings.statusHadir,
                    value: stats.hadir,
                    color: AppColors.statusHadir),
                _StatTile(
                    label: AppStrings.statusTelat,
                    value: stats.telat,
                    color: AppColors.statusTelat),
                _StatTile(
                    label: AppStrings.statusIzin,
                    value: stats.izin,
                    color: AppColors.statusIzin),
                _StatTile(
                    label: AppStrings.statusAlpha,
                    value: stats.alpha,
                    color: AppColors.statusAlpha),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PercentageRing extends StatelessWidget {
  final int percentage;
  const _PercentageRing({required this.percentage});

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

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$value',
                style: AppTextStyles.title.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

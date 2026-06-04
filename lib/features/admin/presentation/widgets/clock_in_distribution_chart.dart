// Part of: Admin - Presentation

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Histogram jumlah absen masuk per jam (0–23) untuk melihat pola jam kedatangan
/// karyawan. [counts] panjang 24, index = jam.
class ClockInDistributionChart extends StatelessWidget {
  final List<int> counts;
  const ClockInDistributionChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final total = counts.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(AppStrings.adminClockInDistEmpty,
              style: AppTextStyles.caption, textAlign: TextAlign.center),
        ),
      );
    }

    final maxCount = counts.fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = (maxCount + 1).toDouble();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: AppTextStyles.caption,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                // Hanya tandai tiap 3 jam agar label tidak menumpuk.
                getTitlesWidget: (value, _) => _hourLabel(value.toInt()),
              ),
            ),
          ),
          barGroups: [
            for (var hour = 0; hour < counts.length; hour++)
              BarChartGroupData(
                x: hour,
                barRods: [
                  BarChartRodData(
                    toY: counts[hour].toDouble(),
                    color: AppColors.safetyOrange,
                    width: 6,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _hourLabel(int hour) {
    if (hour < 0 || hour > 23 || hour % 3 != 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(hour.toString().padLeft(2, '0'), style: AppTextStyles.caption),
    );
  }
}

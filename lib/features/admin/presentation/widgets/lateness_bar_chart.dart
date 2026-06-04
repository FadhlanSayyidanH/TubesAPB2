// Part of: Admin - Presentation

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_format_id.dart';
import '../../domain/entities/admin_stats.dart';

/// Batang jumlah keterlambatan (status telat) per hari (7 hari terakhir).
class LatenessBarChart extends StatelessWidget {
  final List<DailyAttendance> days;
  const LatenessBarChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final maxLate = days
        .map((d) => d.late)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = (maxLate + 1).toDouble();

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
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
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
                reservedSize: 28,
                getTitlesWidget: (value, _) => _dayLabel(value),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: days[i].late.toDouble(),
                    color: AppColors.statusTelat,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _dayLabel(double value) {
    final i = value.toInt();
    if (i < 0 || i >= days.length) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(hariSingkat(days[i].day), style: AppTextStyles.caption),
    );
  }
}

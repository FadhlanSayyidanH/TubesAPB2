// Part of: Admin - Presentation

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_format_id.dart';
import '../../domain/entities/admin_stats.dart';

/// Garis jumlah karyawan yang absen masuk per hari (7 hari terakhir).
class AttendanceLineChart extends StatelessWidget {
  final List<DailyAttendance> days;
  const AttendanceLineChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final maxPresent = days
        .map((d) => d.present)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = (maxPresent + 1).toDouble();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
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
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < days.length; i++)
                  FlSpot(i.toDouble(), days[i].present.toDouble()),
              ],
              isCurved: true,
              color: AppColors.safetyOrange,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.safetyOrange.withValues(alpha: 0.12),
              ),
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

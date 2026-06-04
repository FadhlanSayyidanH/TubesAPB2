// Part of: Attendance - Presentation

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';

/// Placeholder shimmer yang menyerupai bentuk WeeklyStatsCard saat data dimuat —
/// bukan spinner generik, agar transisi ke konten terasa mulus.
class WeeklyStatsShimmer extends StatelessWidget {
  const WeeklyStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: AppColors.divider,
          highlightColor: AppColors.inputFill,
          child: Column(
            children: [
              Row(
                children: [
                  _box(68, 68, shape: BoxShape.circle),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(140, 14),
                        const SizedBox(height: 8),
                        _box(100, 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(
                  4,
                  (_) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: _box(double.infinity, 56),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(double w, double h, {BoxShape shape = BoxShape.rectangle}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(8)
            : null,
      ),
    );
  }
}

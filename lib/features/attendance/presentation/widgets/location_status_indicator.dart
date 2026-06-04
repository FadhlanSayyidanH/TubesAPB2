// Part of: Attendance - Presentation

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/location_status.dart';

/// Banner status di atas peta: hijau "Dalam Area" / merah "Di Luar Area",
/// plus jarak ke kantor. Inti feedback validasi GPS untuk user.
class LocationStatusIndicator extends StatelessWidget {
  final LocationStatus location;
  final bool isRefreshing;

  const LocationStatusIndicator({
    super.key,
    required this.location,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    final inside = location.isWithinOfficeRadius;
    final color = inside ? AppColors.insideRadius : AppColors.outsideRadius;
    final label = inside ? AppStrings.insideRadius : AppStrings.outsideRadius;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodyBold.copyWith(color: color)),
                Text(
                  '${AppStrings.distanceToOffice}: ${location.readableDistance}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (isRefreshing)
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          else
            Icon(
              inside ? Icons.check_circle : Icons.error_outline,
              color: color,
            ),
        ],
      ),
    );
  }
}

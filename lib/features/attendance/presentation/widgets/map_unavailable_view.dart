// Part of: Attendance - Presentation

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/location_status.dart';
import '../../domain/entities/office_entity.dart';

/// Pengganti peta saat Google Maps belum aktif. Menampilkan ringkasan kantor
/// dan koordinat user agar layar tetap informatif, bukan kotak kosong.
class MapUnavailableView extends StatelessWidget {
  final OfficeEntity office;
  final LocationStatus? location;

  const MapUnavailableView({super.key, required this.office, this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.deepNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined,
              size: 56, color: AppColors.textOnDark.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'Peta dinonaktifkan sementara',
            style: AppTextStyles.bodyBold.copyWith(color: AppColors.textOnDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Validasi lokasi tetap berjalan dari GPS di bawah.',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textOnDark.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.business,
            label: office.name,
            value:
                '${office.latitude.toStringAsFixed(4)}, ${office.longitude.toStringAsFixed(4)}',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.adjust,
            label: AppStrings.mapRadiusLabel,
            value: '${office.radiusMeters} m',
          ),
          if (location != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.my_location,
              label: AppStrings.mapYourPosition,
              value:
                  '${location!.userLatitude.toStringAsFixed(4)}, ${location!.userLongitude.toStringAsFixed(4)}',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.safetyOrange),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textOnDark.withValues(alpha: 0.7))),
        ),
        Text(value,
            style: AppTextStyles.bodyBold.copyWith(color: AppColors.textOnDark)),
      ],
    );
  }
}

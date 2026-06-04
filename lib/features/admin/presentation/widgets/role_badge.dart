// Part of: Admin - Presentation

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Label peran user: Admin (oranye) atau Karyawan (navy).
class RoleBadge extends StatelessWidget {
  final UserRole role;
  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == UserRole.admin;
    final color = isAdmin ? AppColors.safetyOrange : AppColors.deepNavy;
    final label = isAdmin
        ? AppStrings.profileRoleAdmin
        : AppStrings.profileRoleEmployee;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

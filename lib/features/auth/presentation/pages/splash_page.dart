// Part of: Auth - Presentation

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Layar pembuka selagi AuthBloc mengecek sesi tersimpan. Navigasi keluar
/// ditangani redirect go_router begitu status auth diketahui.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                color: AppColors.safetyOrange,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 56,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: AppTextStyles.headline.copyWith(
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.appTagline,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textOnDark.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                valueColor: AlwaysStoppedAnimation(AppColors.safetyOrange),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.splashLoading,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textOnDark.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

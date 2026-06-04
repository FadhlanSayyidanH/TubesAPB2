// Part of: Core - Widgets

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../network/connectivity_cubit.dart';

/// Membungkus seluruh isi aplikasi dan menampilkan banner merah di bawah layar
/// saat perangkat kehilangan koneksi. Dipasang via `MaterialApp.router.builder`
/// agar muncul di atas semua halaman tanpa mengubah tiap Scaffold.
class OfflineBanner extends StatelessWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityCubit>().state;
    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          // Banner murni informatif — jangan menangkap sentuhan halaman.
          child: IgnorePointer(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              offset: isOnline ? const Offset(0, 1) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isOnline ? 0 : 1,
                child: const _OfflineBar(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineBar extends StatelessWidget {
  const _OfflineBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 18, color: AppColors.textOnDark),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  AppStrings.offlineBanner,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textOnDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

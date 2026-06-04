// Part of: Attendance - Presentation

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/attendance_entity.dart';
import '../bloc/clock_in_bloc.dart';
import '../widgets/attendance_status_badge.dart';
import '../widgets/clock_in_map.dart';
import '../widgets/location_status_indicator.dart';
import '../widgets/map_unavailable_view.dart';

class ClockInPage extends StatelessWidget {
  const ClockInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return BlocProvider(
      create: (_) => sl<ClockInBloc>()..add(ClockInStarted(authState.user)),
      child: const _ClockInView(),
    );
  }
}

class _ClockInView extends StatelessWidget {
  const _ClockInView();

  void _onAction(BuildContext context, ClockInState state) {
    switch (state.action) {
      case ClockInAction.clockedIn:
        // Notifikasi lokal konfirmasi absen masuk (di samping dialog sukses).
        final record = state.todayAttendance!;
        sl<LocalNotificationService>().showClockInSuccess(
          DateFormat('HH:mm').format(record.clockIn),
        );
        _showSuccessDialog(context, record);
      case ClockInAction.clockedOut:
        _showSuccessDialog(context, state.todayAttendance!);
      case ClockInAction.failed:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.message ?? AppStrings.errUnknown),
              backgroundColor: AppColors.error,
            ),
          );
      case ClockInAction.idle:
      case ClockInAction.submitting:
        break;
    }
  }

  void _showSuccessDialog(BuildContext context, AttendanceEntity record) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ClockSuccessDialog(
        record: record,
        onClose: () {
          Navigator.pop(dialogContext); // tutup dialog
          Navigator.of(context).maybePop(); // kembali ke dashboard
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.clockInTitle)),
      body: BlocConsumer<ClockInBloc, ClockInState>(
        listenWhen: (prev, curr) =>
            prev.action != curr.action && curr.action != ClockInAction.idle,
        listener: _onAction,
        builder: (context, state) {
          switch (state.status) {
            case ClockInStatus.initial:
            case ClockInStatus.loadingOffice:
              return _CenteredLoader(message: AppStrings.locating);
            case ClockInStatus.officeError:
              return _ErrorState(
                icon: Icons.location_off_outlined,
                message: state.message ?? AppStrings.errUnknown,
                actionLabel: AppStrings.tryAgain,
                onAction: () => context.read<ClockInBloc>().add(
                  ClockInStarted(state.user!),
                ),
              );
            case ClockInStatus.locationError:
              return _LocationErrorState(state: state);
            case ClockInStatus.locating:
            case ClockInStatus.ready:
              return _MapAndActions(state: state);
          }
        },
      ),
    );
  }
}

class _MapAndActions extends StatelessWidget {
  final ClockInState state;
  const _MapAndActions({required this.state});

  @override
  Widget build(BuildContext context) {
    final office = state.office!;
    final location = state.location;
    final timeFmt = DateFormat('HH:mm');

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              if (AppConfig.mapsEnabled)
                ClockInMap(office: office, location: location)
              else
                MapUnavailableView(office: office, location: location),
              if (location == null) const _MapOverlayLoader(),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (location != null)
                LocationStatusIndicator(
                  location: location,
                  isRefreshing: state.isRefreshing,
                ),
              const SizedBox(height: 16),
              if (state.alreadyClockedOut)
                _CompletedBanner(record: state.todayAttendance!)
              else
                _ActionButton(state: state, timeFmt: timeFmt),
              if (!state.alreadyClockedOut) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => context.read<ClockInBloc>().add(
                    const LocationRefreshRequested(isManual: true),
                  ),
                  icon: const Icon(Icons.my_location, size: 18),
                  label: Text(AppStrings.refreshLocation),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final ClockInState state;
  final DateFormat timeFmt;
  const _ActionButton({required this.state, required this.timeFmt});

  /// Clock-out langsung simpan. Clock-in: di luar radius diserahkan ke bloc agar
  /// memunculkan pesan jarak (tanpa membuang capture); di dalam radius wajib
  /// verifikasi wajah dulu, baru simpan dengan selfie-nya.
  Future<void> _onPressed(BuildContext context) async {
    final bloc = context.read<ClockInBloc>();
    if (state.alreadyClockedIn || !state.isWithinRadius) {
      bloc.add(const AttendanceSubmitted());
      return;
    }
    final selfiePath = await context.push<String>('/face-capture');
    if (selfiePath != null) {
      bloc.add(AttendanceSubmitted(selfiePath: selfiePath));
    }
  }

  @override
  Widget build(BuildContext context) {
    final clockingOut = state.alreadyClockedIn;
    final submitting = state.action == ClockInAction.submitting;
    return Column(
      children: [
        if (clockingOut)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              AppStrings.alreadyClockedInAt(
                timeFmt.format(state.todayAttendance!.clockIn),
              ),
              style: AppTextStyles.subtitle,
            ),
          ),
        PrimaryButton(
          label: clockingOut
              ? AppStrings.clockOutButton
              : AppStrings.clockInTitle,
          icon: clockingOut ? Icons.logout : Icons.face_retouching_natural,
          isLoading: submitting,
          onPressed: state.canSubmit ? () => _onPressed(context) : null,
        ),
      ],
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final AttendanceEntity record;
  const _CompletedBanner({required this.record});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.task_alt, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.attendanceCompleteTitle,
                  style: AppTextStyles.bodyBold,
                ),
                Text(
                  AppStrings.historyTileTimes(
                    timeFmt.format(record.clockIn),
                    timeFmt.format(record.clockOut!),
                  ),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog sukses absen: animasi Lottie checkmark + ringkasan, lalu menutup
/// sendiri dan kembali ke dashboard setelah 2 detik (auto-redirect).
class _ClockSuccessDialog extends StatefulWidget {
  final AttendanceEntity record;
  final VoidCallback onClose;
  const _ClockSuccessDialog({required this.record, required this.onClose});

  @override
  State<_ClockSuccessDialog> createState() => _ClockSuccessDialogState();
}

class _ClockSuccessDialogState extends State<_ClockSuccessDialog> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(seconds: 2), widget.onClose);
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final isClockOut = record.hasClockedOut;
    final timeFmt = DateFormat('HH:mm');
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Lottie.asset(
              'assets/lottie/success_check.json',
              repeat: false,
              // Fallback bila aset Lottie belum/ tidak valid: ikon statis.
              errorBuilder: (_, _, _) => const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 96,
              ),
            ),
          ),
          Text(
            isClockOut
                ? AppStrings.clockOutSuccessTitle
                : AppStrings.clockInSuccessTitle,
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(record.userName, style: AppTextStyles.bodyBold),
          const SizedBox(height: 4),
          if (isClockOut) ...[
            Text(
              AppStrings.clockOutAtLabel(timeFmt.format(record.clockOut!)),
              style: AppTextStyles.body,
            ),
            Text(
              AppStrings.workDurationValue(
                _durationText(record.workDurationMinutes),
              ),
              style: AppTextStyles.subtitle,
            ),
          ] else ...[
            Text(
              AppStrings.clockInAtLabel(timeFmt.format(record.clockIn)),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 8),
            AttendanceStatusBadge(status: record.status),
          ],
        ],
      ),
    );
  }
}

String _durationText(int? minutes) {
  if (minutes == null) return '-';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return AppStrings.durationMinutes(m);
  return AppStrings.durationHourMinute(h, m);
}

class _LocationErrorState extends StatelessWidget {
  final ClockInState state;
  const _LocationErrorState({required this.state});

  @override
  Widget build(BuildContext context) {
    final showOpenSettings = state.canOpenSettings;
    return _ErrorState(
      icon: Icons.gps_off,
      message: state.message ?? AppStrings.errUnknown,
      actionLabel: showOpenSettings
          ? AppStrings.openSettings
          : AppStrings.enableGps,
      onAction: () async {
        if (showOpenSettings) {
          await Geolocator.openAppSettings();
        } else {
          await Geolocator.openLocationSettings();
        }
      },
      secondaryLabel: AppStrings.tryAgain,
      onSecondary: () => context.read<ClockInBloc>().add(
        const LocationRefreshRequested(isManual: true),
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  final String message;
  const _CenteredLoader({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}

class _MapOverlayLoader extends StatelessWidget {
  const _MapOverlayLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.7),
      child: _CenteredLoader(message: AppStrings.locating),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _ErrorState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.outsideRadius),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(label: actionLabel, onPressed: onAction),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

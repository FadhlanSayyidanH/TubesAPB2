// Part of: Attendance - Presentation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../../domain/entities/attendance_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/attendance_status_badge.dart';
import '../widgets/selfie_image.dart';
import '../widgets/weekly_stats_card.dart';
import '../widgets/weekly_stats_shimmer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return BlocProvider(
      create: (_) =>
          sl<DashboardBloc>()..add(DashboardLoadRequested(authState.user.uid)),
      child: _DashboardView(user: authState.user),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final UserEntity user;
  const _DashboardView({required this.user});

  Future<void> _openClockIn(BuildContext context) async {
    await context.push('/clock-in');
    // Muat ulang status & statistik setelah kembali dari halaman absen.
    if (context.mounted) {
      context.read<DashboardBloc>().add(DashboardLoadRequested(user.uid));
    }
  }

  Future<void> _openLeave(BuildContext context) async {
    await context.push('/leave');
    // Izin yang baru diajukan bisa mengubah status hari ini & rekap minggu ini.
    if (context.mounted) {
      context.read<DashboardBloc>().add(DashboardLoadRequested(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dashboard berada di back-stack saat toggle tema/bahasa dibuka di Profil;
    // tanpa ini teks (AppStrings) & warna (AppColors) statis tetap basi sampai
    // halaman dibuka ulang. BlocBuilder SettingsCubit memaksa rebuild penuh.
    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, _) => Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => context
              .read<DashboardBloc>()
              .add(DashboardLoadRequested(user.uid)),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              _GreetingHeader(fallbackUser: user),
              const SizedBox(height: 24),
              _TodayCard(onTapAbsen: () => _openClockIn(context)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openLeave(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                  ),
                  icon: const Icon(Icons.event_busy_outlined),
                  label: Text(AppStrings.leaveButton),
                ),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.weeklySummaryTitle, style: AppTextStyles.title),
              const SizedBox(height: 12),
              const _WeeklySection(),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final UserEntity fallbackUser;
  const _GreetingHeader({required this.fallbackUser});

  @override
  Widget build(BuildContext context) {
    // Pantau AuthBloc agar nama & foto ikut segar setelah profil diubah
    // (AuthProfileUpdated). Pakai fallbackUser bila state belum Authenticated.
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => curr is Authenticated,
      builder: (context, authState) {
        final user =
            authState is Authenticated ? authState.user : fallbackUser;
        return Row(
          children: [
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: _Avatar(user: user),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.greeting, style: AppTextStyles.subtitle),
                  Text(user.name,
                      style: AppTextStyles.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(AppStrings.departmentNik(user.department, user.nik),
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            IconButton(
              tooltip: AppStrings.historyTitle,
              icon: Icon(Icons.history, color: AppColors.textPrimary),
              onPressed: () => context.push('/history'),
            ),
            const LogoutButton(),
          ],
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final UserEntity user;
  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.photoUrl.isEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.deepNavy,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: AppTextStyles.title.copyWith(color: AppColors.textOnDark),
        ),
      );
    }
    return ClipOval(
      child: SizedBox(
        width: 52,
        height: 52,
        child: SelfieImage(selfieUrl: user.photoUrl, fit: BoxFit.cover),
      ),
    );
  }
}

/// Kartu absen hari ini — tampilannya menyesuaikan: belum absen / sudah masuk /
/// sudah selesai, lengkap dengan tombol aksi yang relevan.
class _TodayCard extends StatelessWidget {
  final VoidCallback onTapAbsen;
  const _TodayCard({required this.onTapAbsen});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final record = state.todayAttendance;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: switch ((state.hasClockedIn, state.hasClockedOut)) {
              (false, _) => _notClockedIn(),
              (true, false) => _clockedIn(record!),
              (true, true) => _completed(record!),
            },
          ),
        );
      },
    );
  }

  Widget _notClockedIn() {
    return Column(
      children: [
        Icon(Icons.location_on_outlined, size: 40, color: AppColors.safetyOrange),
        const SizedBox(height: 12),
        Text(AppStrings.notClockedInTitle, style: AppTextStyles.title),
        const SizedBox(height: 4),
        Text(AppStrings.clockInRadiusHint,
            style: AppTextStyles.subtitle, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onTapAbsen,
            icon: const Icon(Icons.fingerprint),
            label: Text(AppStrings.clockInButton),
          ),
        ),
      ],
    );
  }

  Widget _clockedIn(AttendanceEntity record) {
    final timeFmt = DateFormat('HH:mm');
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppStrings.clockedInAt(timeFmt.format(record.clockIn)),
                style: AppTextStyles.title),
            const SizedBox(width: 8),
            AttendanceStatusBadge(status: record.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(AppStrings.clockOutHint,
            style: AppTextStyles.subtitle, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onTapAbsen,
            icon: const Icon(Icons.logout),
            label: Text(AppStrings.clockOutButton),
          ),
        ),
      ],
    );
  }

  Widget _completed(AttendanceEntity record) {
    final timeFmt = DateFormat('HH:mm');
    return Column(
      children: [
        const Icon(Icons.task_alt, size: 40, color: AppColors.success),
        const SizedBox(height: 12),
        Text(AppStrings.attendanceCompleteTitle, style: AppTextStyles.title),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _timeChip(AppStrings.clockInShort, timeFmt.format(record.clockIn)),
            const SizedBox(width: 12),
            _timeChip(AppStrings.clockOutShort, timeFmt.format(record.clockOut!)),
          ],
        ),
      ],
    );
  }

  Widget _timeChip(String label, String time) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(time, style: AppTextStyles.bodyBold),
      ],
    );
  }
}

class _WeeklySection extends StatelessWidget {
  const _WeeklySection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        switch (state.status) {
          case DashboardStatus.loading:
            return const WeeklyStatsShimmer();
          case DashboardStatus.error:
            return _StatsError(message: state.message ?? AppStrings.errUnknown);
          case DashboardStatus.loaded:
            final stats = state.weeklyStats;
            if (stats == null || stats.workdaysElapsed == 0) {
              return const _StatsEmpty();
            }
            return WeeklyStatsCard(stats: stats);
        }
      },
    );
  }
}

class _StatsEmpty extends StatelessWidget {
  const _StatsEmpty();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.insights_outlined, size: 48, color: AppColors.divider),
            const SizedBox(height: 12),
            Text(AppStrings.weeklyEmptyTitle,
                style: AppTextStyles.bodyBold, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(AppStrings.weeklyEmptyHint,
                style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _StatsError extends StatelessWidget {
  final String message;
  const _StatsError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 40, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message,
                style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

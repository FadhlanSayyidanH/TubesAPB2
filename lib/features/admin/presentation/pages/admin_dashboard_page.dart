// Part of: Admin - Presentation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_format_id.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../../domain/entities/admin_stats.dart';
import '../bloc/admin_stats_bloc.dart';
import '../bloc/export_bloc.dart';
import '../widgets/admin_today_card.dart';
import '../widgets/attendance_line_chart.dart';
import '../widgets/clock_in_distribution_chart.dart';
import '../widgets/lateness_bar_chart.dart';

/// Dashboard admin: monitoring kehadiran real-time (stream Firestore) + KPI 7 hari.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<AdminStatsBloc>()..add(const AdminDashboardStarted()),
        ),
        BlocProvider(create: (_) => sl<ExportBloc>()),
      ],
      child: const _AdminView(),
    );
  }
}

class _AdminView extends StatelessWidget {
  const _AdminView();

  /// Pilih rentang tanggal lalu minta ExportBloc membangun CSV-nya.
  Future<void> _onExport(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 6)),
        end: now,
      ),
      helpText: AppStrings.exportTitle,
    );
    if (range != null && context.mounted) {
      context
          .read<ExportBloc>()
          .add(ExportRequested(from: range.start, to: range.end));
    }
  }

  Future<void> _onExportState(BuildContext context, ExportState state) async {
    final messenger = ScaffoldMessenger.of(context);
    switch (state.status) {
      case ExportStatus.loading:
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text(AppStrings.exportPreparing)));
      case ExportStatus.success:
        messenger.hideCurrentSnackBar();
        // Buka share sheet sistem dengan file CSV-nya.
        await SharePlus.instance.share(ShareParams(
          files: [XFile(state.filePath!)],
          text: AppStrings.exportShareText,
        ));
      case ExportStatus.failure:
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(state.message ?? AppStrings.errUnknown),
            backgroundColor: AppColors.error,
          ));
      case ExportStatus.idle:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final name = authState is Authenticated ? authState.user.name : 'Admin';

    return BlocListener<ExportBloc, ExportState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: _onExportState,
      child: Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.adminTitle),
        actions: [
          IconButton(
            tooltip: AppStrings.exportTitle,
            icon:
                const Icon(Icons.file_download_outlined, color: AppColors.textOnDark),
            onPressed: () => _onExport(context),
          ),
          IconButton(
            tooltip: AppStrings.employeesTitle,
            icon: const Icon(Icons.group_outlined, color: AppColors.textOnDark),
            onPressed: () => context.push('/admin/employees'),
          ),
          const _LiveBadge(),
          const SizedBox(width: 8),
          const LogoutButton(),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => context
              .read<AdminStatsBloc>()
              .add(const AdminCountRefreshRequested()),
          child: BlocBuilder<AdminStatsBloc, AdminStatsState>(
            builder: (context, state) {
              switch (state.status) {
                case AdminStatus.initial:
                case AdminStatus.loading:
                  return const _CenteredLoader();
                case AdminStatus.error:
                  return _ErrorView(message: state.message ?? AppStrings.errUnknown);
                case AdminStatus.loaded:
                  return _LoadedView(name: name, stats: state.stats!);
              }
            },
          ),
        ),
      ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final String name;
  final AdminStats stats;
  const _LoadedView({required this.name, required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Text(AppStrings.greetingNamed(name), style: AppTextStyles.headline),
        Text(formatTanggalLengkap(DateTime.now()),
            style: AppTextStyles.subtitle),
        const SizedBox(height: 20),
        Text(AppStrings.adminTodaySection, style: AppTextStyles.title),
        const SizedBox(height: 12),
        AdminTodayCard(stats: stats),
        const SizedBox(height: 24),
        Text(AppStrings.adminTrendSection, style: AppTextStyles.title),
        const SizedBox(height: 12),
        _ChartCard(child: AttendanceLineChart(days: stats.last7Days)),
        const SizedBox(height: 24),
        Text(AppStrings.adminLatenessSection, style: AppTextStyles.title),
        const SizedBox(height: 12),
        _ChartCard(child: LatenessBarChart(days: stats.last7Days)),
        const SizedBox(height: 24),
        Text(AppStrings.adminClockInDistSection, style: AppTextStyles.title),
        const SizedBox(height: 12),
        _ChartCard(
            child: ClockInDistributionChart(counts: stats.clockInHourCounts)),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
        child: child,
      ),
    );
  }
}

/// Badge "LANGSUNG" — penanda bahwa angka diperbarui real-time dari stream.
class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusHadir.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.statusHadir,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(AppStrings.adminLiveBadge,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.statusHadir, fontSize: 10)),
        ],
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    // ListView agar RefreshIndicator tetap bisa ditarik saat loading.
    return ListView(
      children: const [
        SizedBox(height: 200),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      children: [
        const Icon(Icons.cloud_off, size: 56, color: AppColors.error),
        const SizedBox(height: 16),
        Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => context
                .read<AdminStatsBloc>()
                .add(const AdminDashboardStarted()),
            child: Text(AppStrings.tryAgain),
          ),
        ),
      ],
    );
  }
}

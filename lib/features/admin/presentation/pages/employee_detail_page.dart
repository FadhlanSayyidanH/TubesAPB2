// Part of: Admin - Presentation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../../../attendance/presentation/bloc/history_bloc.dart';
import '../../../attendance/presentation/widgets/attendance_history_tile.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/employee_detail_bloc.dart';
import '../widgets/role_badge.dart';
import 'employee_list_page.dart';

/// Detail satu karyawan: info, tombol ubah peran, dan riwayat absensinya.
class EmployeeDetailPage extends StatelessWidget {
  final UserEntity user;
  const EmployeeDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => EmployeeDetailBloc(updateRole: sl(), user: user),
        ),
        BlocProvider(
          create: (_) => sl<HistoryBloc>()..add(HistoryLoadRequested(user.uid)),
        ),
      ],
      child: const _EmployeeDetailView(),
    );
  }
}

class _EmployeeDetailView extends StatelessWidget {
  const _EmployeeDetailView();

  Future<void> _confirmRoleChange(BuildContext context, UserEntity user) async {
    final targetRole = user.isAdmin
        ? AppStrings.profileRoleEmployee
        : AppStrings.profileRoleAdmin;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.changeRole, style: AppTextStyles.title),
        content: Text(
          AppStrings.confirmRoleChange(user.name, targetRole),
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppStrings.ok),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<EmployeeDetailBloc>().add(
        const EmployeeRoleToggleRequested(),
      );
    }
  }

  void _onRoleChanged(BuildContext context, EmployeeDetailState state) {
    if (state.status == RoleChangeStatus.success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              state.user.isAdmin
                  ? AppStrings.roleChangedToAdmin
                  : AppStrings.roleChangedToEmployee,
            ),
            backgroundColor: AppColors.success,
          ),
        );
    } else if (state.status == RoleChangeStatus.error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.message ?? AppStrings.errUnknown),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUid = authState is Authenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.employeeDetailTitle)),
      body: BlocConsumer<EmployeeDetailBloc, EmployeeDetailState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: _onRoleChanged,
        builder: (context, state) {
          final user = state.user;
          final isSelf = user.uid == currentUid;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(child: UserAvatar(user: user, radius: 44)),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  user.name,
                  style: AppTextStyles.headline,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 6),
              Center(child: RoleBadge(role: user.role)),
              const SizedBox(height: 20),
              _InfoCard(user: user),
              const SizedBox(height: 16),
              _RoleAction(
                user: user,
                isSelf: isSelf,
                isSaving: state.status == RoleChangeStatus.saving,
                onPressed: () => _confirmRoleChange(context, user),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.employeeHistorySection,
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 8),
              const _HistoryDateFilter(),
              const SizedBox(height: 4),
              const _EmployeeHistory(),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final UserEntity user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(AppStrings.labelEmail, user.email),
            _row(AppStrings.labelNik, user.nik),
            _row(AppStrings.labelDepartment, user.department),
            _row(
              AppStrings.labelRole,
              user.isAdmin
                  ? AppStrings.profileRoleAdmin
                  : AppStrings.profileRoleEmployee,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: AppTextStyles.bodyBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleAction extends StatelessWidget {
  final UserEntity user;
  final bool isSelf;
  final bool isSaving;
  final VoidCallback onPressed;

  const _RoleAction({
    required this.user,
    required this.isSelf,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelf) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: AppColors.textHint),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.roleChangeSelfBlocked,
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      );
    }
    return PrimaryButton(
      label: user.isAdmin
          ? AppStrings.demoteToEmployee
          : AppStrings.promoteToAdmin,
      icon: user.isAdmin ? Icons.person_outline : Icons.shield_outlined,
      isLoading: isSaving,
      onPressed: onPressed,
    );
  }
}

/// Baris filter rentang tanggal untuk riwayat absensi karyawan (riwayat admin).
class _HistoryDateFilter extends StatelessWidget {
  const _HistoryDateFilter();

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final state = context.read<HistoryBloc>().state;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: state.fromDate != null && state.toDate != null
          ? DateTimeRange(start: state.fromDate!, end: state.toDate!)
          : null,
      helpText: AppStrings.historyDateFilterButton,
    );
    if (picked != null && context.mounted) {
      context.read<HistoryBloc>().add(
        HistoryDateRangeChanged(picked.start, picked.end),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return BlocBuilder<HistoryBloc, HistoryState>(
      buildWhen: (p, c) => p.fromDate != c.fromDate || p.toDate != c.toDate,
      builder: (context, state) {
        final hasRange = state.fromDate != null && state.toDate != null;
        final label = hasRange
            ? '${fmt.format(state.fromDate!)} – ${fmt.format(state.toDate!)}'
            : AppStrings.historyDateFilterAll;
        return Row(
          children: [
            Icon(Icons.date_range, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: AppTextStyles.caption)),
            if (hasRange)
              IconButton(
                tooltip: AppStrings.cancel,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => context.read<HistoryBloc>().add(
                  const HistoryDateRangeChanged(null, null),
                ),
              ),
            TextButton.icon(
              onPressed: () => _pick(context),
              icon: const Icon(Icons.tune, size: 16),
              label: Text(AppStrings.historyDateFilterButton),
            ),
          ],
        );
      },
    );
  }
}

class _EmployeeHistory extends StatelessWidget {
  const _EmployeeHistory();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        switch (state.status) {
          case HistoryStatus.loading:
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            );
          case HistoryStatus.error:
            return _historyMessage(
              Icons.cloud_off,
              state.message ?? AppStrings.errUnknown,
            );
          case HistoryStatus.loaded:
            final items = state.filtered;
            if (items.isEmpty) {
              return _historyMessage(
                Icons.event_busy_outlined,
                state.hasDateFilter
                    ? AppStrings.historyDateFilterEmpty
                    : AppStrings.employeeHistoryEmpty,
              );
            }
            return Column(
              children: [
                for (final record in items)
                  AttendanceHistoryTile(record: record),
              ],
            );
        }
      },
    );
  }

  Widget _historyMessage(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.divider),
          const SizedBox(height: 12),
          Text(text, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

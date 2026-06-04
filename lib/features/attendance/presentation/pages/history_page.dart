// Part of: Attendance - Presentation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/attendance_entity.dart';
import '../bloc/history_bloc.dart';
import '../widgets/attendance_history_tile.dart';
import '../widgets/history_shimmer.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return BlocProvider(
      create: (_) =>
          sl<HistoryBloc>()..add(HistoryLoadRequested(authState.user.uid)),
      child: _HistoryView(userId: authState.user.uid),
    );
  }
}

class _HistoryView extends StatelessWidget {
  final String userId;
  const _HistoryView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.historyTitle)),
      body: Column(
        children: [
          const _FilterChips(),
          Expanded(
            child: BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                switch (state.status) {
                  case HistoryStatus.loading:
                    return const HistoryShimmer();
                  case HistoryStatus.error:
                    return _ErrorState(
                      message: state.message ?? AppStrings.errUnknown,
                      onRetry: () => context.read<HistoryBloc>().add(
                        HistoryLoadRequested(userId),
                      ),
                    );
                  case HistoryStatus.loaded:
                    if (state.filtered.isEmpty) {
                      return _EmptyState(isFiltered: state.filter != null);
                    }
                    return _HistoryList(userId: userId);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Daftar kartu riwayat dengan lazy render: hanya [HistoryState.visible] yang
/// dibangun, lalu bertambah satu halaman saat gulir mendekati bawah.
class _HistoryList extends StatefulWidget {
  final String userId;
  const _HistoryList({required this.userId});

  @override
  State<_HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<_HistoryList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeLoadMore);
    _controller.dispose();
    super.dispose();
  }

  // Bloc mengabaikan permintaan saat data sudah habis, jadi aman dipanggil
  // berkali-kali selama menggulir.
  void _maybeLoadMore() {
    if (!_controller.hasClients) return;
    if (_controller.position.extentAfter < 320) {
      context.read<HistoryBloc>().add(const HistoryLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<HistoryBloc>().add(HistoryLoadRequested(widget.userId)),
      child: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          final items = state.visible;
          return ListView.builder(
            controller: _controller,
            padding: const EdgeInsets.all(16),
            itemCount: items.length + (state.hasMore ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return AttendanceHistoryTile(record: items[i]);
            },
          );
        },
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  // null = Semua, lalu tiap status.
  static const List<AttendanceStatus?> _filters = [
    null,
    AttendanceStatus.hadir,
    AttendanceStatus.telat,
    AttendanceStatus.izin,
    AttendanceStatus.alpha,
  ];

  @override
  Widget build(BuildContext context) {
    final active = context.select((HistoryBloc b) => b.state.filter);
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = _filters[i];
          final label = filter?.label ?? AppStrings.historyFilterAll;
          return ChoiceChip(
            label: Text(label),
            selected: active == filter,
            onSelected: (_) =>
                context.read<HistoryBloc>().add(HistoryFilterChanged(filter)),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  const _EmptyState({required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined, size: 64, color: AppColors.divider),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? AppStrings.historyEmptyFiltered
                  : AppStrings.historyEmpty,
              style: AppTextStyles.bodyBold,
              textAlign: TextAlign.center,
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 4),
              Text(
                AppStrings.historyEmptyHint,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: AppStrings.tryAgain,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

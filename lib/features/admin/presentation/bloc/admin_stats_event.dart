// Part of: Admin - Presentation

part of 'admin_stats_bloc.dart';

sealed class AdminStatsEvent extends Equatable {
  const AdminStatsEvent();

  @override
  List<Object?> get props => [];
}

/// Mulai memantau: ambil jumlah karyawan lalu subscribe stream absensi.
class AdminDashboardStarted extends AdminStatsEvent {
  const AdminDashboardStarted();
}

/// Segarkan jumlah karyawan (stream absensi sudah real-time).
class AdminCountRefreshRequested extends AdminStatsEvent {
  const AdminCountRefreshRequested();
}

// Part of: Attendance - Presentation

part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Muat (atau muat ulang) status hari ini + statistik mingguan untuk [userId].
/// Dipanggil saat dashboard dibuka dan setiap kembali dari halaman clock-in.
class DashboardLoadRequested extends DashboardEvent {
  final String userId;
  const DashboardLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

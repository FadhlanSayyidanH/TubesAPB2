// Part of: Admin - Presentation

part of 'admin_stats_bloc.dart';

enum AdminStatus { initial, loading, loaded, error }

class AdminStatsState extends Equatable {
  final AdminStatus status;
  final AdminStats? stats;
  final String? message;

  const AdminStatsState({
    this.status = AdminStatus.initial,
    this.stats,
    this.message,
  });

  AdminStatsState copyWith({
    AdminStatus? status,
    AdminStats? stats,
    String? message,
  }) {
    return AdminStatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, stats, message];
}

// Part of: Attendance - Presentation

part of 'dashboard_bloc.dart';

enum DashboardStatus { loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final AttendanceEntity? todayAttendance;
  final WeeklyStats? weeklyStats;
  final String? message;

  const DashboardState({
    this.status = DashboardStatus.loading,
    this.todayAttendance,
    this.weeklyStats,
    this.message,
  });

  bool get hasClockedIn => todayAttendance != null;
  bool get hasClockedOut => todayAttendance?.hasClockedOut ?? false;

  DashboardState copyWith({
    DashboardStatus? status,
    AttendanceEntity? todayAttendance,
    WeeklyStats? weeklyStats,
    String? message,
  }) {
    return DashboardState(
      status: status ?? this.status,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, todayAttendance, weeklyStats, message];
}

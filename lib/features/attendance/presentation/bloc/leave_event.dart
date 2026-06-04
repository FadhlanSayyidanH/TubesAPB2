// Part of: Attendance - Presentation

part of 'leave_bloc.dart';

sealed class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

/// Kirim pengajuan izin untuk [date] dengan [reason].
class LeaveSubmitted extends LeaveEvent {
  final UserEntity user;
  final DateTime date;
  final String reason;
  const LeaveSubmitted({
    required this.user,
    required this.date,
    required this.reason,
  });

  @override
  List<Object?> get props => [user, date, reason];
}

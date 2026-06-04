// Part of: Attendance - Presentation

part of 'leave_bloc.dart';

enum LeaveStatus { idle, submitting, success, error }

class LeaveState extends Equatable {
  final LeaveStatus status;
  final String? message;

  const LeaveState({this.status = LeaveStatus.idle, this.message});

  LeaveState copyWith({LeaveStatus? status, String? message}) {
    return LeaveState(
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

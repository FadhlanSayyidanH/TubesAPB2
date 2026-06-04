// Part of: Admin - Presentation

part of 'export_bloc.dart';

sealed class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

/// Minta laporan CSV untuk rentang [from]–[to] (inklusif).
class ExportRequested extends ExportEvent {
  final DateTime from;
  final DateTime to;

  const ExportRequested({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}

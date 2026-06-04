// Part of: Admin - Presentation

part of 'export_bloc.dart';

enum ExportStatus { idle, loading, success, failure }

class ExportState extends Equatable {
  final ExportStatus status;
  final String? filePath;
  final int recordCount;
  final String? message;

  const ExportState({
    this.status = ExportStatus.idle,
    this.filePath,
    this.recordCount = 0,
    this.message,
  });

  ExportState copyWith({
    ExportStatus? status,
    String? filePath,
    int? recordCount,
    String? message,
    bool clearFilePath = false,
  }) {
    return ExportState(
      status: status ?? this.status,
      filePath: clearFilePath ? null : (filePath ?? this.filePath),
      recordCount: recordCount ?? this.recordCount,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, filePath, recordCount, message];
}

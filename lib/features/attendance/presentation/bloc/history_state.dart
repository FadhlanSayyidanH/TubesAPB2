// Part of: Attendance - Presentation

part of 'history_bloc.dart';

enum HistoryStatus { loading, loaded, error }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<AttendanceEntity> records; // semua catatan, urut terbaru
  final AttendanceStatus? filter; // null = semua
  final String? message;

  /// Berapa kartu (dari [filtered]) yang sedang dirender. Bertambah per
  /// [AppConfig.historyPageSize] saat user menggulir ke bawah (lazy render).
  final int visibleCount;

  /// Filter rentang tanggal (opsional, inklusif) — dipakai riwayat admin.
  /// Riwayat karyawan sendiri tidak memakainya (tetap null).
  final DateTime? fromDate;
  final DateTime? toDate;

  const HistoryState({
    this.status = HistoryStatus.loading,
    this.records = const [],
    this.filter,
    this.message,
    this.visibleCount = AppConfig.historyPageSize,
    this.fromDate,
    this.toDate,
  });

  /// Catatan yang cocok dengan filter status + rentang tanggal aktif
  /// (seluruhnya — dipakai detail admin & jadi basis [visible]).
  List<AttendanceEntity> get filtered => records.where((r) {
    if (filter != null && r.status != filter) return false;
    if (fromDate != null &&
        r.clockIn.isBefore(
          DateTime(fromDate!.year, fromDate!.month, fromDate!.day),
        )) {
      return false;
    }
    if (toDate != null &&
        r.clockIn.isAfter(
          DateTime(toDate!.year, toDate!.month, toDate!.day, 23, 59, 59),
        )) {
      return false;
    }
    return true;
  }).toList();

  /// Sedang ada filter rentang tanggal aktif.
  bool get hasDateFilter => fromDate != null || toDate != null;

  /// Potongan [filtered] yang benar-benar dirender saat ini (lazy pagination).
  List<AttendanceEntity> get visible => filtered.take(visibleCount).toList();

  /// Masih ada catatan tersembunyi yang bisa dimunculkan dengan menggulir.
  bool get hasMore => filtered.length > visibleCount;

  HistoryState copyWith({
    HistoryStatus? status,
    List<AttendanceEntity>? records,
    AttendanceStatus? filter,
    bool clearFilter = false,
    String? message,
    int? visibleCount,
    DateTime? fromDate,
    DateTime? toDate,
    bool clearDateRange = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      records: records ?? this.records,
      filter: clearFilter ? null : (filter ?? this.filter),
      message: message,
      visibleCount: visibleCount ?? this.visibleCount,
      fromDate: clearDateRange ? null : (fromDate ?? this.fromDate),
      toDate: clearDateRange ? null : (toDate ?? this.toDate),
    );
  }

  @override
  List<Object?> get props => [
    status,
    records,
    filter,
    message,
    visibleCount,
    fromDate,
    toDate,
  ];
}

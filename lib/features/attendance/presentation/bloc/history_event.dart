// Part of: Attendance - Presentation

part of 'history_bloc.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Muat seluruh riwayat absensi user (dipanggil saat halaman dibuka & refresh).
class HistoryLoadRequested extends HistoryEvent {
  final String userId;
  const HistoryLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Ganti filter status. [filter] null = tampilkan semua.
class HistoryFilterChanged extends HistoryEvent {
  final AttendanceStatus? filter;
  const HistoryFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Render satu "halaman" kartu berikutnya dari data yang sudah ter-load
/// (dipicu saat gulir mendekati bawah daftar). Tidak menyentuh jaringan.
class HistoryLoadMoreRequested extends HistoryEvent {
  const HistoryLoadMoreRequested();
}

/// Ubah filter rentang tanggal (riwayat admin). [from]/[to] null = hapus filter.
class HistoryDateRangeChanged extends HistoryEvent {
  final DateTime? from;
  final DateTime? to;
  const HistoryDateRangeChanged(this.from, this.to);

  @override
  List<Object?> get props => [from, to];
}

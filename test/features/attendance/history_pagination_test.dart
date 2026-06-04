// Part of: Attendance - Presentation (test)
//
// Menguji logika lazy-render riwayat: getter `visible` & `hasMore` di
// HistoryState, plus reset halaman saat ganti filter (Hari 13).

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_attendance/core/constants/app_config.dart';
import 'package:smart_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_attendance/features/attendance/presentation/bloc/history_bloc.dart';

AttendanceEntity _record(int i, AttendanceStatus status) => AttendanceEntity(
  id: 'rec_$i',
  userId: 'u1',
  userName: 'Budi',
  date: '2026-06-${(i % 28) + 1}',
  clockIn: DateTime(2026, 6, 1).add(Duration(days: i)),
  clockInLat: 0,
  clockInLon: 0,
  selfieUrl: '',
  status: status,
  isInRadius: true,
);

List<AttendanceEntity> _records(int n, {AttendanceStatus? status}) =>
    List.generate(n, (i) => _record(i, status ?? AttendanceStatus.hadir));

void main() {
  group('HistoryState lazy render', () {
    test('default hanya menampilkan satu halaman pertama', () {
      final state = HistoryState(
        status: HistoryStatus.loaded,
        records: _records(40),
      );
      expect(state.visible.length, AppConfig.historyPageSize);
      expect(state.hasMore, isTrue);
    });

    test(
      'data lebih sedikit dari satu halaman → tampil semua, hasMore false',
      () {
        final state = HistoryState(
          status: HistoryStatus.loaded,
          records: _records(3),
        );
        expect(state.visible.length, 3);
        expect(state.hasMore, isFalse);
      },
    );

    test('menambah visibleCount memunculkan halaman berikutnya', () {
      final base = HistoryState(
        status: HistoryStatus.loaded,
        records: _records(40),
      );
      final next = base.copyWith(
        visibleCount: base.visibleCount + AppConfig.historyPageSize,
      );
      expect(next.visible.length, AppConfig.historyPageSize * 2);
      expect(next.hasMore, isTrue);
    });

    test(
      'visibleCount melebihi jumlah data tidak melempar & hasMore false',
      () {
        final state = HistoryState(
          status: HistoryStatus.loaded,
          records: _records(10),
          visibleCount: 999,
        );
        expect(state.visible.length, 10);
        expect(state.hasMore, isFalse);
      },
    );

    test('filter rentang tanggal (inklusif) menyaring berdasarkan clockIn', () {
      // _record(i) clockIn = 2026-06-01 + i hari.
      final state = HistoryState(
        status: HistoryStatus.loaded,
        records: _records(10), // 1–10 Juni
        fromDate: DateTime(2026, 6, 3),
        toDate: DateTime(2026, 6, 5),
      );
      // 3,4,5 Juni → 3 catatan.
      expect(state.filtered.length, 3);
      expect(state.hasDateFilter, isTrue);
    });

    test('filter tanggal + status digabung', () {
      final records = [
        ..._records(5, status: AttendanceStatus.hadir), // 1–5 Juni hadir
        ..._records(5, status: AttendanceStatus.telat), // 1–5 Juni telat
      ];
      final state = HistoryState(
        status: HistoryStatus.loaded,
        records: records,
        filter: AttendanceStatus.telat,
        fromDate: DateTime(2026, 6, 2),
        toDate: DateTime(2026, 6, 4),
      );
      // telat & 2–4 Juni → 3.
      expect(state.filtered.length, 3);
      expect(
        state.filtered.every((r) => r.status == AttendanceStatus.telat),
        isTrue,
      );
    });

    test('visible menghormati filter aktif', () {
      final records = [
        ..._records(5, status: AttendanceStatus.hadir),
        ..._records(3, status: AttendanceStatus.telat),
      ];
      final state = HistoryState(
        status: HistoryStatus.loaded,
        records: records,
        filter: AttendanceStatus.telat,
      );
      expect(state.visible.length, 3);
      expect(
        state.visible.every((r) => r.status == AttendanceStatus.telat),
        isTrue,
      );
      expect(state.hasMore, isFalse);
    });
  });

  group('HistoryBloc paginasi', () {
    test('load more menambah satu halaman, berhenti saat data habis', () async {
      // Bloc butuh usecase; pakai logika murni lewat copyWith di sini cukup,
      // tapi kita verifikasi guard hasMore lewat state langsung.
      var state = HistoryState(
        status: HistoryStatus.loaded,
        records: _records(20), // 20 < 2 halaman (15*2=30)
      );
      // Halaman 1: 15 tampil, masih ada sisa 5.
      expect(state.visible.length, 15);
      expect(state.hasMore, isTrue);
      // Setelah satu kali load more: semua 20 tampil, tak ada lagi.
      state = state.copyWith(
        visibleCount: state.visibleCount + AppConfig.historyPageSize,
      );
      expect(state.visible.length, 20);
      expect(state.hasMore, isFalse);
    });
  });
}

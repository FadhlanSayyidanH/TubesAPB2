// Part of: Attendance - Presentation

part of 'clock_in_bloc.dart';

sealed class ClockInEvent extends Equatable {
  const ClockInEvent();

  @override
  List<Object?> get props => [];
}

/// Dipicu saat halaman clock-in dibuka: muat kantor, absensi hari ini, lalu
/// lokasi pertama, dan mulai refresh berkala. [user] dipakai saat menyimpan.
class ClockInStarted extends ClockInEvent {
  final UserEntity user;
  const ClockInStarted(this.user);

  @override
  List<Object?> get props => [user];
}

/// Refresh posisi — dari timer 5 detik maupun tombol "Perbarui Lokasi".
class LocationRefreshRequested extends ClockInEvent {
  final bool isManual;
  const LocationRefreshRequested({this.isManual = false});

  @override
  List<Object?> get props => [isManual];
}

/// Tombol aksi ditekan: simpan clock-in bila belum absen, atau clock-out bila
/// sudah. Validasi radius dilakukan di bloc sebelum menyimpan.
///
/// [selfiePath] wajib ada untuk clock-in (file selfie yang sudah lolos
/// verifikasi wajah); null untuk clock-out (tanpa wajah).
class AttendanceSubmitted extends ClockInEvent {
  final String? selfiePath;
  const AttendanceSubmitted({this.selfiePath});

  @override
  List<Object?> get props => [selfiePath];
}

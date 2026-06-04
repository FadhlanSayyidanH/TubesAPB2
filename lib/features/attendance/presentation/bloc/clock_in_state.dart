// Part of: Attendance - Presentation

part of 'clock_in_bloc.dart';

enum ClockInStatus {
  initial,
  loadingOffice, // mengambil titik kantor
  officeError, // gagal memuat kantor (fatal untuk layar ini)
  locating, // punya kantor, sedang mencari lokasi pertama
  ready, // kantor + lokasi tersedia, peta bisa ditampilkan
  locationError, // gagal mendapatkan lokasi (GPS/izin)
}

/// Hasil aksi clock-in/out (transien) untuk dipantau UI: tampilkan dialog
/// sukses atau snackbar gagal.
enum ClockInAction { idle, submitting, clockedIn, clockedOut, failed }

class ClockInState extends Equatable {
  final ClockInStatus status;
  final UserEntity? user;
  final OfficeEntity? office;
  final LocationStatus? location;
  final AttendanceEntity? todayAttendance;
  final ClockInAction action;
  final String? message;
  final bool canOpenSettings;
  final bool isRefreshing;

  const ClockInState({
    this.status = ClockInStatus.initial,
    this.user,
    this.office,
    this.location,
    this.todayAttendance,
    this.action = ClockInAction.idle,
    this.message,
    this.canOpenSettings = false,
    this.isRefreshing = false,
  });

  bool get alreadyClockedIn => todayAttendance != null;
  bool get alreadyClockedOut => todayAttendance?.hasClockedOut ?? false;
  bool get isWithinRadius => location?.isWithinOfficeRadius ?? false;

  /// Tombol aksi aktif hanya jika lokasi siap dan absen hari ini belum tuntas.
  bool get canSubmit =>
      status == ClockInStatus.ready &&
      location != null &&
      action != ClockInAction.submitting &&
      !alreadyClockedOut;

  ClockInState copyWith({
    ClockInStatus? status,
    UserEntity? user,
    OfficeEntity? office,
    LocationStatus? location,
    AttendanceEntity? todayAttendance,
    ClockInAction? action,
    String? message,
    bool? canOpenSettings,
    bool? isRefreshing,
  }) {
    return ClockInState(
      status: status ?? this.status,
      user: user ?? this.user,
      office: office ?? this.office,
      location: location ?? this.location,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      action: action ?? this.action,
      message: message,
      canOpenSettings: canOpenSettings ?? this.canOpenSettings,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    office,
    location,
    todayAttendance,
    action,
    message,
    canOpenSettings,
    isRefreshing,
  ];
}

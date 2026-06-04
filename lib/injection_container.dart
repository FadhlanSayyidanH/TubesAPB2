// Part of: App - Dependency Injection

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/connectivity_cubit.dart';
import 'core/network/network_info.dart';
import 'core/settings/settings_cubit.dart';
import 'core/services/csv_export_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/push_token_service.dart';
import 'core/utils/image_encoder.dart';
import 'features/admin/data/datasources/admin_remote_datasource.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/domain/usecases/get_all_users_usecase.dart';
import 'features/admin/domain/usecases/get_attendance_between_usecase.dart';
import 'features/admin/domain/usecases/get_employee_count_usecase.dart';
import 'features/admin/domain/usecases/update_user_role_usecase.dart';
import 'features/admin/domain/usecases/watch_attendance_usecase.dart';
import 'features/admin/presentation/bloc/admin_stats_bloc.dart';
import 'features/admin/presentation/bloc/employee_list_bloc.dart';
import 'features/admin/presentation/bloc/export_bloc.dart';
import 'features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'features/attendance/data/datasources/location_datasource.dart';
import 'features/attendance/data/datasources/office_remote_datasource.dart';
import 'features/attendance/data/repositories/attendance_repository_impl.dart';
import 'features/attendance/domain/repositories/attendance_repository.dart';
import 'features/attendance/domain/usecases/clock_in_usecase.dart';
import 'features/attendance/domain/usecases/clock_out_usecase.dart';
import 'features/attendance/domain/usecases/get_attendance_history_usecase.dart';
import 'features/attendance/domain/usecases/get_location_status_usecase.dart';
import 'features/attendance/domain/usecases/get_primary_office_usecase.dart';
import 'features/attendance/domain/usecases/get_today_attendance_usecase.dart';
import 'features/attendance/domain/usecases/get_weekly_stats_usecase.dart';
import 'features/attendance/domain/usecases/submit_leave_usecase.dart';
import 'features/attendance/presentation/bloc/clock_in_bloc.dart';
import 'features/attendance/presentation/bloc/dashboard_bloc.dart';
import 'features/attendance/presentation/bloc/history_bloc.dart';
import 'features/attendance/presentation/bloc/leave_bloc.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/change_password_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/face/data/datasources/face_datasource.dart';
import 'features/face/data/repositories/face_repository_impl.dart';
import 'features/face/domain/repositories/face_repository.dart';
import 'features/face/domain/usecases/capture_selfie_usecase.dart';
import 'features/face/domain/usecases/start_face_camera_usecase.dart';
import 'features/face/presentation/bloc/face_capture_bloc.dart';

final sl = GetIt.instance;

/// Daftarkan seluruh dependency. Dipanggil sekali di main() setelah Firebase init.
Future<void> initDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<GeolocatorPlatform>(() => GeolocatorPlatform.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  // Singleton: satu pemantau koneksi untuk banner offline global (main.dart).
  sl.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit(sl()));
  // Singleton: preferensi tema & bahasa, dipakai di atas MaterialApp.
  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit(sl()));
  sl.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(sl()),
  );
  sl.registerLazySingleton<PushTokenService>(() => PushTokenService(sl(), sl()));
  sl.registerLazySingleton<CsvExportService>(() => CsvExportService());

  // Auth - data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // Auth - repository (butuh ImageEncoder untuk kompres foto profil)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), sl()),
  );

  // Auth - use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));

  // Auth - bloc (singleton: dipakai bersama oleh router untuk redirect)
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      login: sl(),
      logout: sl(),
      getCurrentUser: sl(),
      forgotPassword: sl(),
      local: sl(),
      repository: sl(),
    ),
  );

  // Profile - bloc (factory: instance baru tiap halaman profil dibuka)
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(updateProfile: sl(), changePassword: sl()),
  );

  // Attendance - data sources
  sl.registerLazySingleton<LocationDataSource>(
    () => LocationDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OfficeRemoteDataSource>(
    () => OfficeRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ImageEncoder>(() => ImageEncoder());

  // Attendance - repository
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(sl(), sl(), sl(), sl(), sl()),
  );

  // Attendance - use cases
  sl.registerLazySingleton(() => GetPrimaryOfficeUseCase(sl()));
  sl.registerLazySingleton(() => GetLocationStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetTodayAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => GetWeeklyStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceHistoryUseCase(sl()));
  sl.registerLazySingleton(() => ClockInUseCase(sl()));
  sl.registerLazySingleton(() => ClockOutUseCase(sl()));
  sl.registerLazySingleton(() => SubmitLeaveUseCase(sl()));

  // Attendance - blocs (factory: instance baru tiap kali halamannya dibuka)
  sl.registerFactory<ClockInBloc>(
    () => ClockInBloc(
      getOffice: sl(),
      getLocationStatus: sl(),
      getToday: sl(),
      clockIn: sl(),
      clockOut: sl(),
    ),
  );
  sl.registerFactory<DashboardBloc>(
    () => DashboardBloc(getToday: sl(), getWeeklyStats: sl()),
  );
  sl.registerFactory<HistoryBloc>(() => HistoryBloc(getHistory: sl()));
  sl.registerFactory<LeaveBloc>(() => LeaveBloc(submitLeave: sl()));

  // Face detection - data source
  sl.registerLazySingleton<FaceDataSource>(() => FaceDataSourceImpl());

  // Face detection - repository
  sl.registerLazySingleton<FaceRepository>(() => FaceRepositoryImpl(sl()));

  // Face detection - use cases
  sl.registerLazySingleton(() => StartFaceCameraUseCase(sl()));
  sl.registerLazySingleton(() => CaptureSelfieUseCase(sl()));

  // Face detection - bloc (factory: instance baru tiap halaman dibuka)
  sl.registerFactory<FaceCaptureBloc>(
    () => FaceCaptureBloc(startCamera: sl(), captureSelfie: sl()),
  );

  // Admin - data source
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(sl()),
  );

  // Admin - repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl(), sl()),
  );

  // Admin - use cases
  sl.registerLazySingleton(() => WatchAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => GetEmployeeCountUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserRoleUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceBetweenUseCase(sl()));

  // Admin - blocs (factory: instance baru tiap halaman dibuka)
  sl.registerFactory<AdminStatsBloc>(
    () => AdminStatsBloc(watchAttendance: sl(), getEmployeeCount: sl()),
  );
  sl.registerFactory<EmployeeListBloc>(
    () => EmployeeListBloc(getAllUsers: sl()),
  );
  sl.registerFactory<ExportBloc>(
    () => ExportBloc(
      getAttendanceBetween: sl(),
      getAllUsers: sl(),
      csvService: sl(),
    ),
  );
}

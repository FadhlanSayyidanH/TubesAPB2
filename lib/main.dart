// Part of: App - Entry Point

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'core/network/connectivity_cubit.dart';
import 'core/router/app_router.dart';
import 'core/settings/settings_cubit.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/push_token_service.dart';
import 'core/widgets/offline_banner.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase diinisialisasi sebelum DI agar instance Auth/Firestore siap dipakai.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();

  // Siapkan kanal notifikasi lokal + minta izin (Android 13+) sekali di awal.
  final notifications = sl<LocalNotificationService>();
  await notifications.init();
  await notifications.requestPermission();

  runApp(const SmartAttendanceApp());
}

class SmartAttendanceApp extends StatefulWidget {
  const SmartAttendanceApp({super.key});

  @override
  State<SmartAttendanceApp> createState() => _SmartAttendanceAppState();
}

class _SmartAttendanceAppState extends State<SmartAttendanceApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;
  final PushTokenService _pushToken = sl<PushTokenService>();
  final LocalNotificationService _notifications =
      sl<LocalNotificationService>();

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());
    _appRouter = AppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  /// Saat sesi berubah: simpan FCM token & jadwalkan pengingat absen (karyawan
  /// saja — admin tidak melakukan absen). Saat logout: hentikan keduanya.
  void _onAuthChanged(BuildContext context, AuthState state) {
    if (state is Authenticated) {
      _pushToken.registerFor(state.user.uid);
      if (!state.user.isAdmin) {
        _notifications.scheduleDailyClockInReminder();
        _notifications.scheduleDailyClockOutReminder();
      } else {
        _notifications.cancelDailyReminder();
      }
    } else if (state is Unauthenticated) {
      _pushToken.stop();
      _notifications.cancelDailyReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        // Singleton dari DI: hidup selama aplikasi → banner offline global.
        BlocProvider.value(value: sl<ConnectivityCubit>()),
        // Preferensi tema & bahasa.
        BlocProvider.value(value: sl<SettingsCubit>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            curr is Authenticated || curr is Unauthenticated,
        listener: _onAuthChanged,
        child: BlocBuilder<SettingsCubit, AppSettings>(
          builder: (context, settings) {
            return MaterialApp.router(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: settings.themeMode,
              // Locale Material/Cupertino (date picker dll) ikut bahasa app.
              locale: settings.locale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('id'), Locale('en')],
              routerConfig: _appRouter.router,
              // Bungkus seluruh halaman: banner offline + KeyedSubtree ber-key
              // tema+bahasa. Warna (AppColors) & teks (AppStrings) statis
              // di-cache saat build, sehingga ganti tema/bahasa perlu rebuild
              // penuh subtree agar teks/ikon ikut berganti. Lokasi navigasi
              // tetap dijaga oleh GoRouter.
              builder: (context, child) => OfflineBanner(
                child: KeyedSubtree(
                  key: ValueKey('${settings.isDark}_${settings.isEnglish}'),
                  child: child!,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

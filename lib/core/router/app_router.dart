// Part of: Core - Router

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/employee_detail_page.dart';
import '../../features/admin/presentation/pages/employee_list_page.dart';
import '../../features/attendance/presentation/pages/clock_in_page.dart';
import '../../features/attendance/presentation/pages/dashboard_page.dart';
import '../../features/attendance/presentation/pages/history_page.dart';
import '../../features/attendance/presentation/pages/leave_request_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/face/presentation/pages/face_capture_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// Konfigurasi navigasi terpusat. Redirect menonton AuthBloc: belum login →
/// /login, sudah login → dashboard sesuai role, dan /admin dijaga dari employee.
class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthBlocRefresh(_authBloc.stream),
    redirect: _redirect,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(path: '/dashboard', builder: (_, _) => const DashboardPage()),
      GoRoute(path: '/history', builder: (_, _) => const HistoryPage()),
      GoRoute(path: '/leave', builder: (_, _) => const LeaveRequestPage()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
      GoRoute(path: '/clock-in', builder: (_, _) => const ClockInPage()),
      GoRoute(
        path: '/face-capture',
        builder: (_, _) => const FaceCapturePage(),
      ),
      GoRoute(path: '/admin', builder: (_, _) => const AdminDashboardPage()),
      GoRoute(
        path: '/admin/employees',
        builder: (_, _) => const EmployeeListPage(),
      ),
      GoRoute(
        path: '/admin/employee-detail',
        builder: (_, state) =>
            EmployeeDetailPage(user: state.extra! as UserEntity),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final location = state.matchedLocation;

    // Selama sesi belum dipastikan, tahan di splash.
    if (authState is AuthInitial ||
        (authState is AuthLoading && !authState.isSubmitting)) {
      return location == '/splash' ? null : '/splash';
    }

    final isLoggedIn = authState is Authenticated;
    final onAuthScreen = location == '/login' ||
        location == '/forgot-password' ||
        location == '/splash';

    if (!isLoggedIn) {
      return onAuthScreen && location != '/splash' ? null : '/login';
    }

    // Sudah login: arahkan sesuai role dan halangi akses lintas-role.
    final home = authState.user.isAdmin ? '/admin' : '/dashboard';
    if (onAuthScreen) return home;
    if (location.startsWith('/admin') && !authState.user.isAdmin) {
      return '/dashboard';
    }
    if (location == '/dashboard' && authState.user.isAdmin) return '/admin';
    return null;
  }
}

/// Menjembatani `Stream<AuthState>` BLoC ke Listenable yang dimengerti go_router,
/// supaya redirect dievaluasi ulang setiap kali status auth berubah.
class _AuthBlocRefresh extends ChangeNotifier {
  _AuthBlocRefresh(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

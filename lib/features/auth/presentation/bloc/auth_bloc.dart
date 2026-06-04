// Part of: Auth - Presentation

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;
  final ForgotPasswordUseCase _forgotPassword;
  final AuthLocalDataSource _local;

  StreamSubscription<String?>? _authSub;

  AuthBloc({
    required LoginUseCase login,
    required LogoutUseCase logout,
    required GetCurrentUserUseCase getCurrentUser,
    required ForgotPasswordUseCase forgotPassword,
    required AuthLocalDataSource local,
    required AuthRepository repository,
  })  : _login = login,
        _logout = logout,
        _getCurrentUser = getCurrentUser,
        _forgotPassword = forgotPassword,
        _local = local,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthProfileUpdated>(_onProfileUpdated);

    // Pantau perubahan sesi Firebase (mis. token kedaluwarsa / logout di tab lain).
    _authSub = repository.authStateChanges.listen(
      (uid) => add(AuthStateChanged(uid)),
    );
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _getCurrentUser();
    result.fold(
      (_) => emit(Unauthenticated(
        rememberedIdentifier: _local.getRememberedIdentifier(),
      )),
      (user) => user != null
          ? emit(Authenticated(user))
          : emit(Unauthenticated(
              rememberedIdentifier: _local.getRememberedIdentifier(),
            )),
    );
  }

  /// Re-fetch profil saat stream auth memancarkan uid berbeda dari state aktif.
  /// Mencegah pengambilan ulang ketika kita baru saja login secara manual.
  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.uid == null) {
      if (state is! Unauthenticated) {
        emit(Unauthenticated(
          rememberedIdentifier: _local.getRememberedIdentifier(),
        ));
      }
      return;
    }
    final current = state;
    if (current is Authenticated && current.user.uid == event.uid) return;

    final result = await _getCurrentUser();
    result.fold(
      (_) {},
      (user) {
        if (user != null) emit(Authenticated(user));
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(isSubmitting: true));
    final result = await _login(
      identifier: event.identifier,
      password: event.password,
    );
    await result.fold(
      (failure) async => emit(AuthError(
        failure.message,
        rememberedIdentifier: _local.getRememberedIdentifier(),
      )),
      (user) async {
        // Simpan identifier hanya bila "Ingat saya" dicentang — tidak pernah password.
        if (event.rememberMe) {
          await _local.saveRememberedIdentifier(event.identifier);
        } else {
          await _local.clearRememberedIdentifier();
        }
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(Unauthenticated(rememberedIdentifier: _local.getRememberedIdentifier()));
  }

  void _onProfileUpdated(AuthProfileUpdated event, Emitter<AuthState> emit) {
    if (state is Authenticated) emit(Authenticated(event.user));
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(isSubmitting: true));
    final result = await _forgotPassword(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const PasswordResetSent()),
    );
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}

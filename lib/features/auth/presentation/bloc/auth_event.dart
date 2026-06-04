// Part of: Auth - Presentation

part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dipicu saat splash: cek apakah ada sesi tersimpan untuk menentukan rute awal.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Stream authStateChanges memancarkan uid baru (atau null saat logout).
class AuthStateChanged extends AuthEvent {
  final String? uid;
  const AuthStateChanged(this.uid);

  @override
  List<Object?> get props => [uid];
}

class LoginRequested extends AuthEvent {
  final String identifier;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.identifier,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [identifier, password, rememberMe];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Profil tersimpan dari halaman Profil — segarkan user di state Authenticated
/// agar sapaan & avatar di dashboard ikut terbarui tanpa fetch ulang.
class AuthProfileUpdated extends AuthEvent {
  final UserEntity user;
  const AuthProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

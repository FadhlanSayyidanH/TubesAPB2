// Part of: Auth - Presentation

part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Status awal sebelum pengecekan sesi selesai (splash menampilkan logo).
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Sedang memproses login / cek sesi. [isSubmitting] membedakan loading tombol
/// login (true) dari loading pengecekan sesi di splash (false).
class AuthLoading extends AuthState {
  final bool isSubmitting;
  const AuthLoading({this.isSubmitting = false});

  @override
  List<Object?> get props => [isSubmitting];
}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  /// Pre-fill form login bila "Ingat saya" pernah aktif.
  final String? rememberedIdentifier;
  const Unauthenticated({this.rememberedIdentifier});

  @override
  List<Object?> get props => [rememberedIdentifier];
}

class AuthError extends AuthState {
  final String message;
  final String? rememberedIdentifier;
  const AuthError(this.message, {this.rememberedIdentifier});

  @override
  List<Object?> get props => [message, rememberedIdentifier];
}

/// Hasil pengiriman email reset password (untuk SnackBar konfirmasi).
class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}

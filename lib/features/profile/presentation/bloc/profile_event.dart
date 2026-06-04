// Part of: Profile - Presentation

part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Simpan nama (dan foto baru bila [photoPath] diisi) ke profil.
class ProfileSaveRequested extends ProfileEvent {
  final String uid;
  final String name;
  final String? photoPath;

  const ProfileSaveRequested({
    required this.uid,
    required this.name,
    this.photoPath,
  });

  @override
  List<Object?> get props => [uid, name, photoPath];
}

class ProfilePasswordChangeRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ProfilePasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

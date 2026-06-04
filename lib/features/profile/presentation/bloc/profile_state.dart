// Part of: Profile - Presentation

part of 'profile_bloc.dart';

enum ProfileSaveStatus { idle, saving, success, failure }

enum ProfilePasswordStatus { idle, submitting, success, failure }

class ProfileState extends Equatable {
  final ProfileSaveStatus saveStatus;
  final ProfilePasswordStatus passwordStatus;
  final String? saveMessage;
  final String? passwordMessage;

  /// Profil terbaru setelah simpan sukses — dipakai halaman untuk menyegarkan
  /// AuthBloc (sapaan dashboard) dan menampilkan foto baru.
  final UserEntity? updatedUser;

  const ProfileState({
    this.saveStatus = ProfileSaveStatus.idle,
    this.passwordStatus = ProfilePasswordStatus.idle,
    this.saveMessage,
    this.passwordMessage,
    this.updatedUser,
  });

  ProfileState copyWith({
    ProfileSaveStatus? saveStatus,
    ProfilePasswordStatus? passwordStatus,
    String? saveMessage,
    String? passwordMessage,
    UserEntity? updatedUser,
    bool clearSaveMessage = false,
    bool clearPasswordMessage = false,
  }) {
    return ProfileState(
      saveStatus: saveStatus ?? this.saveStatus,
      passwordStatus: passwordStatus ?? this.passwordStatus,
      saveMessage: clearSaveMessage ? null : (saveMessage ?? this.saveMessage),
      passwordMessage:
          clearPasswordMessage ? null : (passwordMessage ?? this.passwordMessage),
      updatedUser: updatedUser ?? this.updatedUser,
    );
  }

  @override
  List<Object?> get props =>
      [saveStatus, passwordStatus, saveMessage, passwordMessage, updatedUser];
}

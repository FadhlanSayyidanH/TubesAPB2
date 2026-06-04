// Part of: Profile - Presentation

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/change_password_usecase.dart';
import '../../../auth/domain/usecases/update_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Mengelola dua aksi independen di halaman Profil: simpan nama+foto dan ganti
/// kata sandi. Statusnya dipisah supaya satu form tidak menampilkan loading
/// milik form lainnya.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUseCase _updateProfile;
  final ChangePasswordUseCase _changePassword;

  ProfileBloc({
    required UpdateProfileUseCase updateProfile,
    required ChangePasswordUseCase changePassword,
  }) : _updateProfile = updateProfile,
       _changePassword = changePassword,
       super(const ProfileState()) {
    on<ProfileSaveRequested>(_onSaveRequested);
    on<ProfilePasswordChangeRequested>(_onPasswordChangeRequested);
  }

  Future<void> _onSaveRequested(
    ProfileSaveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        saveStatus: ProfileSaveStatus.saving,
        clearSaveMessage: true,
      ),
    );
    final result = await _updateProfile(
      uid: event.uid,
      name: event.name,
      photoPath: event.photoPath,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          saveStatus: ProfileSaveStatus.failure,
          saveMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          saveStatus: ProfileSaveStatus.success,
          updatedUser: user,
        ),
      ),
    );
  }

  Future<void> _onPasswordChangeRequested(
    ProfilePasswordChangeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        passwordStatus: ProfilePasswordStatus.submitting,
        clearPasswordMessage: true,
      ),
    );
    final result = await _changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          passwordStatus: ProfilePasswordStatus.failure,
          passwordMessage: failure.message,
        ),
      ),
      (_) =>
          emit(state.copyWith(passwordStatus: ProfilePasswordStatus.success)),
    );
  }
}

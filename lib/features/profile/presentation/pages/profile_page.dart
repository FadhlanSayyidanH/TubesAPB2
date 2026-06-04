// Part of: Profile - Presentation

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../../../attendance/presentation/widgets/selfie_image.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return BlocProvider(
      create: (_) => sl<ProfileBloc>(),
      child: _ProfileView(initialUser: authState.user),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final UserEntity initialUser;
  const _ProfileView({required this.initialUser});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _nameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialUser.name,
  );
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  /// Path foto baru yang baru dipilih, belum tersimpan. Null = pakai foto profil
  /// yang sudah ada di server.
  String? _pickedPhotoPath;

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 90,
      );
      if (picked != null && mounted) {
        setState(() => _pickedPhotoPath = picked.path);
      }
    } catch (_) {
      if (mounted) _showSnackBar(AppStrings.errPickImage, isError: true);
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(AppStrings.pickFromCamera),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(AppStrings.pickFromGallery),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile(String uid) {
    FocusScope.of(context).unfocus();
    if (!_nameFormKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
      ProfileSaveRequested(
        uid: uid,
        name: _nameController.text,
        photoPath: _pickedPhotoPath,
      ),
    );
  }

  void _changePassword() {
    FocusScope.of(context).unfocus();
    if (!_passwordFormKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
      ProfilePasswordChangeRequested(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.success,
        ),
      );
  }

  /// Hanya tangani transisi status SIMPAN. Dipasang lewat listener terpisah
  /// (listenWhen saveStatus) supaya perubahan status ganti-sandi tidak ikut
  /// memunculkan ulang snackbar profil.
  void _onSaveStatusChanged(BuildContext context, ProfileState state) {
    switch (state.saveStatus) {
      case ProfileSaveStatus.success:
        final user = state.updatedUser;
        if (user != null) {
          context.read<AuthBloc>().add(AuthProfileUpdated(user));
        }
        setState(() => _pickedPhotoPath = null);
        _showSnackBar(AppStrings.profileSaved, isError: false);
      case ProfileSaveStatus.failure:
        _showSnackBar(
          state.saveMessage ?? AppStrings.errUnknown,
          isError: true,
        );
      case ProfileSaveStatus.idle:
      case ProfileSaveStatus.saving:
        break;
    }
  }

  void _onPasswordStatusChanged(BuildContext context, ProfileState state) {
    switch (state.passwordStatus) {
      case ProfilePasswordStatus.success:
        // reset() membersihkan field + status validasi sekaligus, jadi field
        // kosong pasca-sukses tidak langsung menampilkan "wajib diisi".
        _passwordFormKey.currentState?.reset();
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _showSnackBar(AppStrings.passwordChanged, isError: false);
      case ProfilePasswordStatus.failure:
        _showSnackBar(
          state.passwordMessage ?? AppStrings.errUnknown,
          isError: true,
        );
      case ProfilePasswordStatus.idle:
      case ProfilePasswordStatus.submitting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profileTitle),
        actions: const [LogoutButton()],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (prev, curr) => prev.saveStatus != curr.saveStatus,
            listener: _onSaveStatusChanged,
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (prev, curr) =>
                prev.passwordStatus != curr.passwordStatus,
            listener: _onPasswordStatusChanged,
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (prev, curr) => curr is Authenticated,
          builder: (context, authState) {
            final user = authState is Authenticated
                ? authState.user
                : widget.initialUser;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                Center(
                  child: _ProfileAvatar(
                    user: user,
                    pickedPhotoPath: _pickedPhotoPath,
                    onTap: _showPhotoSourceSheet,
                  ),
                ),
                const SizedBox(height: 24),
                _EmployeeIdCard(user: user),
                const SizedBox(height: 28),
                // Tidak const: judul seksi ("Pengaturan") membaca AppStrings
                // (getter locale-aware) — const akan membekukan teks saat bahasa
                // diganti karena widget const dilewati saat parent rebuild.
                _AppSettingsSection(),
                const Divider(height: 48),
                _buildEditNameSection(user.uid),
                const Divider(height: 48),
                _buildChangePasswordSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditNameSection(String uid) {
    return Form(
      key: _nameFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.editProfileSection, style: AppTextStyles.title),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _nameController,
            label: AppStrings.labelName,
            hint: AppStrings.fieldNameHint,
            icon: Icons.person_outline,
            textInputAction: TextInputAction.done,
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          BlocBuilder<ProfileBloc, ProfileState>(
            buildWhen: (p, c) => p.saveStatus != c.saveStatus,
            builder: (context, state) => PrimaryButton(
              label: AppStrings.saveProfile,
              icon: Icons.save_outlined,
              isLoading: state.saveStatus == ProfileSaveStatus.saving,
              onPressed: () => _saveProfile(uid),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.changePasswordSection, style: AppTextStyles.title),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _currentPasswordController,
            label: AppStrings.fieldCurrentPasswordLabel,
            hint: AppStrings.fieldCurrentPasswordHint,
            icon: Icons.lock_outline,
            isPassword: true,
            validator: Validators.password,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _newPasswordController,
            label: AppStrings.fieldNewPasswordLabel,
            hint: AppStrings.fieldNewPasswordHint,
            icon: Icons.lock_reset_outlined,
            isPassword: true,
            validator: _validateNewPassword,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmPasswordController,
            label: AppStrings.fieldConfirmPasswordLabel,
            hint: AppStrings.fieldConfirmPasswordHint,
            icon: Icons.lock_reset_outlined,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 16),
          BlocBuilder<ProfileBloc, ProfileState>(
            buildWhen: (p, c) => p.passwordStatus != c.passwordStatus,
            builder: (context, state) => PrimaryButton(
              label: AppStrings.changePasswordButton,
              icon: Icons.lock_outline,
              isLoading:
                  state.passwordStatus == ProfilePasswordStatus.submitting,
              onPressed: _changePassword,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateName(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return AppStrings.nameRequired;
    if (input.length < 3) return AppStrings.nameTooShort;
    return null;
  }

  /// Kata sandi baru: valid sebagai password DAN harus beda dari yang sekarang.
  String? _validateNewPassword(String? value) {
    final base = Validators.password(value);
    if (base != null) return base;
    if (value == _currentPasswordController.text) {
      return AppStrings.newPasswordSameAsOld;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _newPasswordController.text) {
      return AppStrings.confirmPasswordMismatch;
    }
    return null;
  }
}

/// Seksi pengaturan aplikasi: mode gelap (bahasa ditambah di langkah i18n).
class _AppSettingsSection extends StatelessWidget {
  const _AppSettingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.settingsSection, style: AppTextStyles.title),
        const SizedBox(height: 8),
        BlocBuilder<SettingsCubit, AppSettings>(
          builder: (context, settings) => Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  settings.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.safetyOrange,
                ),
                title: Text(
                  AppStrings.darkModeTitle,
                  style: AppTextStyles.bodyBold,
                ),
                subtitle: Text(
                  AppStrings.darkModeSubtitle,
                  style: AppTextStyles.caption,
                ),
                value: settings.isDark,
                onChanged: (value) =>
                    context.read<SettingsCubit>().setDarkMode(value),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(
                  Icons.translate,
                  color: AppColors.safetyOrange,
                ),
                title: Text(
                  AppStrings.languageTitle,
                  style: AppTextStyles.bodyBold,
                ),
                subtitle: Text(
                  AppStrings.languageSubtitle,
                  style: AppTextStyles.caption,
                ),
                value: settings.isEnglish,
                onChanged: (value) =>
                    context.read<SettingsCubit>().setEnglish(value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Avatar bundar 96px yang bisa diketuk untuk ganti foto. Menampilkan (urut
/// prioritas) foto yang baru dipilih, foto profil tersimpan (data URI/URL),
/// atau inisial nama.
class _ProfileAvatar extends StatelessWidget {
  final UserEntity user;
  final String? pickedPhotoPath;
  final VoidCallback onTap;

  const _ProfileAvatar({
    required this.user,
    required this.pickedPhotoPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipOval(child: SizedBox(width: 96, height: 96, child: _image())),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.safetyOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 16,
              color: AppColors.textOnDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _image() {
    if (pickedPhotoPath != null) {
      return Image.file(File(pickedPhotoPath!), fit: BoxFit.cover);
    }
    if (user.photoUrl.isNotEmpty) {
      return SelfieImage(selfieUrl: user.photoUrl, fit: BoxFit.cover);
    }
    return Container(
      color: AppColors.deepNavy,
      alignment: Alignment.center,
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        style: AppTextStyles.displayLarge.copyWith(color: AppColors.textOnDark),
      ),
    );
  }
}

/// Kartu identitas karyawan — ringkasan data read-only dari Firestore.
class _EmployeeIdCard extends StatelessWidget {
  final UserEntity user;
  const _EmployeeIdCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final roleLabel = user.isAdmin
        ? AppStrings.profileRoleAdmin
        : AppStrings.profileRoleEmployee;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 20,
                  color: AppColors.safetyOrange,
                ),
                const SizedBox(width: 8),
                Text(AppStrings.profileIdCardTitle, style: AppTextStyles.title),
              ],
            ),
            const SizedBox(height: 16),
            _IdRow(label: AppStrings.labelName, value: user.name),
            _IdRow(label: AppStrings.labelEmail, value: user.email),
            _IdRow(label: AppStrings.labelNik, value: user.nik),
            _IdRow(label: AppStrings.labelDepartment, value: user.department),
            _IdRow(label: AppStrings.labelRole, value: roleLabel, isLast: true),
          ],
        ),
      ),
    );
  }
}

class _IdRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _IdRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: AppTextStyles.bodyBold,
            ),
          ),
        ],
      ),
    );
  }
}

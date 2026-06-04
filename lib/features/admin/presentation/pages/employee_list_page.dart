// Part of: Admin - Presentation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../../../attendance/presentation/widgets/selfie_image.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/employee_list_bloc.dart';
import '../widgets/role_badge.dart';

class EmployeeListPage extends StatelessWidget {
  const EmployeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EmployeeListBloc>()..add(const EmployeeListRequested()),
      child: const _EmployeeListView(),
    );
  }
}

class _EmployeeListView extends StatelessWidget {
  const _EmployeeListView();

  Future<void> _openDetail(BuildContext context, UserEntity user) async {
    await context.push('/admin/employee-detail', extra: user);
    // Peran bisa berubah di halaman detail → muat ulang daftar saat kembali.
    if (context.mounted) {
      context.read<EmployeeListBloc>().add(const EmployeeListRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.employeesTitle)),
      body: BlocBuilder<EmployeeListBloc, EmployeeListState>(
        builder: (context, state) {
          switch (state.status) {
            case EmployeeListStatus.initial:
            case EmployeeListStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case EmployeeListStatus.error:
              return _ErrorState(
                message: state.message ?? AppStrings.errUnknown,
                onRetry: () => context.read<EmployeeListBloc>().add(
                  const EmployeeListRequested(),
                ),
              );
            case EmployeeListStatus.loaded:
              if (state.users.isEmpty) {
                return Center(child: Text(AppStrings.employeesEmpty));
              }
              final users = state.visibleUsers;
              return Column(
                children: [
                  const _SearchField(),
                  Expanded(
                    child: users.isEmpty
                        ? const _NoSearchResult()
                        : RefreshIndicator(
                            onRefresh: () async => context
                                .read<EmployeeListBloc>()
                                .add(const EmployeeListRequested()),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: users.length,
                              itemBuilder: (_, i) => _EmployeeTile(
                                user: users[i],
                                onTap: () => _openDetail(context, users[i]),
                              ),
                            ),
                          ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}

/// Kolom pencarian karyawan. Filter berjalan client-side via EmployeeListBloc.
class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          context.read<EmployeeListBloc>().add(EmployeeSearchChanged(value));
          setState(() {}); // refresh visibilitas ikon clear
        },
        decoration: InputDecoration(
          hintText: AppStrings.employeeSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    context.read<EmployeeListBloc>().add(
                      const EmployeeSearchChanged(''),
                    );
                    setState(() {});
                  },
                ),
          isDense: true,
        ),
        // Perbarui ikon clear saat teks berubah.
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}

class _NoSearchResult extends StatelessWidget {
  const _NoSearchResult();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: AppColors.divider),
            const SizedBox(height: 12),
            Text(
              AppStrings.employeeSearchEmpty,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onTap;
  const _EmployeeTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              UserAvatar(user: user, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.departmentNik(user.department, user.nik),
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    RoleBadge(role: user.role),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar user: foto profil (data URI) bila ada, jika tidak inisial nama.
class UserAvatar extends StatelessWidget {
  final UserEntity user;
  final double radius;
  const UserAvatar({super.key, required this.user, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    if (user.photoUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.deepNavy,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: AppTextStyles.title.copyWith(color: AppColors.textOnDark),
        ),
      );
    }
    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: SelfieImage(selfieUrl: user.photoUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: AppStrings.tryAgain,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

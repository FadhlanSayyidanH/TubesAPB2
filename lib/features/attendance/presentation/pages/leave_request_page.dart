// Part of: Attendance - Presentation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_format_id.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/leave_bloc.dart';

/// Form pengajuan izin: pilih tanggal + tulis alasan → langsung tercatat izin.
class LeaveRequestPage extends StatelessWidget {
  const LeaveRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return BlocProvider(
      create: (_) => sl<LeaveBloc>(),
      child: _LeaveView(user: authState.user),
    );
  }
}

class _LeaveView extends StatefulWidget {
  final UserEntity user;
  const _LeaveView({required this.user});

  @override
  State<_LeaveView> createState() => _LeaveViewState();
}

class _LeaveViewState extends State<_LeaveView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 7)),
      lastDate: DateTime(now.year, now.month, now.day)
          .add(const Duration(days: 60)),
      helpText: AppStrings.leaveDateLabel,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<LeaveBloc>().add(LeaveSubmitted(
          user: widget.user,
          date: _selectedDate,
          reason: _reasonController.text,
        ));
  }

  void _onState(BuildContext context, LeaveState state) {
    final messenger = ScaffoldMessenger.of(context);
    if (state.status == LeaveStatus.success) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(AppStrings.leaveSuccess),
          backgroundColor: AppColors.success,
        ));
      context.pop();
    } else if (state.status == LeaveStatus.error) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(state.message ?? AppStrings.errUnknown),
          backgroundColor: AppColors.error,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.leaveTitle)),
      body: BlocConsumer<LeaveBloc, LeaveState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: _onState,
        builder: (context, state) {
          final isSubmitting = state.status == LeaveStatus.submitting;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.leaveSubtitle, style: AppTextStyles.subtitle),
                  const SizedBox(height: 24),
                  Text(AppStrings.leaveDateLabel, style: AppTextStyles.bodyBold),
                  const SizedBox(height: 8),
                  _DateField(
                    label: formatTanggalLengkap(_selectedDate),
                    onTap: isSubmitting ? null : _pickDate,
                  ),
                  const SizedBox(height: 20),
                  Text(AppStrings.leaveReasonLabel,
                      style: AppTextStyles.bodyBold),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 4,
                    enabled: !isSubmitting,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: AppStrings.leaveReasonHint,
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return AppStrings.leaveReasonRequired;
                      if (text.length < 5) return AppStrings.leaveReasonTooShort;
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: AppStrings.leaveSubmitButton,
                      icon: Icons.event_available,
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Kotak tappable yang menampilkan tanggal terpilih (mirip field).
class _DateField extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _DateField({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            Icon(Icons.edit_calendar_outlined,
                size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

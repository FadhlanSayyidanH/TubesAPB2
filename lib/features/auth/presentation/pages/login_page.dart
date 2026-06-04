// Part of: Auth - Presentation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _prefilledFromRemember = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      LoginRequested(
        identifier: _identifierController.text,
        password: _passwordController.text,
        rememberMe: _rememberMe,
      ),
    );
  }

  /// Isi otomatis field identifier dari preferensi "Ingat saya" sekali saja,
  /// tanpa menimpa ketikan user yang sedang berjalan.
  void _applyRememberedIdentifier(String? identifier) {
    if (_prefilledFromRemember || identifier == null || identifier.isEmpty) {
      return;
    }
    _identifierController.text = identifier;
    _prefilledFromRemember = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => curr is AuthError,
          listener: (context, state) {
            if (state is AuthError) {
              _applyRememberedIdentifier(state.rememberedIdentifier);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
            }
          },
          builder: (context, state) {
            if (state is Unauthenticated) {
              _applyRememberedIdentifier(state.rememberedIdentifier);
            }
            final isSubmitting = state is AuthLoading && state.isSubmitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    AuthTextField(
                      controller: _identifierController,
                      label: AppStrings.fieldIdentifierLabel,
                      hint: AppStrings.fieldIdentifierHint,
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      validator: Validators.identifier,
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                      controller: _passwordController,
                      label: AppStrings.fieldPasswordLabel,
                      hint: AppStrings.fieldPasswordHint,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                    _buildRememberRow(context),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: isSubmitting
                          ? AppStrings.loginLoading
                          : AppStrings.loginButton,
                      isLoading: isSubmitting,
                      onPressed: _submit,
                      icon: Icons.login,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.fingerprint,
            color: AppColors.safetyOrange,
            size: 36,
          ),
        ),
        const SizedBox(height: 24),
        Text(AppStrings.loginTitle, style: AppTextStyles.displayLarge),
        const SizedBox(height: 8),
        Text(AppStrings.loginSubtitle, style: AppTextStyles.subtitle),
      ],
    );
  }

  Widget _buildRememberRow(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _rememberMe,
            activeColor: AppColors.safetyOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Text(AppStrings.rememberMe, style: AppTextStyles.body),
        const Spacer(),
        TextButton(
          onPressed: () => context.push('/forgot-password'),
          child: Text(AppStrings.forgotPassword, style: AppTextStyles.bodyBold),
        ),
      ],
    );
  }
}

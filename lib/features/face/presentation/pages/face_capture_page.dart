// Part of: Face Detection - Presentation

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../bloc/face_capture_bloc.dart';
import '../widgets/oval_face_guide.dart';

/// Layar verifikasi wajah: preview kamera depan + panduan oval + tombol rana.
/// Saat selfie lolos validasi, halaman ditutup mengembalikan path foto (String).
class FaceCapturePage extends StatelessWidget {
  const FaceCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FaceCaptureBloc>()..add(const FaceCameraRequested()),
      child: const _FaceCaptureView(),
    );
  }
}

class _FaceCaptureView extends StatelessWidget {
  const _FaceCaptureView();

  void _onStateChanged(BuildContext context, FaceCaptureState state) {
    if (state.rejectionMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.rejectionMessage!),
            backgroundColor: AppColors.warning,
          ),
        );
    }
    if (state.status == FaceCaptureStatus.success) {
      Navigator.of(context).pop(state.capturedPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppStrings.faceCaptureTitle),
        backgroundColor: Colors.black,
        foregroundColor: AppColors.textOnDark,
      ),
      body: BlocConsumer<FaceCaptureBloc, FaceCaptureState>(
        listenWhen: (prev, curr) =>
            prev.rejectionMessage != curr.rejectionMessage ||
            (prev.status != curr.status &&
                curr.status == FaceCaptureStatus.success),
        listener: _onStateChanged,
        builder: (context, state) {
          switch (state.status) {
            case FaceCaptureStatus.initializing:
              return _CameraLoader(message: AppStrings.facePreparingCamera);
            case FaceCaptureStatus.cameraError:
              return _CameraErrorState(state: state);
            case FaceCaptureStatus.ready:
            case FaceCaptureStatus.capturing:
            case FaceCaptureStatus.success:
              return _CameraView(state: state);
          }
        },
      ),
    );
  }
}

class _CameraView extends StatelessWidget {
  final FaceCaptureState state;
  const _CameraView({required this.state});

  @override
  Widget build(BuildContext context) {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) {
      return _CameraLoader(message: AppStrings.facePreparingCamera);
    }
    final capturing = state.status == FaceCaptureStatus.capturing;

    return Stack(
      fit: StackFit.expand,
      children: [
        _CoveredPreview(controller: controller),
        const OvalFaceGuide(),
        Positioned(
          top: 16,
          left: 24,
          right: 24,
          child: Text(
            capturing ? AppStrings.faceCheckingQuality : AppStrings.faceGuide,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textOnDark),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: _ShutterButton(
              isBusy: capturing,
              onPressed: capturing
                  ? null
                  : () => context.read<FaceCaptureBloc>().add(
                      const FaceShutterPressed(),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Preview kamera yang mengisi penuh layar (BoxFit.cover) tanpa distorsi.
class _CoveredPreview extends StatelessWidget {
  final CameraController controller;
  const _CoveredPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final preview = controller.value.previewSize!;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          // previewSize dilaporkan dalam orientasi lanskap, jadi sumbu ditukar.
          width: preview.height,
          height: preview.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback? onPressed;
  const _ShutterButton({required this.isBusy, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.textOnDark, width: 4),
        ),
        child: Center(
          child: isBusy
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(AppColors.safetyOrange),
                  ),
                )
              : Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.safetyOrange,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CameraLoader extends StatelessWidget {
  final String message;
  const _CameraLoader({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.safetyOrange),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textOnDark),
          ),
        ],
      ),
    );
  }
}

class _CameraErrorState extends StatelessWidget {
  final FaceCaptureState state;
  const _CameraErrorState({required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              size: 64,
              color: AppColors.outsideRadius,
            ),
            const SizedBox(height: 16),
            Text(
              state.cameraErrorMessage ?? AppStrings.errCameraUnavailable,
              style: AppTextStyles.body.copyWith(color: AppColors.textOnDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: state.canOpenSettings
                    ? AppStrings.openSettings
                    : AppStrings.tryAgain,
                onPressed: () async {
                  if (state.canOpenSettings) {
                    await openAppSettings();
                  } else {
                    context.read<FaceCaptureBloc>().add(
                      const FaceCameraRequested(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Part of: Auth - Data

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/image_encoder.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final NetworkInfo _networkInfo;
  final ImageEncoder _imageEncoder;

  AuthRepositoryImpl(this._remote, this._networkInfo, this._imageEncoder);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    try {
      final user = await _remote.login(
        identifier: identifier,
        password: password,
      );
      return Right(user);
    } on NikNotFoundException {
      return Left(AuthFailure(AppStrings.errNikNotFound));
    } on ProfileNotFoundException {
      return Left(ProfileFailure(AppStrings.errProfileMissing));
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthCode(e.code)));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remote.getCurrentUser();
      return Right(user);
    } on ProfileNotFoundException {
      return Left(ProfileFailure(AppStrings.errProfileMissing));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remote.logout();
      return const Right(null);
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    try {
      await _remote.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthCode(e.code)));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String uid,
    required String name,
    String? photoPath,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    try {
      // Siapkan foto (kompres → data URI) DULU; kalau encode gagal, jangan
      // sentuh Firestore supaya nama & foto tidak tersimpan setengah jalan.
      String? photoDataUri;
      if (photoPath != null) {
        try {
          photoDataUri = await _imageEncoder.encodeToDataUri(photoPath);
        } on Exception {
          return Left(ServerFailure(AppStrings.errProfilePhotoFailed));
        }
      }
      final user = await _remote.updateProfile(
        uid: uid,
        name: name,
        photoUrl: photoDataUri,
      );
      return Right(user);
    } on ProfileNotFoundException {
      return Left(ProfileFailure(AppStrings.errProfileMissing));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure(AppStrings.errNoInternet));
    }
    try {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapChangePasswordCode(e.code)));
    } catch (_) {
      return Left(ServerFailure(AppStrings.errUnknown));
    }
  }

  @override
  Stream<String?> get authStateChanges => _remote.authStateChanges;

  /// Terjemahkan kode error mentah Firebase ke kalimat actionable Bahasa Indonesia.
  String _mapAuthCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
        return AppStrings.errUserNotFound;
      case 'wrong-password':
        return AppStrings.errWrongPassword;
      case 'invalid-email':
        return AppStrings.errInvalidEmail;
      case 'user-disabled':
        return AppStrings.errUserDisabled;
      case 'too-many-requests':
        return AppStrings.errTooManyRequests;
      case 'network-request-failed':
        return AppStrings.errNoInternet;
      default:
        return AppStrings.errUnknown;
    }
  }

  /// Mapping khusus konteks ganti kata sandi: 'wrong-password'/'invalid-credential'
  /// di sini berarti kata sandi LAMA yang salah, bukan gagal login biasa.
  String _mapChangePasswordCode(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return AppStrings.errCurrentPasswordWrong;
      case 'weak-password':
        return AppStrings.errWeakPassword;
      case 'requires-recent-login':
        return AppStrings.errRequiresRecentLogin;
      case 'too-many-requests':
        return AppStrings.errTooManyRequests;
      case 'network-request-failed':
        return AppStrings.errNoInternet;
      default:
        return AppStrings.errUnknown;
    }
  }
}

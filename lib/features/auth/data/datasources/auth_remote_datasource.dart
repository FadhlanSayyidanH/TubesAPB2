// Part of: Auth - Data

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Akses langsung ke Firebase Auth & Firestore. Hanya melempar Exception mentah;
/// penerjemahan ke Failure terjadi di repository.
abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String identifier, required String password});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);

  /// Tulis name (dan photoUrl bila ada) ke /users/{uid}, lalu kembalikan profil
  /// terbaru. [photoUrl] sudah berupa data URI base64 siap simpan.
  Future<UserModel> updateProfile({
    required String uid,
    required String name,
    String? photoUrl,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Stream<String?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._auth, this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// NIK = 16 digit angka. Apa pun selain itu diperlakukan sebagai email.
  bool _looksLikeNik(String value) => RegExp(r'^\d{16}$').hasMatch(value);

  @override
  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    // Login Firebase butuh email. Kalau user mengetik NIK, tukar dulu ke email
    // lewat lookup Firestore sebelum memanggil signInWithEmailAndPassword.
    final email = _looksLikeNik(identifier)
        ? await _resolveEmailFromNik(identifier)
        : identifier;

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      return _fetchProfile(uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  Future<String> _resolveEmailFromNik(String nik) async {
    final snapshot =
        await _users.where('nik', isEqualTo: nik).limit(1).get();
    if (snapshot.docs.isEmpty) throw const NikNotFoundException();
    final email = snapshot.docs.first.data()['email'] as String?;
    if (email == null || email.isEmpty) throw const NikNotFoundException();
    return email;
  }

  Future<UserModel> _fetchProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) throw const ProfileNotFoundException();
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _fetchProfile(firebaseUser.uid);
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    required String name,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{'name': name};
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    try {
      await _users.doc(uid).update(updates);
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
    return _fetchProfile(uid);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthException('user-not-found');
    }
    try {
      // Firebase menolak updatePassword tanpa login baru-baru ini; re-autentikasi
      // dengan kata sandi lama dulu agar tidak kena 'requires-recent-login'.
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  @override
  Stream<String?> get authStateChanges =>
      _auth.authStateChanges().map((user) => user?.uid);
}

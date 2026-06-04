// Part of: Core - Services

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Simpan **FCM token** ke `/users/{uid}.fcmToken` saat user login, supaya kelak
/// (setelah pindah Blaze + Cloud Functions, lihat CLAUDE.md §6) server bisa
/// mengirim push ke perangkat yang tepat. Untuk sekarang hanya menyimpan token.
///
/// Token bukan fitur kritikal: semua kegagalan ditelan diam-diam agar tidak
/// mengganggu alur login (mis. perangkat tanpa Google Play Services).
class PushTokenService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  PushTokenService(this._messaging, this._firestore);

  StreamSubscription<String>? _refreshSub;

  /// Ambil token sekarang lalu pantau perubahannya untuk uid ini.
  Future<void> registerFor(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _saveToken(uid, token);

      // FCM bisa merotasi token; ikuti perubahannya selama sesi berlangsung.
      await _refreshSub?.cancel();
      _refreshSub = _messaging.onTokenRefresh.listen((t) => _saveToken(uid, t));
    } catch (_) {
      // Abaikan: tanpa token, app tetap berfungsi penuh.
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fcmToken': token,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Abaikan kegagalan tulis Firestore (mis. offline).
    }
  }

  /// Hentikan pemantauan saat logout.
  Future<void> stop() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
  }
}

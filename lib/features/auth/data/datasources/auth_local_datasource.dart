// Part of: Auth - Data

import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan preferensi "Ingat saya" — HANYA identifier terakhir (email/NIK),
/// tidak pernah password. Dipakai untuk pre-fill form login.
abstract class AuthLocalDataSource {
  Future<void> saveRememberedIdentifier(String identifier);
  Future<void> clearRememberedIdentifier();
  String? getRememberedIdentifier();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _rememberedIdentifierKey = 'remembered_identifier';

  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveRememberedIdentifier(String identifier) =>
      _prefs.setString(_rememberedIdentifierKey, identifier);

  @override
  Future<void> clearRememberedIdentifier() =>
      _prefs.remove(_rememberedIdentifierKey);

  @override
  String? getRememberedIdentifier() =>
      _prefs.getString(_rememberedIdentifierKey);
}

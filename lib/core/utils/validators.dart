// Part of: Core - Utils

import '../constants/app_strings.dart';

/// Validator form. Mengembalikan pesan error (String) bila invalid, atau null
/// bila valid — sesuai kontrak TextFormField.validator.
class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$',
  );

  /// NIK KTP Indonesia: tepat 16 digit angka.
  static final RegExp _nikPattern = RegExp(r'^\d{16}$');

  static bool isEmail(String value) => _emailPattern.hasMatch(value.trim());

  static bool isNik(String value) => _nikPattern.hasMatch(value.trim());

  /// Field login menerima email ATAU NIK. Tolak kalau bukan keduanya supaya
  /// user tahu format yang diharapkan sebelum request ke server.
  static String? identifier(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return AppStrings.identifierRequired;
    if (!isEmail(input) && !isNik(input)) return AppStrings.identifierInvalid;
    return null;
  }

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return AppStrings.emailRequired;
    if (!isEmail(input)) return AppStrings.emailInvalid;
    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return AppStrings.passwordRequired;
    if (input.length < 6) return AppStrings.passwordTooShort;
    return null;
  }
}

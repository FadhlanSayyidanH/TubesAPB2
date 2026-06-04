// Part of: Core - Constants

import 'package:flutter/material.dart';

/// Palet warna tunggal untuk seluruh aplikasi. Jangan hardcode warna inline
/// di widget — selalu rujuk ke sini supaya rebranding cukup ubah satu file.
///
/// Warna brand & status sama di mode terang/gelap (const). Warna **struktural**
/// (latar, permukaan, teks, garis) punya varian Light/Dark eksplisit + getter
/// dinamis yang membaca [isDark]. Getter dinamis dipakai di widget; varian
/// eksplisit dipakai saat membangun ThemeData (lihat AppTheme) agar tetap const.
class AppColors {
  const AppColors._();

  /// Diset oleh pengaturan tema (lihat ThemeController) sebelum MaterialApp
  /// rebuild, sehingga getter di bawah mengembalikan warna mode yang aktif.
  static bool isDark = false;

  // Identitas brand (sama di kedua mode)
  static const Color deepNavy = Color(0xFF0D1B2A);
  static const Color safetyOrange = Color(0xFFF4500E);

  // Status semantik
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);

  // Status absensi (dipakai badge & chart)
  static const Color statusHadir = Color(0xFF43A047);
  static const Color statusTelat = Color(0xFFFB8C00);
  static const Color statusIzin = Color(0xFF1E88E5);
  static const Color statusAlpha = Color(0xFFE53935);

  // Indikator radius kantor
  static const Color insideRadius = Color(0xFF43A047);
  static const Color outsideRadius = Color(0xFFE53935);

  // Putih di atas permukaan gelap/brand (sama di kedua mode)
  static const Color textOnDark = Color(0xFFFFFFFF);

  // --- Warna struktural: varian eksplisit Light & Dark ---
  static const Color backgroundLight = Color(0xFFF5F6FA);
  static const Color backgroundDark = Color(0xFF0E1116);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1F26);
  static const Color cardShadowLight = Color(0x140D1B2A);
  static const Color cardShadowDark = Color(0x33000000);
  static const Color textPrimaryLight = Color(0xFF0D1B2A);
  static const Color textPrimaryDark = Color(0xFFE8EAED);
  static const Color textSecondaryLight = Color(0xFF5B6472);
  static const Color textSecondaryDark = Color(0xFFB0B6BF);
  static const Color textHintLight = Color(0xFF9AA1AC);
  static const Color textHintDark = Color(0xFF7A828D);
  static const Color dividerLight = Color(0xFFE3E6ED);
  static const Color dividerDark = Color(0xFF2A313A);
  static const Color inputFillLight = Color(0xFFF0F2F7);
  static const Color inputFillDark = Color(0xFF232932);

  // --- Getter dinamis (dipakai di widget) ---
  static Color get background => isDark ? backgroundDark : backgroundLight;
  static Color get surface => isDark ? surfaceDark : surfaceLight;
  static Color get cardShadow => isDark ? cardShadowDark : cardShadowLight;
  static Color get textPrimary => isDark ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary =>
      isDark ? textSecondaryDark : textSecondaryLight;
  static Color get textHint => isDark ? textHintDark : textHintLight;
  static Color get divider => isDark ? dividerDark : dividerLight;
  static Color get inputFill => isDark ? inputFillDark : inputFillLight;
}

// Part of: Core - Constants

/// Bahasa aktif aplikasi. Pola kembar dengan [AppColors.isDark]: flag global
/// statis yang diset [SettingsCubit] sebelum MaterialApp rebuild, sehingga
/// getter di [AppStrings] mengembalikan teks bahasa yang aktif — termasuk saat
/// dipanggil di data layer (Failure/Exception/notifikasi) yang tak punya
/// BuildContext.
class AppLocale {
  const AppLocale._();

  /// false = Bahasa Indonesia (default), true = English.
  static bool isEnglish = false;

  /// Pilih teks sesuai bahasa aktif. Dipakai semua getter di [AppStrings].
  static String pick(String id, String en) => isEnglish ? en : id;
}

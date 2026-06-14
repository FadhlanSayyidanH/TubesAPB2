// Part of: Core - Constants

/// Konfigurasi runtime tingkat aplikasi.
class AppConfig {
  const AppConfig._();

  /// Tampilkan peta OpenStreetMap di halaman clock-in.
  /// OSM tidak memerlukan API key atau billing — selalu aktif.
  static const bool mapsEnabled = true;

  /// Ambang keterlambatan: clock-in setelah jam ini berstatus "telat".
  static const int lateThresholdHour = 8;
  static const int lateThresholdMinute = 30;

  /// Jam pengingat harian (WIB). Masuk pagi 08:00, pulang sore 17:00.
  static const int clockInReminderHour = 8;
  static const int clockOutReminderHour = 17;

  /// Jumlah kartu riwayat yang ditampilkan per "halaman". Riwayat di-load sekali
  /// dari Firestore lalu dirender bertahap (lazy) sebanyak ini tiap kali user
  /// menggulir mendekati bawah — meringankan build widget saat data sudah banyak.
  static const int historyPageSize = 15;

  // --- Ambang kualitas selfie verifikasi wajah (Hari 6) ---

  /// Variance Laplacian minimum agar foto dianggap cukup tajam (tidak buram).
  /// Di bawah ini → tolak dengan pesan "buram".
  static const double faceBlurMinVariance = 100;

  /// Rentang rata-rata luma (0–255) yang dianggap pencahayaan layak.
  /// Di luar rentang → tolak dengan pesan gelap/silau.
  static const double faceBrightnessMin = 50;
  static const double faceBrightnessMax = 220;
}

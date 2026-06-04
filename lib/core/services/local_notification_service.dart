// Part of: Core - Services

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_config.dart';
import '../constants/app_strings.dart';

/// Notifikasi lokal tanpa server (project masih Spark — push terjadwal dari
/// Cloud Functions butuh Blaze, lihat CLAUDE.md §6). Menangani: konfirmasi
/// sukses absen masuk, pengingat absen masuk pagi (08:00), dan pengingat absen
/// pulang sore (17:00).
///
/// Timezone dipatok **Asia/Jakarta (WIB)** karena seluruh pengguna berada di
/// Indonesia bagian barat — menghindari dependensi deteksi timezone perangkat.
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationService(this._plugin);

  // Id notifikasi dibuat tetap agar reminder bisa dijadwal ulang/dibatalkan,
  // dan notifikasi sukses absen tidak menumpuk.
  static const int _dailyReminderId = 1001;
  static const int _clockOutReminderId = 1002;
  static const int _clockInSuccessId = 2001;

  static const String _successChannelId = 'attendance_success';
  static const String _successChannelName = 'Konfirmasi Absen';
  static const String _reminderChannelId = 'attendance_reminder';
  static const String _reminderChannelName = 'Pengingat Absen';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _successChannelId,
        _successChannelName,
        description: 'Notifikasi saat absen masuk berhasil disimpan.',
        importance: Importance.high,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _reminderChannelId,
        _reminderChannelName,
        description: 'Pengingat harian untuk melakukan absen masuk.',
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  /// Minta izin notifikasi (Android 13+). Di bawah Android 13 izin runtime tidak
  /// diperlukan sehingga dianggap diizinkan.
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<void> showClockInSuccess(String time) {
    return _plugin.show(
      _clockInSuccessId,
      AppStrings.notifClockInTitle,
      AppStrings.notifClockInBody(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _successChannelId,
          _successChannelName,
          channelDescription: 'Notifikasi saat absen masuk berhasil disimpan.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Jadwalkan pengingat absen masuk tiap hari pukul 08:00 WIB (berulang harian).
  /// Pakai mode inexact agar tidak perlu izin SCHEDULE_EXACT_ALARM — pengingat
  /// boleh meleset beberapa menit, cukup untuk kasus ini.
  Future<void> scheduleDailyClockInReminder() {
    return _scheduleDailyReminder(
      id: _dailyReminderId,
      hour: AppConfig.clockInReminderHour,
      title: AppStrings.notifReminderTitle,
      body: AppStrings.notifReminderBody,
    );
  }

  /// Jadwalkan pengingat absen pulang tiap hari pukul 17:00 WIB (berulang).
  Future<void> scheduleDailyClockOutReminder() {
    return _scheduleDailyReminder(
      id: _clockOutReminderId,
      hour: AppConfig.clockOutReminderHour,
      title: AppStrings.notifClockOutReminderTitle,
      body: AppStrings.notifClockOutReminderBody,
    );
  }

  /// Batalkan kedua pengingat harian (dipanggil saat logout / sesi admin).
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
    await _plugin.cancel(_clockOutReminderId);
  }

  Future<void> _scheduleDailyReminder({
    required int id,
    required int hour,
    required String title,
    required String body,
  }) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextDailyTime(hour),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          _reminderChannelName,
          channelDescription: 'Pengingat harian terkait absensi.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// TZDateTime berikutnya pada [hour]:00 WIB — hari ini bila belum lewat, kalau
  /// sudah lewat maka besok.
  tz.TZDateTime _nextDailyTime(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

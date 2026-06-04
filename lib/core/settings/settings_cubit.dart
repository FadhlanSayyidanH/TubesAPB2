// Part of: Core - Settings

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_locale.dart';

/// Preferensi aplikasi yang persist lintas sesi (tema gelap + bahasa).
/// Disediakan di atas MaterialApp agar perubahan langsung merebuild seluruh UI.
class AppSettings extends Equatable {
  final ThemeMode themeMode;
  final bool isEnglish;

  const AppSettings({this.themeMode = ThemeMode.light, this.isEnglish = false});

  bool get isDark => themeMode == ThemeMode.dark;

  /// Locale Material/Cupertino aktif (untuk date picker dll mengikuti bahasa).
  Locale get locale => isEnglish ? const Locale('en') : const Locale('id');

  AppSettings copyWith({ThemeMode? themeMode, bool? isEnglish}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        isEnglish: isEnglish ?? this.isEnglish,
      );

  @override
  List<Object?> get props => [themeMode, isEnglish];
}

class SettingsCubit extends Cubit<AppSettings> {
  final SharedPreferences _prefs;

  static const String _kDarkMode = 'settings_dark_mode';
  static const String _kEnglish = 'settings_english';

  SettingsCubit(this._prefs) : super(_initial(_prefs));

  // Set flag global AppColors/AppLocale lebih dulu agar getter warna & teks
  // konsisten sejak build pertama, lalu kembalikan state awal dari preferensi.
  static AppSettings _initial(SharedPreferences prefs) {
    final dark = prefs.getBool(_kDarkMode) ?? false;
    final english = prefs.getBool(_kEnglish) ?? false;
    AppColors.isDark = dark;
    AppLocale.isEnglish = english;
    return AppSettings(
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      isEnglish: english,
    );
  }

  Future<void> setDarkMode(bool dark) async {
    if (dark == state.isDark) return;
    AppColors.isDark = dark;
    await _prefs.setBool(_kDarkMode, dark);
    emit(state.copyWith(themeMode: dark ? ThemeMode.dark : ThemeMode.light));
  }

  void toggleDarkMode() => setDarkMode(!state.isDark);

  Future<void> setEnglish(bool english) async {
    if (english == state.isEnglish) return;
    AppLocale.isEnglish = english;
    await _prefs.setBool(_kEnglish, english);
    emit(state.copyWith(isEnglish: english));
  }

  void toggleEnglish() => setEnglish(!state.isEnglish);
}

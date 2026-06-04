// Part of: Core - Utils
//
// Format tanggal tanpa perlu inisialisasi locale `intl`
// (`initializeDateFormatting`), supaya ringan dan tidak gampang lupa setup.
// Bilingual: ikut bahasa aktif via [AppLocale] (ID default, EN bila aktif).

import '../constants/app_locale.dart';

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _bulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const _day = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _month = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Contoh: "Senin, 3 Juni 2026" (ID) / "Monday, June 3, 2026" (EN).
String formatTanggalLengkap(DateTime d) {
  if (AppLocale.isEnglish) {
    return '${_day[d.weekday - 1]}, ${_month[d.month - 1]} ${d.day}, ${d.year}';
  }
  return '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]} ${d.year}';
}

const _hariSingkat = ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'];
const _daySingkat = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

/// Label dua huruf untuk sumbu grafik. Contoh: Senin → "Sn" / Monday → "Mo".
String hariSingkat(DateTime d) =>
    (AppLocale.isEnglish ? _daySingkat : _hariSingkat)[d.weekday - 1];

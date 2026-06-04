// Part of: Core - Constants

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Skala tipografi berbasis Poppins. Widget merujuk style dari sini, bukan
/// menulis TextStyle inline, supaya ukuran/berat font konsisten lintas layar.
class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get _base => GoogleFonts.poppins(color: AppColors.textPrimary);

  static TextStyle get displayLarge =>
      _base.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get headline =>
      _base.copyWith(fontSize: 22, fontWeight: FontWeight.w600, height: 1.25);

  static TextStyle get title =>
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600);

  static TextStyle get body =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4);

  static TextStyle get bodyBold =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

  static TextStyle get subtitle =>
      _base.copyWith(fontSize: 13, color: AppColors.textSecondary, height: 1.4);

  static TextStyle get caption =>
      _base.copyWith(fontSize: 12, color: AppColors.textHint);

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnDark,
      );
}

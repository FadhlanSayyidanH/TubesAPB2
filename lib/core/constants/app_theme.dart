// Part of: Core - Constants

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// ThemeData terpusat. Deep Navy sebagai primary, Safety Orange sebagai aksi.
/// Tersedia varian [light] & [dark]; MaterialApp memilih lewat themeMode.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(dark: false);
  static ThemeData get dark => _build(dark: true);

  static ThemeData _build({required bool dark}) {
    final surface = dark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final background =
        dark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final onSurface =
        dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final inputFill = dark ? AppColors.inputFillDark : AppColors.inputFillLight;
    final divider = dark ? AppColors.dividerDark : AppColors.dividerLight;
    final cardShadow =
        dark ? AppColors.cardShadowDark : AppColors.cardShadowLight;
    final textHint = dark ? AppColors.textHintDark : AppColors.textHintLight;
    final textSecondary =
        dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // AppBar tetap Deep Navy di mode terang; di mode gelap memakai permukaan
    // gelap agar tidak terlalu kontras.
    final appBarBg = dark ? surface : AppColors.deepNavy;

    final colorScheme = ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: AppColors.deepNavy,
      onPrimary: AppColors.textOnDark,
      secondary: AppColors.safetyOrange,
      onSecondary: AppColors.textOnDark,
      surface: surface,
      onSurface: onSurface,
      error: AppColors.error,
      onError: AppColors.textOnDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineMedium: AppTextStyles.headline,
        titleMedium: AppTextStyles.title,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.subtitle,
        labelSmall: AppTextStyles.caption,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: AppColors.textOnDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title.copyWith(color: AppColors.textOnDark),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: cardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        hintStyle: AppTextStyles.body.copyWith(color: textHint),
        labelStyle: AppTextStyles.body.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.safetyOrange, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.safetyOrange,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor: AppColors.safetyOrange.withValues(alpha: 0.5),
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.safetyOrange),
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

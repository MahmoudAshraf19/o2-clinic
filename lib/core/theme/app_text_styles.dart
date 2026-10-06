import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Base text theme for the app
  static const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.black,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.black,
      height: 1.2,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.black,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.grey,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
      height: 1.2,
    ),
  );

  // Alternative text styles for different fonts
  static const TextTheme interTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.black,
      height: 1.2,
      fontFamily: AppFonts.inter,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
      height: 1.3,
      fontFamily: AppFonts.inter,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.black,
      height: 1.5,
      fontFamily: AppFonts.inter,
    ),
  );

  static const TextTheme poppinsTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.black,
      height: 1.2,
      fontFamily: AppFonts.poppins,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
      height: 1.3,
      fontFamily: AppFonts.poppins,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.black,
      height: 1.5,
      fontFamily: AppFonts.poppins,
    ),
  );

  // Decorative font styles
  static const TextStyle decorativeTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
    height: 1.1,
    fontFamily: AppFonts.greatVibes,
  );

  static const TextStyle signatureTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
    height: 1.1,
    fontFamily: AppFonts.broetownSignature,
  );

  static const TextStyle dancingScriptStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    height: 1.2,
    fontFamily: AppFonts.dancingScript,
  );

  static const TextStyle dancingScriptTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.1,
    fontFamily: AppFonts.dancingScript,
  );
}

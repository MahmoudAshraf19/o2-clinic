import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- New Brand Colors ---
  static const Color brandBlue = Color(0xFF03458F);
  static const Color vibrantCyan = Color(0xFF01D1D1);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softCyan = Color(0xFF90EAEA);

  // Main brand colors
  static const Color primary = brandBlue;
  static const Color secondary = vibrantCyan;
  static const Color tertiary = softCyan;
  static const Color info = Color(0xFF7EBCE6);
  static const Color accent = Color(0xFF8980F5);

  // Neutral colors
  static const Color white = pureWhite;
  static const Color black = Color(0xFF111111);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFF3F4F6);

  // Background colors
  static const Color scaffoldLight = Color(0xFFF4F9F8);
  static const Color scaffoldDark = Color(0xFF0F1A19);
  
  static const Color backgroundLight = scaffoldLight;
  static const Color backgroundDark = scaffoldDark;
  static const Color scaffoldBackground = scaffoldLight;
  static const Color cardBackground = pureWhite;
  static const Color homeBackground = scaffoldLight;
  static const Color surfaceContainer = Color(0xFFF1F4F3);
  static const Color surfaceContainerLow = Color(0xFFF1F4F3);

  // Border and divider colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEAECEF);

  // Additional colors
  static const Color surface = pureWhite;
  static const Color background = scaffoldLight;
  static const Color textPrimary = Color(0xFF181D1C);
  static const Color textSecondary = Color(0xFF3E4947);
  static const Color outline = Color(0xFF6E7977);
  static const Color outlineVariant = Color(0xFFBDC9C6);

  // State colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color error = Color(0xFFDC2626);

  // Shadow colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Additional grey shades
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Additional brand variations
  static const Color primaryLight = Color(0xFF4A89DC);
  static const Color primaryDark = Color(0xFF022E60);
  static const Color secondaryLight = Color(0xFF4EE8E8);
  static const Color secondaryDark = Color(0xFF009999);

  // Disabled states
  static const Color disabled = Color(0xFF9CA3AF);
  static const Color disabledBackground = Color(0xFFF3F4F6);

  // Interactive states
  static const Color hover = Color(0xFFF3F4F6);
  static const Color pressed = Color(0xFFE5E7EB);
  static const Color focused = Color(0xFFDBEAFE);
  static const Color selected = Color(0xFFDCFCE7);

  static const surfaceLowest = pureWhite;
  static const surfaceLow = Color(0xffF1F4F2);
  static const surfaceHigh = Color(0xffE6E9E7);
  static const surfaceHighest = Color(0xffE0E3E1);
  static const surfaceVariant = Color(0xffE0E3E1);

  static const primaryContainer = Color(0xFF023875);
  static const onPrimary = pureWhite;

  static const onSurface = Color(0xff181C1C);
  static const onSurfaceVariant = Color(0xff3E4947);

  static const errorContainer = Color(0xffFFDAD6);

  static const Color primarySoft = Color(0xFFE6F0FA);

  static const Color muted = Color(0xFF7B8784);

  static const Color surfaceAlt = Color(0xFFF2F5F4);
  static const Color surfaceSoft = Color(0xFFEFF4F2);

  static const Color borderSoft = Color(0xFFDDE5E2);
  static const Color shadowSoft = Color(0x12000000);

  static const Color toggleTrack = Color(0xFFDDE5E2);
  static const Color toggleThumb = pureWhite;

  static const Color secondaryContainer = Color(0xFF9DF5F5);
  static const Color tertiaryContainer = Color(0xFF023875);

  static const Color surfaceBright = Color(0xFFF7FAF8);
  static const Color surfaceContainerLowest = pureWhite;
  static const Color surfaceContainerHigh = Color(0xFFE6E9E7);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E1);
  static const Color surfaceDim = Color(0xFFD7DBD9);

  static const Color onBackground = Color(0xFF181C1C);
  static const Color onPrimaryContainer = Color(0xFF99C2FF);
  static const Color onSecondary = pureWhite;
  static const Color onSecondaryContainer = Color(0xFF006666);
  static const Color onTertiary = pureWhite;
  static const Color onTertiaryContainer = Color(0xFF7FE7D8);

  static const Color primaryFixed = Color(0xFFA1C9F1);
  static const Color primaryFixedDim = Color(0xFF85B6D5);
  static const Color onPrimaryFixed = Color(0xFF001220);
  static const Color onPrimaryFixedVariant = Color(0xFF002E50);

  static const Color secondaryFixed = Color(0xFF96F3E6);
  static const Color secondaryFixedDim = Color(0xFF79D7CA);
  static const Color onSecondaryFixed = Color(0xFF00201D);
  static const Color onSecondaryFixedVariant = Color(0xFF005049);

  static const Color tertiaryFixed = Color(0xFF8CF5E6);
  static const Color tertiaryFixedDim = Color(0xFF6FD8CA);
  static const Color onTertiaryFixed = Color(0xFF00201C);
  static const Color onTertiaryFixedVariant = Color(0xFF005049);

  static const Color inverseSurface = Color(0xFF2D3130);
  static const Color inverseOnSurface = Color(0xFFEEF1EF);
  static const Color inversePrimary = Color(0xFF85B6D5);

  static const Color chatUserBubble = brandBlue;
  static const Color chatAgentBubble = Color(0xFFE6E9E7);
  static const Color chatDivider = Color(0xFFE0E3E1);
  static const Color chatInputBorder = Color(0xFFBEC9C6);
  static const Color chatInputBg = pureWhite;
  static const Color chatTypingDot = Color(0xFFBEC9C6);

  static const Color onError = pureWhite;
  static const Color onErrorContainer = Color(0xFF93000A);
}

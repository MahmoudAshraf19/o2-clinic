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

  // --- Auto-generated colors ---
  static const Color amber = Colors.amber;
  static const Color black12 = Colors.black12;
  static const Color black26 = Colors.black26;
  static const Color black45 = Colors.black45;
  static const Color black54 = Colors.black54;
  static const Color black87 = Colors.black87;
  static const Color blue = Colors.blue;
  static const Color green = Colors.green;
  static const Color greenAccent = Colors.greenAccent;
  static const Color orange = Colors.orange;
  static const Color orangeAccent = Colors.orangeAccent;
  static const Color purple = Colors.purple;
  static const Color red = Colors.red;
  static const Color redAccent = Colors.redAccent;
  static const Color transparent = Colors.transparent;
  static const Color white12 = Colors.white12;
  static const Color white24 = Colors.white24;
  static const Color white38 = Colors.white38;
  static const Color white54 = Colors.white54;
  static const Color white60 = Colors.white60;
  static const Color white70 = Colors.white70;
  static const Color color11000000 = Color(0x11000000);
  static const Color color33BDC9C6 = Color(0x33BDC9C6);
  static const Color color66000000 = Color(0x66000000);
  static const Color color88000000 = Color(0x88000000);
  static const Color color99000000 = Color(0x99000000);
  static const Color colorAA000000 = Color(0xAA000000);
  static const Color colorB3FFFFFF = Color(0xB3FFFFFF);
  static const Color colorCC000000 = Color(0xCC000000);
  static const Color colorCCFFFFFF = Color(0xCCFFFFFF);
  static const Color colorDD000000 = Color(0xDD000000);
  static const Color colorE6000000 = Color(0xE6000000);
  static const Color colorE6FFFFFF = Color(0xE6FFFFFF);
  static const Color colorFF00685F = Color(0xFF00685F);
  static const Color colorFF006860 = Color(0xFF006860);
  static const Color colorFF006A61 = Color(0xFF006A61);
  static const Color colorFF007167 = Color(0xFF007167);
  static const Color colorFF008379 = Color(0xFF008379);
  static const Color colorFF081F1D = Color(0xFF081F1D);
  static const Color colorFF0F172A = Color(0xFF0F172A);
  static const Color colorFF0F5A51 = Color(0xFF0F5A51);
  static const Color colorFF0F766E = Color(0xFF0F766E);
  static const Color colorFF13364A = Color(0xFF13364A);
  static const Color colorFF134E4A = Color(0xFF134E4A);
  static const Color colorFF158278 = Color(0xFF158278);
  static const Color colorFF1A2020 = Color(0xFF1A2020);
  static const Color colorFF1A2625 = Color(0xFF1A2625);
  static const Color colorFF1E1E1E = Color(0xFF1E1E1E);
  static const Color colorFF1E293B = Color(0xFF1E293B);
  static const Color colorFF1E2A29 = Color(0xFF1E2A29);
  static const Color colorFF1E877B = Color(0xFF1E877B);
  static const Color colorFF21897E = Color(0xFF21897E);
  static const Color colorFF2A3A39 = Color(0xFF2A3A39);
  static const Color colorFF2D3737 = Color(0xFF2D3737);
  static const Color colorFF333333 = Color(0xFF333333);
  static const Color colorFF334155 = Color(0xFF334155);
  static const Color colorFF3BA99C = Color(0xFF3BA99C);
  static const Color colorFF546868 = Color(0xFF546868);
  static const Color colorFF60A5FA = Color(0xFF60A5FA);
  static const Color colorFF64748B = Color(0xFF64748B);
  static const Color colorFF69D1C5 = Color(0xFF69D1C5);
  static const Color colorFF8DF4E8 = Color(0xFF8DF4E8);
  static const Color colorFFB71C1C = Color(0xFFB71C1C);
  static const Color colorFFDFE3E1 = Color(0xFFDFE3E1);
  static const Color colorFFE53E3E = Color(0xFFE53E3E);
  static const Color colorFFE5E9E7 = Color(0xFFE5E9E7);
  static const Color colorFFE6E9E8 = Color(0xFFE6E9E8);
  static const Color colorFFE6ECEC = Color(0xFFE6ECEC);
  static const Color colorFFE8F0EC = Color(0xFFE8F0EC);
  static const Color colorFFEAF8F6 = Color(0xFFEAF8F6);
  static const Color colorFFEAF9F7 = Color(0xFFEAF9F7);
  static const Color colorFFEF4444 = Color(0xFFEF4444);
  static const Color colorFFF0F4F2 = Color(0xFFF0F4F2);
  static const Color colorFFF0FAF9 = Color(0xFFF0FAF9);
  static const Color colorFFF1F4FA = Color(0xFFF1F4FA);
  static const Color colorFFF2F7F6 = Color(0xFFF2F7F6);
  static const Color colorFFF3F8F7 = Color(0xFFF3F8F7);
  static const Color colorFFF4F7F9 = Color(0xFFF4F7F9);
  static const Color colorFFF4F7FC = Color(0xFFF4F7FC);
  static const Color colorFFF4F8F7 = Color(0xFFF4F8F7);
  static const Color colorFFF4FFFC = Color(0xFFF4FFFC);
  static const Color colorFFF6FAF8 = Color(0xFFF6FAF8);
  static const Color colorFFF7FAFA = Color(0xFFF7FAFA);
  static const Color colorFFF8FAFA = Color(0xFFF8FAFA);
  static const Color colorFFF9F6F0 = Color(0xFFF9F6F0);
  static const Color colorFFF9FBFF = Color(0xFFF9FBFF);
  static const Color colorFFFF4B4B = Color(0xFFFF4B4B);
  static const Color colorFFFFDAD6 = Color(0xFFFFDAD6);

  // Missing shade colors
  static const Color green50 = Color(0xFFE8F5E9);
  static const Color green700 = Color(0xFF388E3C);
  static const Color red50 = Color(0xFFFFEBEE);
  static const Color red300 = Color(0xFFE57373);
  static const Color red400 = Color(0xFFEF5350);
  static const Color red700 = Color(0xFFD32F2F);
  static const Color orange50 = Color(0xFFFFF3E0);
  static const Color orange700 = Color(0xFFF57C00);
  static const Color orange800 = Color(0xFFEF6C00);
}

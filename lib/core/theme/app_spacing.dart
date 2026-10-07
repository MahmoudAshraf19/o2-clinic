import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Core Spacing Tokens (8pt Grid System)
  static const double xs2 = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Common EdgeInsets
  static const EdgeInsets pagePadding = EdgeInsets.all(md);
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  // Specific EdgeInsets
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 12.0,
  );
}

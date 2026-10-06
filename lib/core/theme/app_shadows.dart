import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // Soft, generic shadow for cards
  static final List<BoxShadow> primary = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Lighter shadow for smaller elements like buttons or chips
  static final List<BoxShadow> light = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Heavy shadow for dialogs and bottom sheets
  static final List<BoxShadow> heavy = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Shadow for floating action buttons or prominent actions
  static final List<BoxShadow> floating = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
}

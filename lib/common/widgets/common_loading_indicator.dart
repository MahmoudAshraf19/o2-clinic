import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A unified Loading Indicator widget to be used across the entire application.
/// 
/// **Purpose:**
/// Replaces the default [CircularProgressIndicator] to ensure consistent sizing,
/// colors, and stroke width throughout the app. If the design team decides to 
/// change the loading animation (e.g., to a Lottie animation) in the future, 
/// it can be done here in one single place.
/// 
/// **Usage Example:**
/// ```dart
/// return CommonLoadingIndicator();
/// ```
class CommonLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final double? value;

  const CommonLoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 4.0,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          value: value,
          color: color ?? AppColors.primary,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

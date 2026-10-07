import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';

/// A utility class for displaying unified Snackbars (Toasts) across the app.
/// 
/// **Purpose:**
/// Provides a consistent way to show Success, Error, and Warning messages to the user.
/// It standardizes the padding, background color, border radius, and icons of the snackbars.
/// This prevents developers from writing inline ScaffoldMessenger calls with mismatched designs.
/// 
/// **Usage Example:**
/// ```dart
/// // For a success message:
/// CommonSnackbar.showSuccess(title: 'Success', message: 'Profile updated successfully!');
/// 
/// // For an error message:
/// CommonSnackbar.showError(title: 'Error', message: 'Failed to connect to the server.');
/// 
/// // For a warning message:
/// CommonSnackbar.showWarning(title: 'Warning', message: 'Please complete your profile.');
/// ```
class CommonSnackbar {
  static void showSuccess({String title = 'Success', required String message}) {
    _showSnackbar(title, message, AppColors.primary, Icons.check_circle_outline);
  }

  static void showError({String title = 'Error', required String message}) {
    _showSnackbar(title, message, AppColors.red400, Icons.error_outline);
  }

  static void showWarning({String title = 'Warning', required String message}) {
    _showSnackbar(title, message, Colors.orange, Icons.warning_amber_rounded);
  }

  static void _showSnackbar(String title, String message, Color bgColor, IconData icon) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    
    Get.snackbar(
      title,
      message,
      backgroundColor: bgColor,
      colorText: AppColors.white,
      icon: Icon(icon, color: AppColors.white),
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'common_button.dart';

/// A utility class containing unified Dialogs (Pop-ups) for the application.
/// 
/// **Purpose:**
/// Centralizes the creation of AlertDialogs to ensure consistent styling (border radius, 
/// button colors, title typography). This prevents developers from rewriting dialog
/// styles repeatedly and maintains a unified user experience.
/// 
/// **Usage Example:**
/// ```dart
/// final confirmed = await CommonDialogs.showConfirmationDialog(
///   context,
///   title: 'Logout',
///   message: 'Are you sure you want to log out?',
///   confirmText: 'Logout',
///   isDestructive: true,
/// );
/// if (confirmed == true) {
///   // Perform logout
/// }
/// ```
class CommonDialogs {
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: const TextStyle(color: AppColors.grey500),
              ),
            ),
            CommonButton(
              onPressed: () => Navigator.of(context).pop(true),
              text: confirmText,
              type: CommonButtonType.primary,
              backgroundColor: isDestructive ? AppColors.red400 : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        );
      },
    );
  }

  /// Displays a customized Dialog with consistent shape and styling.
  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        );
      },
    );
  }

  /// Displays a customizable Bottom Sheet with a drag handle and consistent styling.
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isScrollControlled = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        );
      },
    );
  }
}

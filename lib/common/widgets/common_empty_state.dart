import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'common_button.dart';

/// A standard widget to display when a screen or list has no data.
/// 
/// **Purpose:**
/// To provide a consistent "Empty State" UI (Icon, Title, Subtitle, and an optional 
/// Retry Button) across all lists, searches, and screens when data is missing or empty.
/// 
/// **Usage Example:**
/// ```dart
/// if (items.isEmpty) {
///   return CommonEmptyState(
///     title: 'No appointments found',
///     subtitle: 'You have no upcoming appointments at the moment.',
///     icon: Icons.calendar_today_outlined,
///     onRetry: () => fetchData(),
///     retryText: 'Refresh',
///   );
/// }
/// ```
class CommonEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryText;

  const CommonEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CommonButton(
                onPressed: onRetry!,
                text: retryText ?? 'Retry',
                type: CommonButtonType.primary,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

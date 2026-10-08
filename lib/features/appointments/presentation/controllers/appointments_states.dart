import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/common/widgets/common_button.dart';
import 'package:o2_clinic/core/routes/app_routes.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'booking_helper.dart';

/// Shared layout for full-screen informational states.
class _StateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final Widget? action;

  const _StateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? AppColors.scaffoldDark 
              : AppColors.grey200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: iconColor),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, 
              height: 1.4, 
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.white54 : AppColors.grey600,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    );
  }
}

/// Empty list. Differentiates "no bookings yet" from "filters hide everything".
class AppointmentsEmptyState extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  const AppointmentsEmptyState({
    super.key,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = BookingHelper.isArabic(context);

    if (hasActiveFilters) {
      return _StateCard(
        icon: Icons.search_off_rounded,
        iconColor: AppColors.primary,
        title: l10n.noAppointmentsFound,
        message: l10n.tryChangingTheFilterOr,
        action: CommonButton(
          onPressed: onClearFilters,
          text: l10n.clearFilters,
          type: CommonButtonType.outline,
          borderColor: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return _StateCard(
      icon: Icons.event_available_rounded,
      iconColor: AppColors.primary,
      title: l10n.noAppointmentsYetTitle,
      message: l10n.noAppointmentsYetDesc,
    );
  }
}

class AppointmentsErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const AppointmentsErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isAr = BookingHelper.isArabic(context);

    return _StateCard(
      icon: Icons.cloud_off_rounded,
      iconColor: AppColors.red,
      title: l10n.somethingWentWrongTitle,
      message: l10n.couldNotLoadAppointmentsDesc,
      action: CommonButton(
        onPressed: onRetry,
        text: l10n.tryAgainBtn,
        type: CommonButtonType.primary,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        height: 50,
        borderRadius: BorderRadius.circular(16),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AppointmentsLoginRequired extends StatelessWidget {
  const AppointmentsLoginRequired({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = BookingHelper.isArabic(context);

    return _StateCard(
      icon: Icons.lock_outline_rounded,
      iconColor: AppColors.primary,
      title: l10n.signInToContinue,
      message: l10n.pleaseLoginOrCreateAn,
      action: CommonButton(
        onPressed: () => Get.toNamed(AppRoutes.login),
        text: l10n.loginBtn,
        type: CommonButtonType.primary,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        height: 54,
        borderRadius: BorderRadius.circular(16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isAr; // Kept for backward compatibility but unused for labels now

  const StatusBadge({super.key, required this.status, required this.isAr});

  static String labelOf(BuildContext context, String status) =>
      _styleOf(context, status).label;

  static _StatusStyle _styleOf(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'completed':
        return _StatusStyle(
          bg: AppColors.green50,
          fg: AppColors.green700,
          icon: Icons.check_circle_rounded,
          label: l10n.completedStatus,
        );
      case 'cancelled':
        return _StatusStyle(
          bg: AppColors.red50,
          fg: AppColors.red700,
          icon: Icons.cancel_rounded,
          label: l10n.cancelledStatus,
        );
      case 'pending':
      case 'pending_price':
        return _StatusStyle(
          bg: AppColors.orange50,
          fg: AppColors.orange700,
          icon: Icons.hourglass_top_rounded,
          label: l10n.pending,
        );
      case 'under_investigation':
        return _StatusStyle(
          bg: AppColors.orange50,
          fg: AppColors.orange700,
          icon: Icons.manage_search_rounded,
          label: l10n.underReviewStatus,
        );
      case 'no_show':
        return _StatusStyle(
          bg: AppColors.grey100,
          fg: AppColors.grey600,
          icon: Icons.person_off_rounded,
          label: l10n.missedStatus,
        );
      default:
        return _StatusStyle(
          bg: AppColors.primary.withValues(alpha: 0.1),
          fg: AppColors.primary,
          icon: Icons.event_available_rounded,
          label: l10n.upcomingStatus,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleOf(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 12, color: style.fg),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: style.fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  final String label;

  const _StatusStyle({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.label,
  });
}

import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AvailabilityBar extends StatelessWidget {
  final int booked;
  final int total;

  const AvailabilityBar({super.key, required this.booked, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = booked / total;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.availability,
              style: AppTextStyles.textTheme.bodyMedium!.copyWith(fontSize: 12),
            ),
            Text(
              "$booked / $total Booked",
              style: AppTextStyles.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 7,
            backgroundColor: AppColors.surface,
            color: percent > 0.8
                ? AppColors.redAccent
                : percent > 0.5
                ? AppColors.primary
                : AppColors.accent,
          ),
        ),
      ],
    );
  }
}

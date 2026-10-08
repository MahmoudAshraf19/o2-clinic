import 'dart:ui';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:o2_clinic/common/widgets/common_avatar.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:o2_clinic/features/booking/utils/booking_helper.dart'; // NEW
import 'package:o2_clinic/common/models/fs_doctor_model.dart';
import 'availability_bar.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor.withValues(alpha: 0.75)
                : AppColors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.2),
                              AppColors.accent.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                      ),
                      CommonAvatar(size: 42 * 2, imageUrl: doctor.image,),
                    ],
                  ),
                  if (doctor.theTop)
                    _badge("Top Rated"),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                doctor.name(Get.locale?.languageCode ?? 'en'),
                style: AppTextStyles.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.textPrimary),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                doctor.title(Get.locale?.languageCode ?? 'en'),
                style: AppTextStyles.textTheme.bodyLarge!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppColors.accent, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "${doctor.ratingAverage.toDouble()}",
                    style: AppTextStyles.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "(${doctor.reviewsCount})",
                    style: AppTextStyles.textTheme.bodyMedium!.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '',
                    style: AppTextStyles.textTheme.bodyMedium!.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              AvailabilityBar(booked: 0, total: doctor.maxBooking),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: CommonButton(
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes.doctorProfile,
                            arguments: doctor,
                          );
                        },
                        text: AppLocalizations.of(context)!.fullProfile,
                        type: CommonButtonType.outline,
                        borderRadius: BorderRadius.circular(20),
                        textStyle: AppTextStyles.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.white70
                              : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: CommonButton(
                        onPressed: () {
                          BookingHelper.onBookNowClicked(context, doctor);
                        },
                        text: AppLocalizations.of(context)!.bookNow,
                        type: CommonButtonType.primary,
                        backgroundColor: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        elevation: 4,
                        textStyle: AppTextStyles.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.textTheme.bodyMedium!.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

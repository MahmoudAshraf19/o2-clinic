import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/booking_helper.dart'; // NEW
import '../models/doctor_model.dart';
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
            color: AppColors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, 15),
              )
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
                      CircleAvatar(
                        radius: 42,
                        backgroundImage: CachedNetworkImageProvider(doctor.image),
                      ),
                    ],
                  ),
                  if (doctor.isTopRated)
                    _badge("Top Rated")
                  else if (doctor.isMostBooked)
                    _badge("Most Booked"),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                doctor.name,
                style: AppTextStyles.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                doctor.title,
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
                    "${doctor.rating}",
                    style: AppTextStyles.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "(${doctor.reviews})",
                    style: AppTextStyles.textTheme.bodyMedium!
                        .copyWith(color: AppColors.outline),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    doctor.availability,
                    style: AppTextStyles.textTheme.bodyMedium!
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              AvailabilityBar(
                booked: doctor.booked,
                total: doctor.total,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes.doctorProfile,
                            arguments: doctor,
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.fullProfile,
                          style: AppTextStyles.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          BookingHelper.onBookNowClicked(context, doctor);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.bookNow,
                          style: AppTextStyles.textTheme.labelLarge,
                        ),
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

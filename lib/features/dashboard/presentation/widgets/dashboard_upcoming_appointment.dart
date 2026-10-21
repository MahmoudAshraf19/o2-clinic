import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import 'package:o2_clinic/features/booking/utils/booking_helper.dart';
import '../../../../common/controllers/app_constants_controller.dart';
import '../../../../common/models/fs_doctor_model.dart';
import '../controllers/dashboard_controller.dart';

class DashboardUpcomingAppointment extends StatelessWidget {
  const DashboardUpcomingAppointment({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      final doctors = controller.upcomingDoctors;

      if (doctors.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 18,
                color: (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.white
                    : AppColors.colorFF081F1D),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.upcomingDoctors,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.colorFF081F1D,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              for (int i = 0; i < doctors.length; i++) ...[
                _UpcomingDoctorCard(doctor: doctors[i]),
                if (i != doctors.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ],
      );
    });
  }
}

class _UpcomingDoctorCard extends StatelessWidget {
  const _UpcomingDoctorCard({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    final currentLang = Get.locale?.languageCode ?? 'ar';
    final isArabic = currentLang == 'ar';
    final localizedSpecialty = controller.getLocalizedSpecialty(
      doctor.specialty,
      currentLang,
    );

    final availabilityPreview = _buildAvailabilityPreview(
      doctor.availabilityDay,
    );

    return GestureDetector(
      onTap: () => BookingHelper.onBookNowClicked(context, doctor),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.onTertiaryFixedVariant],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.20),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_hospital_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.featuredDoctor,
                            style: const TextStyle(
                              color: AppColors.colorE6FFFFFF,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          doctor.theTop ? 'THE TOP' : 'FEATURED',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedImageWidget(
                          imageUrl: doctor.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person_rounded,
                              color: AppColors.white,
                              size: 30,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic && doctor.nameAr.isNotEmpty
                                  ? doctor.nameAr
                                  : doctor.nameEn,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isArabic && doctor.titleAr.isNotEmpty
                                  ? doctor.titleAr
                                  : doctor.titleEn,
                              style: const TextStyle(
                                color: AppColors.colorB3FFFFFF,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoChip(
                                  icon: Icons.local_hospital_rounded,
                                  text: localizedSpecialty.isNotEmpty
                                      ? localizedSpecialty
                                      : doctor.specialty,
                                ),
                                _InfoChip(
                                  icon: Icons.work_history_rounded,
                                  text:
                                      '${doctor.yearsExperience}+ ${AppLocalizations.of(context)!.years}',
                                ),
                                _InfoChip(
                                  icon: Icons.payments_rounded,
                                  text:
                                      '${doctor.price.toString()} ${Get.isRegistered<AppConstantsController>() ? Get.find<AppConstantsController>().currencySymbol.value : "EGP"}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (availabilityPreview.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final item in availabilityPreview)
                          _InfoChip(icon: Icons.schedule_rounded, text: item),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _buildAvailabilityPreview(Map<String, String> days) {
    if (days.isEmpty) return [];

    final entries = days.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries
        .take(2)
        .map((e) => '${_dayLabel(e.key)}: ${e.value}')
        .toList();
  }

  String _dayLabel(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Mon';
      case 'tuesday':
        return 'Tue';
      case 'wednesday':
        return 'Wed';
      case 'thursday':
        return 'Thu';
      case 'friday':
        return 'Fri';
      case 'saturday':
        return 'Sat';
      case 'sunday':
        return 'Sun';
      default:
        return day;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

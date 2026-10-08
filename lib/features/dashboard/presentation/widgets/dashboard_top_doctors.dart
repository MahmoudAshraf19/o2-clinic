import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/booking_helper.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/doctors/data/models/doctor_model.dart';
import '../controllers/dashboard_controller.dart';

class DashboardTopDoctors extends StatelessWidget {
  const DashboardTopDoctors({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      final doctors = controller.topDoctors;

      if (doctors.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.topDoctors,
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
                _DoctorCard(doctor: doctors[i]),
                if (i != doctors.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ],
      );
    });
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorFF0F766E.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _DoctorAvatar(imageUrl: doctor.image),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic && doctor.nameAr.isNotEmpty
                      ? doctor.nameAr
                      : doctor.nameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.white
                        : AppColors.colorFF081F1D,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isArabic && doctor.titleAr.isNotEmpty
                      ? doctor.titleAr
                      : doctor.titleEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.white70
                        : AppColors.grey500,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniInfoChip(
                      icon: Icons.workspace_premium_rounded,
                      text: doctor.specialty,
                    ),
                    _MiniInfoChip(
                      icon: Icons.timelapse_rounded,
                      text:
                          '${doctor.yearsExperience}+ ${AppLocalizations.of(context)!.years}',
                    ),
                    _MiniInfoChip(
                      icon: Icons.event_available_rounded,
                      text:
                          '${AppLocalizations.of(context)!.max} ${doctor.maxBooking}',
                    ),
                    // _MiniInfoChip(
                    //   icon: Icons.payments_rounded,
                    //   text: '${doctor.price.toString()} EGP',
                    // ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CommonButton(
            text: AppLocalizations.of(context)!.book,
            onPressed: () => BookingHelper.onBookNowClicked(context, doctor),
            type: CommonButtonType.primary,
            size: CommonButtonSize.medium,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
        ],
      ),
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.transparent
              : AppColors.colorFFF8FAFA,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.colorFF2A3A39
                : AppColors.colorFFF2F7F6,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedImageWidget(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/icons/user.png', fit: BoxFit.cover);
          },
        ),
      ),
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.colorFF2A3A39
            : AppColors.colorFFF3F8F7,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.white70
                    : AppColors.colorFF334155,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

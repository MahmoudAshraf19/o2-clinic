import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';

import '../../../chat_doctors/presentation/screens/patient_chat_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import 'package:o2_clinic/common/models/fs_doctor_model.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onViewProfile,
    required this.onBook,
    this.localizedSpecialty,
  });

  final DoctorModel doctor;
  final VoidCallback onViewProfile;
  final VoidCallback onBook;
  final String? localizedSpecialty;

  String _getDoctorName(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ar' && doctor.nameAr.isNotEmpty) return doctor.nameAr;
    if (lang == 'he' && doctor.nameHe.isNotEmpty) return doctor.nameHe;
    return doctor.nameEn;
  }

  String _getDoctorTitle(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ar' && doctor.titleAr.isNotEmpty) return doctor.titleAr;
    if (lang == 'he' && doctor.titleHe.isNotEmpty) return doctor.titleHe;
    return doctor.titleEn;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 96,
                height: 96,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.transparent
                    : AppColors.surfaceContainer,
                child: CachedImageWidget(
                  imageUrl: doctor.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.person, size: 44, color: AppColors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getDoctorName(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.white
                                    : AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDoctorTitle(context).isNotEmpty
                                  ? _getDoctorTitle(context)
                                  : (localizedSpecialty ?? doctor.specialty),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppFonts.inter,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.colorFF2A3A39
                          : AppColors.surfaceContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${doctor.yearsExperience} ${AppLocalizations.of(context)!.years}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.inter,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.white70
                            : AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          onPressed: onViewProfile,
                          text: AppLocalizations.of(context)!.viewProfile,
                          type: CommonButtonType.outline,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          borderRadius: BorderRadius.circular(999),
                          foregroundColor: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.white 
                              : AppColors.primary,
                          borderColor: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.white.withValues(alpha: 0.5) 
                              : AppColors.primary,
                          textStyle: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CommonButton(
                          onPressed: () {
                            Get.to(() => PatientChatScreen(doctor: doctor));
                          },
                          icon: Icons.chat_bubble_outline,
                          iconSize: 16,
                          text: AppLocalizations.of(context)!.chatMessage,
                          type: CommonButtonType.primary,
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          borderRadius: BorderRadius.circular(999),
                          elevation: 0,
                          textStyle: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

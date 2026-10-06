import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../chat_doctors/views/patient_chat_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../services_firestore/models/doctor_model.dart';
import '../../../doctors/models/doctor_model.dart' as ui_model;

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
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 96,
                height: 96,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : AppColors.surfaceContainer,
                child: CachedImageWidget(
                  imageUrl: doctor.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
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
                                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary),
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
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A3A39) : AppColors.surfaceContainer.withOpacity(0.45),
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
                        color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onViewProfile,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.viewProfile,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final uiDoctor = ui_model.DoctorModel(
                              id: doctor.id,
                              name: _getDoctorName(context),
                              title: _getDoctorTitle(context),
                              image: doctor.image,
                              rating: 5.0,
                              reviews: 0,
                              availability: 'Available',
                              booked: 0,
                              total: doctor.maxBooking,
                            );
                            Get.to(() => PatientChatScreen(doctor: uiDoctor));
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 16),
                          label: Text(
                            AppLocalizations.of(context)!.chatMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
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



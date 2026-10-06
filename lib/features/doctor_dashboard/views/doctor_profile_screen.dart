import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/doctor_profile_controller.dart';
import 'doctor_edit_profile_screen.dart';

class DoctorProfileScreen extends GetView<DoctorProfileController> {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctor = controller.doctor.value;
          if (doctor == null) {
            return const Center(child: Text('Profile not found'));
          }

          final isArabic = Localizations.localeOf(context).languageCode == 'ar';

          String doctorName;
          if (isArabic && doctor.nameAr.trim().isNotEmpty) {
            doctorName = doctor.nameAr;
          } else if (!isArabic && doctor.nameEn.trim().isNotEmpty) {
            doctorName = doctor.nameEn;
          } else {
            doctorName = doctor.nameAr.trim().isNotEmpty
                ? doctor.nameAr
                : doctor.nameEn;
          }

          String doctorTitle;
          if (isArabic && doctor.titleAr.trim().isNotEmpty) {
            doctorTitle = doctor.titleAr;
          } else if (!isArabic && doctor.titleEn.trim().isNotEmpty) {
            doctorTitle = doctor.titleEn;
          } else {
            doctorTitle = doctor.titleAr.trim().isNotEmpty
                ? doctor.titleAr
                : doctor.titleEn;
          }

          String doctorAbout;
          if (isArabic && doctor.descriptionAr.trim().isNotEmpty) {
            doctorAbout = doctor.descriptionAr;
          } else if (!isArabic && doctor.descriptionEn.trim().isNotEmpty) {
            doctorAbout = doctor.descriptionEn;
          } else {
            doctorAbout = doctor.descriptionAr.trim().isNotEmpty
                ? doctor.descriptionAr
                : doctor.descriptionEn;
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Edit Button at the top
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                Get.to(() => const DoctorEditProfileScreen()),
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              AppLocalizations.of(context)!.editProfile,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Avatar with Badge
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: doctor.image.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: doctor.image,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColors.lightGrey,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: AppColors.lightGrey,
                                          child: const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                  )
                                : Container(
                                    color: AppColors.lightGrey,
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.grey,
                                    ),
                                  ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 4, bottom: 4),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name and Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        doctorName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF13364A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        doctorTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF6B7280)),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tags Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.medical_services_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                doctor.specialty.isNotEmpty
                                    ? doctor.specialty
                                    : AppLocalizations.of(context)!.doctor,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.yearsExperienceVal(
                                doctor.yearsExperience.toString(),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Info Sections
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildSection(context: context,
                            icon: Icons.person_outline,
                            title: AppLocalizations.of(context)!.about,
                            child: Text(
                              doctorAbout,
                              style: TextStyle(
                                fontSize: 14,
                                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF6B7280)),
                                height: 1.5,
                              ),
                            ),
                          ),

                          _buildSection(context: context,
                            icon: Icons.calendar_today_outlined,
                            title: AppLocalizations.of(
                              context,
                            )!.regularAvailability,
                            titleBadge: const Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: AppColors.grey,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: doctor.availabilityDay.entries.map((
                                entry,
                              ) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${entry.key.capitalizeFirst} • ${entry.value}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF6B7280)),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          _buildSection(context: context,
                            icon: Icons.videocam_outlined,
                            title: AppLocalizations.of(
                              context,
                            )!.onlineConsultation,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: doctor.isOnlineConsultationAvailable
                                        ? Colors.green
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  doctor.isOnlineConsultationAvailable
                                      ? AppLocalizations.of(context)!.available
                                      : AppLocalizations.of(
                                          context,
                                        )!.unavailable,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _buildSection(context: context,
                            icon: Icons.monetization_on_outlined,
                            title: AppLocalizations.of(
                              context,
                            )!.consultationFee,
                            child: Text(
                              doctor.price.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF13364A)),
                              ),
                            ),
                          ),

                          _buildSection(context: context,
                            icon: Icons.star_border_rounded,
                            title: AppLocalizations.of(context)!.rating,
                            titleBadge: const Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: AppColors.grey,
                            ),
                            child: Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (index) => const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(4.8)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF6B7280)),
                                  ),
                                ),
                              ],
                            ),
                            showBorder: false,
                          ),

                          const SizedBox(height: 16),

                          // Logout Button
                          ElevatedButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Get.offAllNamed(AppRoutes.login);
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: Text(
                              isArabic ? 'تسجيل الخروج' : 'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
    Widget? titleBadge,
    bool showBorder = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white12 : const Color(0xFFF3F4F6))))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF13364A)),
                      ),
                    ),
                    if (titleBadge != null) ...[
                      const SizedBox(width: 6),
                      titleBadge,
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}





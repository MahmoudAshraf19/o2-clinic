import '../../../../../../common/widgets/common_text_field.dart';
import '../../../../../../common/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/routes/app_routes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_fonts.dart';

import '../../../doctors/presentation/screens/all_doctor_profile_page.dart';
import '../../../booking/presentation/screens/cosmetic_booking_page.dart';
import '../../../booking/presentation/screens/radiology_profile_screen.dart';

import '../controllers/global_search_controller.dart';
import '../widgets/search_result_tile.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class GlobalSearchScreen extends StatelessWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GlobalSearchController());
    final isAr = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        title: CommonTextField(
          controller: controller.textController,
          autofocus: true,
          onChanged: controller.onSearchChanged,
          onSubmitted: controller.submitSearch,
          hint: isAr
              ? 'ابحث عن طبيب، قسم، تجميل، أو أشعة...'
              : 'Search doctors, specialties, cosmetics...',
          type: CommonTextFieldType.search,
          showBorder: false,
          filled: false,
        ),
        actions: [
          Obx(() {
            if (controller.query.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  controller.textController.clear();
                  controller.onSearchChanged('');
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CommonLoadingIndicator(color: AppColors.primary),
          );
        }

        if (controller.query.value.isEmpty) {
          return _buildRecentSearches(controller, isAr);
        }

        final hasResults =
            controller.filteredDoctors.isNotEmpty ||
            controller.filteredSpecialties.isNotEmpty ||
            controller.filteredRadiology.isNotEmpty ||
            controller.filteredCosmetics.isNotEmpty;

        if (!hasResults) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 80,
                  color: AppColors.border.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  isAr ? 'لا توجد نتائج' : 'No results found',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.filteredDoctors.isNotEmpty) ...[
              _buildSectionHeader(isAr ? 'الأطباء' : 'Doctors'),
              ...controller.filteredDoctors.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SearchResultTile(
                    title: isAr ? d.nameAr : d.nameEn,
                    subtitle: d.specialty,
                    imageUrl: d.image,
                    icon: Icons.person_rounded,
                    onTap: () {
                      controller.submitSearch(isAr ? d.nameAr : d.nameEn);
                      Get.to(() => DoctorProfilePage(doctor: d));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (controller.filteredSpecialties.isNotEmpty) ...[
              _buildSectionHeader(isAr ? 'التخصصات والأقسام' : 'Specialties'),
              ...controller.filteredSpecialties.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SearchResultTile(
                    title: s.getLocalizedName(Get.locale?.languageCode ?? 'en'),
                    subtitle: isAr ? 'قسم طبي' : 'Medical Department',
                    imageUrl: s.image,
                    icon: Icons.medical_services_rounded,
                    onTap: () {
                      final term = s.getLocalizedName(
                        Get.locale?.languageCode ?? 'en',
                      );
                      controller.submitSearch(term);
                      Get.toNamed(AppRoutes.departmentDoctors, arguments: s);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (controller.filteredRadiology.isNotEmpty) ...[
              _buildSectionHeader(
                isAr ? 'الأشعة والتصوير الطبي' : 'Radiology Services',
              ),
              ...controller.filteredRadiology.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SearchResultTile(
                    title: r.getName(Get.locale?.languageCode ?? 'en'),
                    subtitle: isAr ? 'خدمة أشعة' : 'Radiology Service',
                    icon: Icons.personal_injury_rounded,
                    onTap: () {
                      controller.submitSearch(
                        r.getName(Get.locale?.languageCode ?? 'en'),
                      );
                      Get.to(() => RadiologyProfileScreen(service: r));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (controller.filteredCosmetics.isNotEmpty) ...[
              _buildSectionHeader(
                isAr ? 'الخدمات التجميلية' : 'Cosmetic Services',
              ),
              ...controller.filteredCosmetics.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SearchResultTile(
                    title: c.getName(Get.locale?.languageCode ?? 'en'),
                    subtitle: isAr ? 'خدمة تجميل' : 'Cosmetic Service',
                    icon: Icons.face_retouching_natural_rounded,
                    onTap: () {
                      controller.submitSearch(
                        c.getName(Get.locale?.languageCode ?? 'en'),
                      );
                      Get.to(() => CosmeticBookingPage(model: c));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildRecentSearches(GlobalSearchController controller, bool isAr) {
    if (controller.recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 80,
              color: AppColors.border.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isAr
                  ? 'ابحث عن أي شيء في العيادة'
                  : 'Search for anything in the clinic',
              style: TextStyle(
                fontFamily: AppFonts.inter,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? 'عمليات البحث الأخيرة' : 'Recent Searches',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            CommonButton(
              onPressed: controller.clearRecentSearches,
              text: isAr ? 'مسح الكل' : 'Clear All',
              type: CommonButtonType.text,
              padding: EdgeInsets.zero,
              width: 50,
              height: 30,
              textStyle: const TextStyle(
                fontFamily: AppFonts.inter,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: controller.recentSearches
              .map((term) => _buildRecentChip(term, controller))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRecentChip(String term, GlobalSearchController controller) {
    return InkWell(
      onTap: () {
        controller.textController.text = term;
        controller.onSearchChanged(term);
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              term,
              style: const TextStyle(
                fontFamily: AppFonts.inter,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => controller.removeRecentSearch(term),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

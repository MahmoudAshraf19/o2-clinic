import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../common/widgets/common_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../search/views/global_search_screen.dart';

class DashboardSearchBar extends StatelessWidget {
  const DashboardSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      readOnly: true,
      onTap: () {
        Get.to(() => const GlobalSearchScreen(), transition: Transition.fadeIn);
      },
      type: CommonTextFieldType.search,
      hint: AppLocalizations.of(context)!.searchDoctorServiceClinic,
      prefixIcon: Icons.search_rounded,
      size: CommonTextFieldSize.medium,
      borderRadius: BorderRadius.circular(24),
      fillColor: AppColors.cardBackground,
      borderColor: AppColors.border.withValues(alpha: 0.20),
      focusBorderColor: AppColors.primary,
      style: const TextStyle(
        color: Color(0xFF181C1C),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}
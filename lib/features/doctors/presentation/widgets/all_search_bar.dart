import '../../../../common/widgets/common_text_field.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: CommonTextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        hint: AppLocalizations.of(context)!.searchDoctorSpecialty,
        type: CommonTextFieldType.search,
        prefixIcon: Icons.search,
        suffixWidget: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.colorFF60A5FA.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.tune,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.colorFF60A5FA
                : AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

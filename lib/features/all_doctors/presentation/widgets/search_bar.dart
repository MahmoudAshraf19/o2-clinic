import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';

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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        cursorColor: AppColors.primary,
        style: TextStyle(fontFamily: AppFonts.inter, fontSize: 14),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchDoctorSpecialty,
          hintStyle: TextStyle(
            fontFamily: AppFonts.inter,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.grey,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 22,
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF60A5FA) : AppColors.primary,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF60A5FA).withOpacity(0.15) : AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.tune, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF60A5FA) : AppColors.primary, size: 20),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.22),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.22),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}


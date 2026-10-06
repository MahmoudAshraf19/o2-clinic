import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final Map<String, String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final categoryKey = categories.keys.elementAt(index);
          final categoryValue = categories.values.elementAt(index);
          final isActive = categoryKey == selectedCategory;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onSelected(categoryKey),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(999),

                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : AppColors.border.withValues(alpha: 0.18),
                ),
              ),
              child: Center(
                child: Text(
                  categoryKey == 'All'
                      ? AppLocalizations.of(context)!.allCategory
                      : categoryValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    color: isActive ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


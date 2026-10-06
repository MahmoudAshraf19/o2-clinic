import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../services_firestore/models/xray_data_model.dart';

class XRayCard extends StatelessWidget {
  const XRayCard({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final XrayCategoryModel category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color cardBorderColor = selected
        ? AppColors.primary
        : AppColors.border.withValues(alpha: .55);

    final Color cardBackgroundColor = selected
        ? AppColors.primary.withValues(alpha: .06)
        : AppColors.white;

    final Color iconBackgroundColor = selected
        ? AppColors.primary.withValues(alpha: .12)
        : AppColors.surface;

    final Color titleColor = selected
        ? AppColors.primary
        : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cardBorderColor,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppColors.primary.withValues(alpha: .10)
                    : AppColors.shadowLight.withValues(alpha: .03),
                blurRadius: selected ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  category.iconData,
                  size: 26,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category.titleEn,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Container(
                  key: ValueKey<bool>(selected),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.add_rounded,
                    size: 18,
                    color: selected ? AppColors.white : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

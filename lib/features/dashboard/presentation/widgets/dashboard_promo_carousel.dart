import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPromoCarousel extends StatelessWidget {
  const DashboardPromoCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      final promo = controller.promos.isNotEmpty
          ? controller.promos.first
          : null;

      return Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              promo?.startColor ?? AppColors.primary,
              promo?.endColor ?? AppColors.onTertiaryFixedVariant,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.colorFF0F766E.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      promo?.title ??
                          AppLocalizations.of(context)!.searchAndBook,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      promo?.subtitle ??
                          AppLocalizations.of(
                            context,
                          )!.findDoctorsClinicsRadiology,
                      style: const TextStyle(
                        color: AppColors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.search,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

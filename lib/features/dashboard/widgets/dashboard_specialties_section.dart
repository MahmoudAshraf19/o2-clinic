import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/common_button.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_specialty_model.dart';

class DashboardSpecialtiesSection extends StatelessWidget {
  const DashboardSpecialtiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context)!.specialtiesClinics,
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  
                ),
              ),
              CommonButton(
                text: AppLocalizations.of(context)!.viewAll,
                onPressed: () {},
                type: CommonButtonType.text,
                size: CommonButtonSize.small,
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Obx(
          () {
            final items = controller.specialties;

            return SizedBox(
              height: 246,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = items[index];

                  if (item.isAvailable) {
                    return _ActiveSpecialtyCard(model: item);
                  }

                  return _InactiveSpecialtyCard(model: item);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActiveSpecialtyCard extends StatelessWidget {
  const _ActiveSpecialtyCard({required this.model});

  final DashboardSpecialtyModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  model.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 8,
                      color: Color(0xFF69D1C5),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppLocalizations.of(context)!.available,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            model.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              
            ),
          ),
          const SizedBox(height: 4),
          Text(
            model.description,
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.today,
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.text200Pm500Pm,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    AppLocalizations.of(context)!.text610SlotsFilled,
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InactiveSpecialtyCard extends StatelessWidget {
  const _InactiveSpecialtyCard({required this.model});

  final DashboardSpecialtyModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  model.icon,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 8,
                      color: Color(0xFF6E7977),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppLocalizations.of(context)!.next,
                      style: TextStyle(
                        color: Color(0xFF3E4947),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            model.name,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF181C1C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              
            ),
          ),
          const SizedBox(height: 4),
          Text(
            model.description,
            style: TextStyle(
              color: Color(0xFF6E7977),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.nextSlot,
                  style: TextStyle(
                    color: Color(0xFF6E7977),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    
                  ),
                ),
                Text(
                  model.nextSlotLabel ?? '-',
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF181C1C),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



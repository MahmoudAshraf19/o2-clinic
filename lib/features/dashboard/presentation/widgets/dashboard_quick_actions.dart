import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../../data/models/dashboard_quick_action_model.dart';

import '../../../appointments/presentation/screens/my_appointments_screen.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../booking/presentation/screens/radiology_services_screen.dart';
import '../../../booking/presentation/screens/cosmetic_services_screen.dart';
import '../../../booking/presentation/screens/lab_tests_screen.dart';
import '../../../contact_us/presentation/screens/our_location_screen.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      final items = controller.quickActions;

      return GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final item = items[index];

          return _QuickActionCard(data: item);
        },
      );
    });
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data});

  final DashboardQuickActionModel data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          if (data.id == 'appointments') {
            Get.to(() => const MyAppointmentsScreen());
          } else if (data.id == 'location') {
            Get.to(() => const OurLocationScreen());
          } else if (data.id == 'doctor') {
            Get.toNamed(AppRoutes.allDoctors);
          } else if (data.id == 'radiology') {
            Get.to(() => const RadiologyServicesScreen());
          } else if (data.id == 'cosmetic') {
            Get.to(() => const CosmeticServicesScreen());
          } else if (data.id == 'lab') {
            Get.to(() => const LabTestsScreen());
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandBlue.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      data.imagePath,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        AppColors.brandBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.white
                        : AppColors.onBackground,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/navigation/widgets/navigation_tab_item.dart';
import '../controllers/doctor_navigation_controller.dart';

class DoctorBottomNavigationBar extends StatelessWidget {
  const DoctorBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final DoctorNavigationController controller =
        Get.find<DoctorNavigationController>();

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              constraints: const BoxConstraints(minHeight: 76, maxHeight: 80),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.50),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Obx(() {
                  final int index = controller.currentIndex.value;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: NavigationTabItem(
                          icon: Icons.home_rounded,
                          label: AppLocalizations.of(context)!.doctorHome,
                          isActive: index == 0,
                          onTap: () => controller.changeIndex(0),
                        ),
                      ),
                      Expanded(
                        child: NavigationTabItem(
                          icon: Icons.calendar_month_rounded,
                          label: AppLocalizations.of(
                            context,
                          )!.doctorAppointments,
                          isActive: index == 1,
                          onTap: () => controller.changeIndex(1),
                        ),
                      ),
                      Expanded(
                        child: NavigationTabItem(
                          icon: Icons.chat_rounded,
                          label: AppLocalizations.of(context)!.doctorChats,
                          isActive: index == 2,
                          onTap: () => controller.changeIndex(2),
                        ),
                      ),
                      Expanded(
                        child: NavigationTabItem(
                          icon: Icons.person_rounded,
                          label: AppLocalizations.of(context)!.doctorProfile,
                          isActive: index == 3,
                          onTap: () => controller.changeIndex(3),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

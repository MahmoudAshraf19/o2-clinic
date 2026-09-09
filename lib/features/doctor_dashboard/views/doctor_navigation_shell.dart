import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/doctor_app_bar.dart';
import '../controllers/doctor_navigation_controller.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_chats_screen.dart';
import 'doctor_home_screen.dart';
import 'doctor_profile_screen.dart';
import '../widgets/doctor_bottom_navigation_bar.dart';

class DoctorNavigationShell extends StatelessWidget {
  const DoctorNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    final DoctorNavigationController controller = Get.find<DoctorNavigationController>();

    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: () {
          switch (controller.currentIndex.value) {
            case 0:
              return const DoctorHomeScreen();
            case 1:
              return const DoctorAppointmentsScreen();
            case 2:
              return const DoctorChatsScreen();
            case 3:
              return const DoctorProfileScreen();
            default:
              return const DoctorHomeScreen();
          }
        }(),
        bottomNavigationBar: const DoctorBottomNavigationBar(),
      );
    });
  }
}

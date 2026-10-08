import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/doctors/presentation/screens/all_doctors_page.dart';
import '../../../features/booking/presentation/screens/booking_screen.dart';
import '../../../features/chat_support/presentation/screens/contact_us_screen.dart';
import '../../../features/dashboard/presentation/screens/dashboard_home_screen.dart';
import '../../../features/dashboard/presentation/screens/dashboard_profile_screen.dart';
import '../../widgets/app_bar/o2_app_bar.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find<NavigationController>();

    return Obx(() {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar:
            (controller.currentIndex.value == 1 ||
                controller.currentIndex.value == 2 ||
                controller.currentIndex.value == 3 ||
                controller.currentIndex.value == 4)
            ? null
            : const O2AppBar(),
        body: () {
          switch (controller.currentIndex.value) {
            case 0:
              return const DashboardHomeScreen();
            case 1:
              return const AllDoctorsPage(showBackButton: false);
            case 2:
              return BookingScreen();
            case 3:
              return const ContactUsScreen();
            case 4:
              return const DashboardProfileScreen();
            default:
              return const _PlaceholderPage(title: 'Home Screen');
          }
        }(),
        bottomNavigationBar: const AppBottomNavigationBar(),
      );
    });
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}

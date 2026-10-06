import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/notification_router.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Timer(const Duration(seconds: 2), () async {
      if (isClosed) return; // Prevent navigation if hot-restarted or disposed

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('user_role');

        if (role == 'doctor') {
          Get.offAllNamed(AppRoutes.doctorNavigation);
        } else {
          Get.offAllNamed(AppRoutes.mainNavigation);
        }

        if (NotificationService.instance.pendingInitialNotification != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            NotificationRouter.handleNotificationTap(
              NotificationService.instance.pendingInitialNotification!,
              fromSplash: true,
            );
            NotificationService.instance.pendingInitialNotification = null;
          });
        }
      } else {
        Get.offAllNamed(AppRoutes.onboarding);
      }
    });
  }
}

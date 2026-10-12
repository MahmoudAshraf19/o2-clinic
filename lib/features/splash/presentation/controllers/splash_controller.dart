import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/notification_router.dart';

class SplashController extends GetxController {
  bool _started = false;

  /// بتتنادى من الـ SplashScreen بعد ما الأنيميشن يخلص
  void start() {
    if (_started) return;
    _started = true;
    Future.delayed(const Duration(milliseconds: 500), _navigateToNextScreen);
  }

  Future<void> _navigateToNextScreen() async {
    if (isClosed) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('user_role');

      if (role == 'doctor') {
        Get.offAllNamed(AppRoutes.doctorNavigation);
      } else {
        Get.offAllNamed(AppRoutes.mainNavigation);
      }

      final pending = NotificationService.instance.pendingInitialNotification;
      if (pending != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          NotificationRouter.handleNotificationTap(pending, fromSplash: true);
          NotificationService.instance.pendingInitialNotification = null;
        });
      }
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}

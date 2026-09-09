import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    print('🚀 SPLASH: Starting 2-second timer...');
    Timer(const Duration(seconds: 2), () {
      if (isClosed) return; // Prevent navigation if hot-restarted or disposed
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('🚀 SPLASH: User is logged in. Navigating to main navigation...');
        Get.offAllNamed(AppRoutes.mainNavigation);
      } else {
        print('🚀 SPLASH: Navigating to onboarding screen...');
        Get.offAllNamed(AppRoutes.onboarding);
      }
    });
  }
}

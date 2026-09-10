import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    print('🚀 SPLASH: Starting 2-second timer...');
    Timer(const Duration(seconds: 2), () async {
      if (isClosed) return; // Prevent navigation if hot-restarted or disposed
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('user_role');
        
        if (role == 'doctor') {
          print('🚀 SPLASH: Doctor is logged in. Navigating to doctor dashboard...');
          Get.offAllNamed(AppRoutes.doctorNavigation);
        } else {
          print('🚀 SPLASH: Patient is logged in. Navigating to main navigation...');
          Get.offAllNamed(AppRoutes.mainNavigation);
        }
      } else {
        print('🚀 SPLASH: Navigating to onboarding screen...');
        Get.offAllNamed(AppRoutes.onboarding);
      }
    });
  }
}

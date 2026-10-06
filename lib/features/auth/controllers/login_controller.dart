import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/auth_error_handler.dart';
import '../../services_firestore/user_firestore_service.dart';
import '../../chat_support/screens/support_chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final email = TextEditingController();
  final password = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  Future<void> login() async {
    try {
      if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter email and password',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      isLoading.value = true;

      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      if (userCred.user != null) {
        final userData = await UserFirestoreService.instance.getUser(
          userCred.user!.uid,
        );

        if (userData == null) {
          await FirebaseAuth.instance.signOut();
          Get.snackbar(
            'Login Failed',
            'Email does not exist in our records.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
          return;
        }

        if (userData['isBlocked'] == true) {
          await FirebaseAuth.instance.signOut();
          Get.snackbar(
            'Account Blocked',
            'Your account is currently blocked. Please contact the administration.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withValues(alpha: 0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 8),
            mainButton: TextButton(
              onPressed: () {
                if (Get.isSnackbarOpen) {
                  Get.closeCurrentSnackbar();
                }
                Get.to(() => const SupportChatScreen());
              },
              child: const Text(
                'Contact Support',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'patient');

      Get.offAllNamed(AppRoutes.mainNavigation);

      Get.snackbar(
        'Success 🎉',
        'Login successful',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        AuthErrorHandler.handleException(e),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}

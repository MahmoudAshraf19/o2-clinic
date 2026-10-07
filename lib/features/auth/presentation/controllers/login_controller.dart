import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import 'package:get/get.dart';

import '../../../../common/utils/validators.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/auth_error_handler.dart';
import '../../data/services/user_firestore_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final email = TextEditingController();
  final password = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  Future<void> login() async {
    try {
      final emailError = Validators.validateEmail(email.text);
      if (emailError != null) {
        CommonSnackbar.showError(title: 'Error', message: emailError);
        return;
      }

      final passError = Validators.validateRequired(password.text, 'Password');
      if (passError != null) {
        CommonSnackbar.showError(title: 'Error', message: passError);
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
          CommonSnackbar.showError(title: 'Login Failed', message: 'Email does not exist in our records.');
          return;
        }

        if (userData['isBlocked'] == true) {
          await FirebaseAuth.instance.signOut();
          CommonSnackbar.showSuccess(title: 'Account Blocked', message: 'Your account is currently blocked. Please contact the administration.');
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'patient');

      Get.offAllNamed(AppRoutes.mainNavigation);

      CommonSnackbar.showSuccess(title: 'Success 🎉', message: 'Login successful');
    } catch (e) {
      CommonSnackbar.showError(title: 'Login Failed', message: AuthErrorHandler.handleException(e));
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_firestore.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/auth_error_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorLoginController extends GetxController {
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

      // 1. Authenticate with Firebase Auth
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      if (userCred.user != null) {
        // 2. Verify Doctor identity in Firestore 'doctors' collection by email
        final uid = userCred.user!.uid;
        final doctorsSnapshot = await FirebaseFirestore.instance
            .collection(AppFirestoreCollections.doctors)
            .where('email', isEqualTo: email.text.trim())
            .limit(1)
            .get();

        if (doctorsSnapshot.docs.isEmpty) {
          // Not a doctor, sign out and show error
          await FirebaseAuth.instance.signOut();

          final context = Get.context;
          Get.snackbar(
            context != null
                ? AppLocalizations.of(context)!.doctorEmailNotFoundTitle
                : 'Email Not Found',
            context != null
                ? AppLocalizations.of(context)!.doctorEmailNotFound
                : 'This email is not found. Please contact administration.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withOpacity(0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }

        // Successfully verified as doctor
        final doctorData = doctorsSnapshot.docs.first.data();
        final existingToken = doctorData['fcmToken'] as String?;
        final existingAuthUid = doctorData['auth_uid'] as String?;

        String? fcmToken = existingToken;

        // Get FCM Token only if it doesn't exist or is empty, and NOT on Web
        if (!kIsWeb && (fcmToken == null || fcmToken.isEmpty)) {
          try {
            fcmToken = await FirebaseMessaging.instance.getToken().timeout(
              const Duration(seconds: 3),
            );
          } catch (e) {
            debugPrint('Failed to get FCM token: $e');
          }
        }

        // Update the doctor's document if auth_uid or fcmToken changed
        final docId = doctorsSnapshot.docs.first.id;
        if (existingAuthUid != uid ||
            (fcmToken != null && fcmToken != existingToken)) {
          await FirebaseFirestore.instance
              .collection(AppFirestoreCollections.doctors)
              .doc(docId)
              .update({
                'auth_uid': uid,
                if (fcmToken != null && fcmToken.isNotEmpty)
                  'fcmToken': fcmToken,
              });
        }

        final locale = Get.locale?.languageCode ?? 'en';
        final doctorName = locale == 'ar'
            ? (doctorData['name_ar'] ?? '')
            : (locale == 'he'
                  ? (doctorData['name_he'] ?? '')
                  : (doctorData['name_en'] ?? ''));

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'doctor');

        Get.offAllNamed(AppRoutes.doctorNavigation);

        Get.snackbar(
          locale == 'ar'
              ? 'مرحباً، $doctorName 👋'
              : (locale == 'he'
                    ? 'שלום, $doctorName 👋'
                    : 'Hi, $doctorName 👋'),
          locale == 'ar'
              ? 'تم تسجيل الدخول بنجاح'
              : (locale == 'he' ? 'ההתחברות הצליחה' : 'Login successful'),
          snackPosition: SnackPosition.TOP,
        );
      }
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

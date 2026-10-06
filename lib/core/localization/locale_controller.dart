import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/services_firestore/user_firestore_service.dart';

class LocaleController extends GetxController {
  LocaleController(String initialCode) {
    _currentLanguageCode.value = initialCode;
  }

  final _currentLanguageCode = 'en'.obs;
  String get currentLanguageCode => _currentLanguageCode.value;
  RxString get rxLanguageCode => _currentLanguageCode;

  Locale get locale => Locale(_currentLanguageCode.value);

  Future<void> changeLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    _currentLanguageCode.value = languageCode;

    // Update locale in GetX
    Get.updateLocale(Locale(languageCode));

    // Update in Firestore for FCM background notifications
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await UserFirestoreService.instance.updateUser(
          uid: user.uid,
          data: {'language': languageCode},
        );
      } catch (e) {
        debugPrint('Failed to update user language in Firestore: $e');
      }
    }
  }
}

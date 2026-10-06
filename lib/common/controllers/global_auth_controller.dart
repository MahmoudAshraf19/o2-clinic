import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../features/services_firestore/user_firestore_service.dart';
import '../../core/routes/app_routes.dart';
import '../../features/chat_support/screens/support_chat_screen.dart';

class GlobalAuthController extends GetxController {
  StreamSubscription<User?>? _authSub;
  StreamSubscription<Map<String, dynamic>?>? _userDocSub;

  final currentUserData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _authSub = FirebaseAuth.instance.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  void _onAuthStateChanged(User? user) {
    _userDocSub?.cancel();
    if (user != null) {
      _updateFcmToken(user.uid);

      _userDocSub = UserFirestoreService.instance.streamUser(user.uid).listen((
        data,
      ) {
        if (data != null) {
          currentUserData.value = data;

          final isBlocked = data['isBlocked'] == true;
          if (isBlocked) {
            _handleBlockedUser();
          }
        } else {
          currentUserData.value = null;
        }
      });
    } else {
      UserFirestoreService.instance.clearCache();
      currentUserData.value = null;
    }
  }

  // _onUserDocUpdated removed as it's now handled inline

  Future<void> _updateFcmToken(String uid) async {
    if (kIsWeb) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await UserFirestoreService.instance.updateUser(
          uid: uid,
          data: {'auth.fcm_token': token},
        );
      }
    } catch (e) { /* ignore */ }
  }

  Future<void> _handleBlockedUser() async {
    await FirebaseAuth.instance.signOut();

    // Redirect to main navigation (which will show the home page for guests)
    Get.offAllNamed(AppRoutes.mainNavigation);

    Get.snackbar(
      'Account Blocked',
      'Your account has been blocked. Please contact the administration.',
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
        child: const Text('OK', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.onClose();
  }
}

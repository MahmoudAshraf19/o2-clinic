import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../services_firestore/user_firestore_service.dart';
import '../services/social_auth_service.dart';

class SocialAuthController extends GetxController {
  final isLoading = false.obs;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> handleAutoLogin() async {
    _log(
      "🚀 Boot sequence started... Checking if you’re already signed in 🧠✨",
    );

    final user = _auth.currentUser;

    if (user == null) {
      _log("🫧 No active session found. Welcome flow will take over 🌿");
      return;
    }

    _log("✅ Session detected! User is already authenticated 🔐💚");
    await _routeAfterAuth(user);
  }

  // ==================== GOOGLE ====================

  /// NOTE: Keeping isWeb param to avoid changing your UI code.
  /// We won't use it inside because SocialAuthService already handles kIsWeb.
  Future<void> loginWithGoogle({required bool isWeb}) async {
    try {
      isLoading.value = true;

      _log("🌟 Google Sign-In is starting... Deep breath, we got this 😌💫");
      _log("🧩 Preparing secure OAuth handshake... 🔒");
      _log("📡 Talking to Google servers... Please wait a tiny moment 🙏✨");

      final cred = await SocialAuthService.instance.signInWithGoogle();

      _log("🎉 Google authentication completed successfully! ✅");

      final user = cred.user;
      if (user == null) {
        _log(
          "⚠️ Unexpected: Firebase returned null user. That’s not normal 😵‍💫",
        );
        throw Exception("Google sign-in returned null user");
      }

      _log("👤 User ready: ${user.uid} 🧡");
      await _routeAfterAuth(user);

      _log("🏁 Google Sign-In flow finished like a champ 🏆🔥");
    } on FirebaseAuthException catch (e) {
      _logError("❌ FirebaseAuthException happened during Google sign-in", e);
      _showFriendlyError(_friendlyAuthMessage(e));
    } catch (e) {
      _logError("❌ Unexpected error during Google sign-in", e);
      _showFriendlyError("Something went wrong. Please try again in a moment.");
    } finally {
      isLoading.value = false;
      _log("🧯 Loading state released. UI back to normal ✨");
    }
  }

  // ==================== APPLE ====================

  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;

      _log("🍎 Apple Sign-In is starting... Smooth & secure vibes only 😎🔐");
      _log("🧬 Generating secure nonce... ultra protection mode ON 🛡️");
      _log("📡 Contacting Apple... Please hold tight, almost there ✨");

      final cred = await SocialAuthService.instance.signInWithApple();

      _log("🎉 Apple authentication completed successfully! ✅");

      final user = cred.user;
      if (user == null) {
        _log("⚠️ Unexpected: Firebase returned null user from Apple 😵‍💫");
        throw Exception("Apple sign-in returned null user");
      }

      _log("👤 User ready: ${user.uid} 🧡");
      await _routeAfterAuth(user);

      _log("🏁 Apple Sign-In flow finished perfectly 🍎✅");
    } on FirebaseAuthException catch (e) {
      _logError("❌ FirebaseAuthException happened during Apple sign-in", e);
      _showFriendlyError(_friendlyAuthMessage(e));
    } catch (e) {
      _logError("❌ Unexpected error during Apple sign-in", e);
      _showFriendlyError("Something went wrong. Please try again in a moment.");
    } finally {
      isLoading.value = false;
      _log("🧯 Loading state released. UI back to normal ✨");
    }
  }

  // ==================== ROUTING ====================

  Future<void> _routeAfterAuth(User user) async {
    _log("🧭 Routing decision time... Checking Firestore profile 🗂️✨");
    _log("🔍 Looking for user document in: users/${user.uid} 👀");

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      _log("✅ Profile found in Firestore! Welcome back, legend 😍🔥");
      _log("🏡 Navigating to Dashboard... 🏃‍♂️💨");

      Get.offAllNamed(AppRoutes.mainNavigation);
      return;
    }

    _log(
      "🆕 No profile found. First time here! Let’s complete your profile 📝💚",
    );
    _log("➡️ Navigating to Register screen to finish setup ✨");

    Get.offAllNamed(
      AppRoutes.register,
      arguments: {
        "mode": "social",
        "uid": user.uid,
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "photoUrl": user.photoURL ?? "",
        "providerId": user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : "",
      },
    );
  }

  // ==================== FIRESTORE SAVE ====================

  Future<void> createFirestoreUserFromSocial({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      _log("🧾 Saving profile to Firestore... This is the final step 😮‍💨✨");
      _log("🧷 Creating stable ID with prefix: o2_ 🔖");

      final o2Id = "o2_$uid";

      final clean = {
        ...data,
        "id": o2Id,
        "uid": uid,
        "createdAt": FieldValue.serverTimestamp(),
      };

      _log("📦 Uploading data to: users/$uid 🚀");
      await UserFirestoreService.instance.createUser(
        docId: o2Id,
        uid: uid, 
        data: clean,
      );

      _log("✅ Firestore write success! Profile saved like a pro 🎯💚");
      _log("🏡 Sending you to Dashboard now... 🏃‍♂️💨");

      Get.offAllNamed(AppRoutes.mainNavigation);
    } on FirebaseAuthException catch (e) {
      _logError("❌ FirebaseAuthException during Firestore save", e);
      _showFriendlyError(_friendlyAuthMessage(e));
    } catch (e) {
      _logError("❌ Unexpected error during Firestore save", e);
      _showFriendlyError("Couldn’t save your profile. Please try again.");
    }
  }

  // ==================== UX: FRIENDLY ERRORS ====================

  void _showFriendlyError(String message) {
    // ✅ User sees only clean friendly message (no Firebase raw errors)
    Get.snackbar(
      "Oops 😅",
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    // ✅ High-level, clean, user-friendly messages
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return "This email is already linked with another sign-in method.";
      case 'invalid-credential':
        return "Invalid credentials. Please try again.";
      case 'operation-not-allowed':
        return "This sign-in method is not enabled right now.";
      case 'user-disabled':
        return "Your account has been disabled. Please contact support.";
      case 'user-not-found':
        return "No account found for this user.";
      case 'wrong-password':
        return "Wrong password. Please try again.";
      case 'invalid-email':
        return "That email address looks invalid.";
      case 'network-request-failed':
        return "No internet connection. Please check your network.";
      case 'too-many-requests':
        return "Too many attempts. Please wait a bit and try again.";
      case 'popup-blocked':
        return "Popup blocked by the browser. Please allow popups and try again.";
      case 'popup-closed-by-user':
        return "Sign-in was cancelled. Please try again.";
      default:
        return "Authentication failed. Please try again.";
    }
  }

  // ==================== LOGS ====================

  void _log(String msg) {
    // ✅ prints in terminal / logs with emotions
    if (kDebugMode) {
      debugPrint(msg);
    }
  }

  void _logError(String title, Object error) {
    // ✅ detailed error only in terminal, not in UI
    if (kDebugMode) {
      debugPrint(title);
      debugPrint("🧨 Debug details: $error");
    }
  }
}

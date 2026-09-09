import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/core/routes/app_routes.dart';
import 'package:o2_clinic/features/profile/models/dashboard_profile_model.dart';
import 'package:o2_clinic/features/profile/services/dashboard_profile_service.dart';
import 'package:o2_clinic/features/profile/view/settings_screen.dart';

class DashboardProfileController extends GetxController {
  DashboardProfileController(this.service);

  final DashboardProfileService service;

  final Rxn<DashboardProfileModel> user = Rxn<DashboardProfileModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<DashboardProfileModel?>? _profileSubscription;
  StreamSubscription<User?>? _authSubscription;
  String? _uid;

  DashboardProfileModel get currentUser =>
      user.value ?? DashboardProfileModel.empty(_uid ?? '');

  @override
  void onInit() {
    super.onInit();
    loadUser();
    startRealtimeSync();
    
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      if (_uid != firebaseUser?.uid) {
        debugPrint('[PROFILE] Auth state changed: uid=${firebaseUser?.uid}');
        _uid = firebaseUser?.uid;
        loadUser();
        startRealtimeSync();
      }
    });
  }

  @override
  void onClose() {
    _profileSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  String? _resolveUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  bool get isGuest => FirebaseAuth.instance.currentUser == null;

  Future<void> loadUser({bool forceRefresh = false}) async {
    final uid = _resolveUid();

    if (uid == null || uid.isEmpty) {
      user.value = const DashboardProfileModel(
        name: 'Guest',
        username: 'Guest',
        email: 'guest@o2clinic.com',
        phone: 'N/A',
        gender: 'N/A',
      );
      return;
    }

    _uid = uid;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      debugPrint('[PROFILE] Loading profile for uid=$uid');

      final profile = await service.getProfile(
        uid: uid,
        forceRefresh: forceRefresh,
      );

      user.value = profile ?? DashboardProfileModel.empty(uid);

      if ((profile?.uid ?? '').isEmpty) {
        debugPrint('[PROFILE] Profile document not found');
        errorMessage.value = 'Profile not found.';
      } else {
        debugPrint('[PROFILE] Profile loaded successfully');
      }
    } catch (e) {
      debugPrint('[PROFILE ERROR] Failed to load profile -> $e');
      errorMessage.value = 'Failed to load profile.';
      user.value = DashboardProfileModel.empty(uid);
    } finally {
      isLoading.value = false;
    }
  }

  /// Call only when you need live updates.
  void startRealtimeSync() {
    final uid = _uid ?? _resolveUid();
    if (uid == null || uid.isEmpty) return;

    debugPrint('[PROFILE] Starting realtime sync for uid=$uid');

    _profileSubscription?.cancel();
    _profileSubscription = service.watchProfile(uid).listen((profile) {
      if (profile != null) {
        debugPrint('[PROFILE] Realtime profile update received');
        user.value = profile;
      }
    });
  }

  @override
  Future<void> refresh() async {
    debugPrint('[PROFILE] Manual refresh requested');
    await loadUser(forceRefresh: true);
  }

  void openSettings() {
    debugPrint('[PROFILE] Opening settings screen');
    Get.to(() => const SettingsScreen());
  }

  Future<void> logout() async {
    if (isGuest) {
      Get.offAllNamed(AppRoutes.welcome);
      return;
    }
    try {
      debugPrint('[PROFILE] Signing out user...');

      await FirebaseAuth.instance.signOut();
      service.clearCache();
      user.value = null;
      errorMessage.value = '';

      debugPrint('[PROFILE] Sign out completed');

      Get.snackbar(
        'Signed Out',
        'You have been logged out',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('[PROFILE ERROR] Logout failed -> $e');
      Get.snackbar(
        'Error',
        'Could not sign out',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

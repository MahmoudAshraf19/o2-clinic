import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../models/onboarding_slide_model.dart';
import '../services/onboarding_service.dart';

class OnboardingController extends GetxController {
  OnboardingController({required this.service});

  final OnboardingService service;

  final PageController pageController = PageController();
  final RxList<OnboardingSlideModel> slides = <OnboardingSlideModel>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<List<OnboardingSlideModel>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenToSlides();
  }

  void _listenToSlides() {
    print('🔄 ONBOARDING: Starting to listen to slides from Firestore...');
    bool hasReceivedData = false;
    
    _subscription = service.watchSlides().listen(
      (data) {
        print('✅ ONBOARDING: Successfully received ${data.length} slides from Firestore');
        if (data.isNotEmpty) {
          for (int i = 0; i < data.length; i++) {
            print('   📄 Slide ${i + 1}: ${data[i].title}');
          }
        }
        hasReceivedData = true;
        slides.assignAll(data);
        isLoading.value = false;
      },
      onError: (error) {
        print('❌ ONBOARDING: Stream error - $error');
        if (!hasReceivedData) {
          print('🔄 ONBOARDING: Trying fallback method...');
          _fetchSlidesAsFallback();
        }
      },
    );

    // Fallback: if no data received within 3 seconds, try direct fetch
    Future.delayed(const Duration(seconds: 3), () {
      if (!hasReceivedData && isLoading.value) {
        print('⏰ ONBOARDING: Stream timeout (3 seconds), trying direct fetch...');
        _fetchSlidesAsFallback();
      }
    });
  }

  void _fetchSlidesAsFallback() async {
    print('🔄 ONBOARDING: Fetching slides directly (fallback method)...');
    try {
      final data = await service.getSlides();
      print('✅ ONBOARDING: Fallback successful - got ${data.length} slides');
      slides.assignAll(data);
      isLoading.value = false;
    } catch (e) {
      print('❌ ONBOARDING: Fallback fetch failed - $e');
      slides.clear();
      isLoading.value = false;
    }
  }

  bool get isLastPage =>
      slides.isNotEmpty && currentIndex.value == slides.length - 1;

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (slides.isEmpty) return;

    if (isLastPage) {
      finishOnboarding();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void skip() {
    finishOnboarding();
  }

  void finishOnboarding() {
    Get.offAllNamed(AppRoutes.welcome);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    pageController.dispose();
    super.onClose();
  }
}

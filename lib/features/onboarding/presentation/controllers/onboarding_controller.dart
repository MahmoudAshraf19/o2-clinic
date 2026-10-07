import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../../core/routes/app_routes.dart';
import '../../data/models/onboarding_slide_model.dart';
import '../../data/services/onboarding_service.dart';

class OnboardingController extends GetxController {
  OnboardingController({required this.service});

  final OnboardingService service;

  final PageController pageController = PageController();
  final RxList<OnboardingSlideModel> slides = <OnboardingSlideModel>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStaticSlides();
  }

  void _loadStaticSlides() {
    // Note: We need a context to access translations. Since GetX controllers
    // don't have context in onInit reliably, we can initialize them when the view is built
    // or just use Get.context! if available. But since we need translations,
    // let's just initialize them lazily in a getter or passing context.
    // For now, we will wait until the next frame to safely access Get.context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        final l10n = AppLocalizations.of(Get.context!)!;
        slides.assignAll([
          OnboardingSlideModel(
            id: '1',
            title: l10n.onboarding1Title,
            description: l10n.onboarding1Desc,
            imageUrl: 'assets/images/onboarding/onboarding1.png',
            order: 1,
            isActive: true,
          ),
          // We can add more slides here if needed, but for now we have slide 1.
          // To make the dots work as in the screenshot, I'll add placeholder slides
          // or just 3 identical slides until the user provides the rest.
          OnboardingSlideModel(
            id: '2',
            title: 'Second Screen',
            description: 'This is the second screen.',
            imageUrl: 'assets/images/onboarding/onboarding1.png',
            order: 2,
            isActive: true,
          ),
          OnboardingSlideModel(
            id: '3',
            title: 'Third Screen',
            description: 'This is the third screen.',
            imageUrl: 'assets/images/onboarding/onboarding1.png',
            order: 3,
            isActive: true,
          ),
        ]);
        isLoading.value = false;
      }
    });
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
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

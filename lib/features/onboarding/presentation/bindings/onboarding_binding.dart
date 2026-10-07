import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import '../../data/services/onboarding_service.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // Register the service first.
    Get.lazyPut<OnboardingService>(() => OnboardingService());

    // Then register the controller.
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(service: Get.find<OnboardingService>()),
    );
  }
}

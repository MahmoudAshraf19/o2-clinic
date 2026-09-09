import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';
import '../services/onboarding_service.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    print('🔗 BINDING: Registering onboarding dependencies...');
    
    // Register the service first.
    Get.lazyPut<OnboardingService>(() => OnboardingService());
    print('🔗 BINDING: OnboardingService registered');

    // Then register the controller.
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(service: Get.find<OnboardingService>()),
    );
    print('🔗 BINDING: OnboardingController registered');
  }
}

import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Register the splash controller.
    Get.lazyPut<SplashController>(() => SplashController());
  }
}

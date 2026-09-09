import 'package:get/get.dart';

import '../controllers/welcome_controller.dart';

class WelcomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register the controller for the welcome screen.
    Get.lazyPut<WelcomeController>(() => WelcomeController());
  }
}

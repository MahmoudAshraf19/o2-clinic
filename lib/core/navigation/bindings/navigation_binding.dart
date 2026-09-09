import 'package:get/get.dart';

import '../../../features/dashboard/bindings/dashboard_binding.dart';
import '../../../features/services/bindings/services_binding.dart';
import '../controllers/navigation_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Registers the navigation controller.
    Get.lazyPut<NavigationController>(() => NavigationController());

    DashboardBinding().dependencies();
    ServicesBinding().dependencies();
  }
}
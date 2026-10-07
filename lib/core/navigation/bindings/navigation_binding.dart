import 'package:get/get.dart';

import '../../../features/dashboard/presentation/bindings/dashboard_binding.dart';
import '../../../features/services/presentation/bindings/services_binding.dart';
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

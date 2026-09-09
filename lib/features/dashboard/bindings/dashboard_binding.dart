import 'package:get/get.dart';

import '../../profile/controllers/dashboard_profile_controller.dart';
import '../../profile/services/dashboard_profile_service.dart';
import '../controllers/dashboard_controller.dart';
import '../services/dashboard_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardService>(() => DashboardService());

    Get.lazyPut<DashboardController>(
      () => DashboardController(service: Get.find<DashboardService>()),
    );

    Get.lazyPut<DashboardProfileService>(() => DashboardProfileService());

    Get.lazyPut<DashboardProfileController>(
      () => DashboardProfileController(Get.find<DashboardProfileService>()),
    );
  }
}

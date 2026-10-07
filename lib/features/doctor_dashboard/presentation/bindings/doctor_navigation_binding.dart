import 'package:get/get.dart';
import '../controllers/doctor_navigation_controller.dart';
import '../controllers/doctor_profile_controller.dart';

class DoctorNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorNavigationController>(() => DoctorNavigationController());
    Get.lazyPut<DoctorProfileController>(() => DoctorProfileController());
  }
}

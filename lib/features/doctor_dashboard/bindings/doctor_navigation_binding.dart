import 'package:get/get.dart';
import '../controllers/doctor_navigation_controller.dart';

class DoctorNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorNavigationController>(() => DoctorNavigationController());
  }
}

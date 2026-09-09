import 'package:get/get.dart';
import '../controllers/doctor_login_controller.dart';

class DoctorLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorLoginController>(() => DoctorLoginController());
  }
}

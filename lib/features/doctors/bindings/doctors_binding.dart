import 'package:get/get.dart';
import '../controllers/doctors_controller.dart';

class DoctorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DoctorsController());
  }
}

import 'package:get/get.dart';
import '../models/doctor_model.dart';
import '../services/doctors_service.dart';

class DoctorsController extends GetxController {
  var doctors = <DoctorModel>[].obs;

  @override
  void onInit() {
    doctors.value = DoctorsService.getDoctors();
    super.onInit();
  }
}
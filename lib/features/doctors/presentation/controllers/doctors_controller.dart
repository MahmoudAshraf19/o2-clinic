import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/common/models/fs_doctor_model.dart';
import '../../data/services/doctors_cache_service.dart';

class DoctorsController extends GetxController {
  var doctors = <DoctorModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    isLoading.value = true;
    try {
      final firestoreDoctors = await DoctorsCacheService.getDoctors();
      doctors.assignAll(firestoreDoctors);
    } catch (e) {
      debugPrint("Error fetching doctors: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

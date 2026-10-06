import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/doctor_model.dart' as ui_model;
import '../../services_firestore/services/doctors_cache_service.dart';

class DoctorsController extends GetxController {
  var doctors = <ui_model.DoctorModel>[].obs;
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

      final mappedDoctors = firestoreDoctors.map((fsDoctor) {
        // Find current language or default to english if Get.context is null
        String locale = 'en';
        if (Get.context != null) {
          locale = Localizations.localeOf(Get.context!).languageCode;
        }

        String name = fsDoctor.nameEn;
        if (locale == 'ar' && fsDoctor.nameAr.isNotEmpty)
          name = fsDoctor.nameAr;
        if (locale == 'he' && fsDoctor.nameHe.isNotEmpty)
          name = fsDoctor.nameHe;

        String title = fsDoctor.titleEn;
        if (locale == 'ar' && fsDoctor.titleAr.isNotEmpty)
          title = fsDoctor.titleAr;
        if (locale == 'he' && fsDoctor.titleHe.isNotEmpty)
          title = fsDoctor.titleHe;

        String description = fsDoctor.descriptionEn;
        if (locale == 'ar' && fsDoctor.descriptionAr.isNotEmpty)
          description = fsDoctor.descriptionAr;
        if (locale == 'he' && fsDoctor.descriptionHe.isNotEmpty)
          description = fsDoctor.descriptionHe;

        return ui_model.DoctorModel(
          id: fsDoctor.id,
          name: name,
          title: title,
          image: fsDoctor.image,
          rating: fsDoctor.ratingAverage.toDouble(),
          reviews: fsDoctor.reviewsCount,
          availability:
              'Available', // Can be computed based on fsDoctor.availabilityDay
          booked: 0,
          total: fsDoctor.maxBooking,
          isTopRated: fsDoctor.theTop,
          isMostBooked: false,
          isOnlineConsultationAvailable: fsDoctor.isOnlineConsultationAvailable,
          about: description,
        );
      }).toList();

      doctors.assignAll(mappedDoctors);
    } catch (e) {
      debugPrint("Error fetching doctors: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

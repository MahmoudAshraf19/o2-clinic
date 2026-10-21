import 'package:get/get.dart';

import '../../../../common/models/fs_doctor_model.dart';
import '../../../doctors/data/services/doctors_firestore_service.dart';
import '../../../services/data/models/fs_specialized_service_model.dart';
import '../../../services/data/services/fs_specialized_cache.dart';
import '../../data/models/dashboard_health_chip_model.dart';
import '../../data/models/dashboard_promo_model.dart';
import '../../data/models/dashboard_quick_action_model.dart';
import '../../data/models/dashboard_specialty_model.dart';
import '../../data/services/dashboard_service.dart';
import '../../../../core/localization/locale_controller.dart';

class DashboardController extends GetxController {
  DashboardController({
    required this.service,
    DoctorsFirestoreService? doctorsService,
  }) : _doctorsService = doctorsService ?? DoctorsFirestoreService();

  final DashboardService service;
  final DoctorsFirestoreService _doctorsService;

  final RxBool isLoading = true.obs;

  final RxList<DashboardPromoModel> promos = <DashboardPromoModel>[].obs;
  final RxList<DashboardQuickActionModel> quickActions =
      <DashboardQuickActionModel>[].obs;
  final RxList<DoctorModel> topDoctors = <DoctorModel>[].obs;
  final RxList<DoctorModel> upcomingDoctors = <DoctorModel>[].obs;
  final RxList<DashboardSpecialtyModel> specialties =
      <DashboardSpecialtyModel>[].obs;
  final RxList<DashboardHealthChipModel> healthChips =
      <DashboardHealthChipModel>[].obs;

  final RxList<SpecializedServiceModel> specializedServices =
      <SpecializedServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();

    // Listen for language changes to instantly update static UI translations
    final localeController = Get.find<LocaleController>();
    ever(localeController.rxLanguageCode, (_) {
      loadLocalStaticData();
    });
  }

  Future<void> loadLocalStaticData() async {
    final data = await service.getDashboardData();
    promos.assignAll(data.promos);
    quickActions.assignAll(data.quickActions);
    specialties.assignAll(data.specialties);
    healthChips.assignAll(data.healthChips);
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;

    try {
      await loadLocalStaticData();

      final results = await Future.wait([
        _doctorsService.getTopRatedDoctors(),
        _doctorsService.getTheTopDoctors(),
        SpecializedCache.getData(),
      ]);

      topDoctors.assignAll(results[0] as List<DoctorModel>);
      upcomingDoctors.assignAll(results[1] as List<DoctorModel>);
      specializedServices.assignAll(results[2] as List<SpecializedServiceModel>);
    } catch (e) {
      topDoctors.clear();
      upcomingDoctors.clear();
      specializedServices.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String getLocalizedSpecialty(String specialtyId, String langCode) {
    if (specialtyId.trim().isEmpty) return '';

    final normalizedTarget = specialtyId
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');

    for (final service in specializedServices) {
      final normalizedId = service.id
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
      final normalizedEn = service.nameEn
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '');

      if (normalizedId == normalizedTarget || normalizedEn == normalizedTarget) {
        return service.getLocalizedName(langCode);
      }
    }

    return specialtyId;
  }
}

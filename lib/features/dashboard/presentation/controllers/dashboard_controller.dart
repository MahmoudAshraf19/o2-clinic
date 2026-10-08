import 'package:get/get.dart';

import '../../../../features/doctors/data/models/doctor_model.dart';
import '../../../doctors/data/services/doctors_firestore_service.dart';
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

      final topDoctorsResult = await _doctorsService.getTopRatedDoctors();
      topDoctors.assignAll(topDoctorsResult);

      final upcomingDoctorsResult = await _doctorsService.getTheTopDoctors();
      upcomingDoctors.assignAll(upcomingDoctorsResult);
    } catch (e) {
      topDoctors.clear();
      upcomingDoctors.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

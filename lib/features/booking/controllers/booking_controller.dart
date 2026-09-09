import 'package:get/get.dart';

import '../../services/models/department_model.dart';
import '../../services_firestore/services/specialized_cache.dart';
import '../models/booking_service_model.dart';
import '../services/booking_service.dart';
import '../views/radiology_services_screen.dart';
import '../widgets/department_doctor_widget.dart'; // فيه DepartmentDoctorScreen
import '../views/cosmetic_services_screen.dart';

class BookingController extends GetxController {
  final services = <BookingServiceModel>[].obs;
  final selectedIndex = (-1).obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _preloadServices();
    loadServices();
  }

  void _preloadServices() async {
    await BookingService.getServices();
  }

  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      final data = await BookingService.getServices();
      services.assignAll(data);
    } catch (e) {
      print("💥 Controller ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectService(int index) {
    selectedIndex.value = index;
    _handleService(services[index]);
  }

  Future<void> _handleService(BookingServiceModel service) async {
    final type = _getServiceType(service);

    if (type == 'radiology') {
      Get.to(() => const RadiologyServicesScreen());
      return;
    }

    if (type == 'specialized') {
      await SpecializedCache.getData(); // warmup
      Get.to(
        () => DepartmentDoctorScreen(
          department: DepartmentModel(
            id: 'specialized_root',
            name: 'Specialized Clinics',
            subtitle: 'All specialties',
            icon: 'medical_services',
            description: '',
            doctors: const [],
          ),
          serviceType: 'specialized',
        ),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 350),
      );
      return;
    }

    // cosmetic
    Get.to(
      () => const CosmeticServicesScreen(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 350),
    );
  }

  String _getServiceType(BookingServiceModel service) {
    final title = service.titleEn.toLowerCase();
    final category = service.category.toLowerCase();

    if (title.contains('radiology') || category.contains('diagnostics')) {
      return 'radiology';
    } else if (title.contains('cosmetic') || category.contains('aesthetics')) {
      return 'cosmetic';
    } else {
      return 'specialized';
    }
  }
}

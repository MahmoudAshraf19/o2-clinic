import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/data/models/department_model.dart';
import '../../../services/data/services/fs_specialized_cache.dart';
import '../../data/models/booking_service_model.dart';
import '../../data/services/booking_service.dart';
import '../screens/radiology_services_screen.dart';
import '../widgets/department_doctor_widget.dart'; // فيه DepartmentDoctorScreen
import '../screens/cosmetic_services_screen.dart';
import '../../../services/data/models/cosmetic_category_model.dart';
import '../screens/cosmetic_booking_page.dart';

class BookingController extends GetxController {
  final services = <BookingServiceModel>[].obs;
  final selectedIndex = (-1).obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _preloadServices();
  }

  void _preloadServices() async {
    await loadServices(forceRefresh: false);
  }

  Future<void> loadServices({bool forceRefresh = true}) async {
    try {
      isLoading.value = true;
      final data = await BookingService.getServices(forceRefresh: forceRefresh);
      services.assignAll(data);
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

    if (type == 'direct') {
      isLoading.value = true;
      Map<String, dynamic> formattedAvailMap = {};
      try {
        // As requested by the user, both use Sleep_study_services document
        final doc = await FirebaseFirestore.instance
            .collection('service_day')
            .doc('Sleep_study_services')
            .get();
        final availMap =
            doc.data()?['availability_day'] as Map<String, dynamic>? ?? {};

        availMap.forEach((day, value) {
          if (value is Map) {
            final from = value['form'] ?? value['from'] ?? 9;
            final to = value['to'] ?? 21;
            final h1 = from.toString().padLeft(2, '0');
            final h2 = to.toString().padLeft(2, '0');
            formattedAvailMap[day.toString().toLowerCase()] = "$h1:00-$h2:00";
          }
        });
      } catch (e) {
        /* ignore */
      }
      isLoading.value = false;

      // Map to CosmeticCategoryModel so we can reuse CosmeticBookingPage
      final directModel = CosmeticCategoryModel(
        id: service.id,
        order: 0,
        nameMap: {
          'en': service.titleEn,
          'ar': service.titleAr,
          'he': service.titleHe,
        },
        descMap: {
          'en': service.descriptionEn,
          'ar': service.descriptionAr,
          'he': service.descriptionHe,
        },
        availabilityDay: formattedAvailMap,
        image: service.image,
        isActive: true,
        price: service.price, // Mapped correctly
      );

      Get.to(
        () => CosmeticBookingPage(model: directModel),
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
    } else if (service.id == 'Sleep_study' ||
        service.id == 'pulmonary_function') {
      return 'direct';
    } else {
      return 'specialized';
    }
  }
}

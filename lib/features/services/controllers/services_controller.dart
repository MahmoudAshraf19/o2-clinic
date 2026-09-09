import 'package:get/get.dart';

import '../../services_firestore/models/specialized_service_model.dart';
import '../../services_firestore/services/specialized_cache.dart';
import '../models/service_model.dart';

class ServicesController extends GetxController {
  final RxInt selectedTab = 0.obs;

  final RxBool isLoading = false.obs;

  RxList<ServiceModel> services = <ServiceModel>[].obs;

  final tabs = ["Specialized Clinics", "Radiology", "Cosmetic"];

  @override
  void onInit() {
    super.onInit();

    loadServices();
  }

  Future<void> loadServices() async {
    try {
      isLoading.value = true;

      final List<SpecializedServiceModel> data =
          await SpecializedCache.getData();

      services.assignAll(
        data.map((service) {
          return ServiceModel(
            id: service.id,
            title: service.nameEn,
            titleAr: service.nameAr,
            titleHe: service.nameHe,
            subtitle: service.subtitleEn,
            subtitleAr: service.subtitleAr,
            subtitleHe: service.subtitleHe,
            description: service.descriptionEn,
            descriptionAr: service.descriptionAr,
            descriptionHe: service.descriptionHe,
            image: service.image,
            doctorsCount: 0,
          );
        }).toList(),
      );

      print("✅ SERVICES LOADED: ${services.length}");
    } catch (e) {
      print("💥 ServicesController ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;

    update();
  }
}

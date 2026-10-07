import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/data/models/cosmetic_category_model.dart';
import '../../../services/data/services/cosmetic_category_service.dart';

class CosmeticServicesController extends GetxController {
  final _loading = true.obs;
  final _error = ''.obs;
  final _services = <CosmeticCategoryModel>[].obs;

  bool get loading => _loading.value;
  String get error => _error.value;
  List<CosmeticCategoryModel> get services => _services;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    try {
      _error.value = '';
      _loading.value = true;

      final data = await CosmeticCategoryService.instance
          .fetchCosmeticCategories(forceRefresh: forceRefresh);

      _services.assignAll(data);
    } catch (e, st) {
      debugPrint(
        "❌ [CosmeticServicesController] Error fetching services: $e\n$st",
      );
      _error.value =
          "Failed to load cosmetic services. Please try again later.";
    } finally {
      _loading.value = false;
    }
  }
}

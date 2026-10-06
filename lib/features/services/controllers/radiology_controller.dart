import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/models/radiology_category_model.dart';
import '../../services/services/radiology_category_service.dart';

class RadiologyController extends GetxController {
  final isLoading = true.obs;
  final services = <RadiologyCategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchRadiologyData();
  }

  Future<void> _fetchRadiologyData() async {
    try {
      isLoading.value = true;
      final data = await RadiologyCategoryService.instance
          .fetchRadiologyCategories();
      services.assignAll(data);
    } catch (e, st) {
      debugPrint("❌ [RadiologyController] Error fetching data: $e\n$st");
    } finally {
      isLoading.value = false;
    }
  }
}

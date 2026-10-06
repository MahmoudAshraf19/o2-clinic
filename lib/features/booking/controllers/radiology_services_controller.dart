import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/models/radiology_category_model.dart';
import '../../services/services/radiology_category_service.dart';

class RadiologyServicesController extends GetxController {
  final _loading = true.obs;
  final _error = ''.obs;
  final _services = <RadiologyCategoryModel>[].obs;

  bool get loading => _loading.value;
  String get error => _error.value;
  List<RadiologyCategoryModel> get services => _services;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    try {
      _error.value = '';
      _loading.value = true;

      final data = await RadiologyCategoryService.instance
          .fetchRadiologyCategories(forceRefresh: forceRefresh);

      _services.assignAll(data);
    } catch (e, st) {
      debugPrint(
        "❌ [RadiologyServicesController] Error fetching services: $e\n$st",
      );
      _error.value =
          "Failed to load radiology services. Please try again later.";
    } finally {
      _loading.value = false;
    }
  }
}

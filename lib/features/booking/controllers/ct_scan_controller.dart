import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services_firestore/models/ct_icon_model.dart';
import '../../services_firestore/models/radiology_ct_model.dart';
import '../../services_firestore/services/ct_icon_mapper.dart';
import '../../services_firestore/services/radiology_cache_service.dart';

class CtScanController extends GetxController {
  final loading = true.obs;

  final ctItems = <RadiologyCtModel>[].obs;

  final icons = <String, IconData>{}.obs;

  final selectedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    loading.value = true;

    final results = await Future.wait([
      RadiologyCacheService.getCtCategories(forceRefresh: forceRefresh),
      RadiologyCacheService.getCtIcons(forceRefresh: forceRefresh),
    ]);

    final items = results[0] as List<RadiologyCtModel>;

    final iconsList = results[1] as List<CtIconModel>;

    ctItems.assignAll(items);

    final mapped = <String, IconData>{};
    for (final ic in iconsList) {
      mapped[ic.id] = CtIconMapper.fromString(ic.icon);
    }
    icons.assignAll(mapped);

    loading.value = false;
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }
}

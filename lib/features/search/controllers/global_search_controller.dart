import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services_firestore/models/doctor_model.dart';
import '../../services_firestore/models/specialized_service_model.dart';
import '../../services_firestore/services/doctors_cache_service.dart';
import '../../services_firestore/services/specialized_cache.dart';

import '../../services/models/radiology_category_model.dart';
import '../../services/services/radiology_category_service.dart';

import '../../services/models/cosmetic_category_model.dart';
import '../../services/services/cosmetic_category_service.dart';

class GlobalSearchController extends GetxController {
  final TextEditingController textController = TextEditingController();

  final RxList<DoctorModel> _allDoctors = <DoctorModel>[].obs;
  final RxList<SpecializedServiceModel> _allSpecialties = <SpecializedServiceModel>[].obs;
  final RxList<RadiologyCategoryModel> _allRadiology = <RadiologyCategoryModel>[].obs;
  final RxList<CosmeticCategoryModel> _allCosmetics = <CosmeticCategoryModel>[].obs;

  final RxList<DoctorModel> filteredDoctors = <DoctorModel>[].obs;
  final RxList<SpecializedServiceModel> filteredSpecialties = <SpecializedServiceModel>[].obs;
  final RxList<RadiologyCategoryModel> filteredRadiology = <RadiologyCategoryModel>[].obs;
  final RxList<CosmeticCategoryModel> filteredCosmetics = <CosmeticCategoryModel>[].obs;

  final RxList<String> recentSearches = <String>[].obs;
  
  final RxBool isLoading = true.obs;
  final RxString query = ''.obs;

  Timer? _debounce;
  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  @override
  void onClose() {
    textController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _initData() async {
    isLoading.value = true;
    _prefs = await SharedPreferences.getInstance();
    
    // Load recent searches
    recentSearches.value = _prefs?.getStringList('global_recent_searches') ?? [];

    try {
      final results = await Future.wait([
        DoctorsCacheService.getDoctors(),
        SpecializedCache.getData(),
        RadiologyCategoryService.instance.fetchRadiologyCategories(),
        CosmeticCategoryService.instance.fetchCosmeticCategories(),
      ]);

      _allDoctors.value = results[0] as List<DoctorModel>;
      _allSpecialties.value = results[1] as List<SpecializedServiceModel>;
      _allRadiology.value = results[2] as List<RadiologyCategoryModel>;
      _allCosmetics.value = results[3] as List<CosmeticCategoryModel>;
      
    } catch (e) {
      debugPrint("💥 [GlobalSearch] Error loading data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 300), () {
      query.value = val.trim().toLowerCase();
      _filterResults();
    });
  }

  void submitSearch(String val) {
    final term = val.trim();
    if (term.isEmpty) return;
    
    if (!recentSearches.contains(term)) {
      recentSearches.insert(0, term);
      if (recentSearches.length > 8) {
        recentSearches.removeLast();
      }
      _prefs?.setStringList('global_recent_searches', recentSearches.toList());
    }
    
    textController.text = term;
    query.value = term.toLowerCase();
    _filterResults();
  }

  void removeRecentSearch(String val) {
    recentSearches.remove(val);
    _prefs?.setStringList('global_recent_searches', recentSearches.toList());
  }

  void clearRecentSearches() {
    recentSearches.clear();
    _prefs?.remove('global_recent_searches');
  }

  void _filterResults() {
    final q = query.value;
    if (q.isEmpty) {
      filteredDoctors.clear();
      filteredSpecialties.clear();
      filteredRadiology.clear();
      filteredCosmetics.clear();
      return;
    }

    final langCode = Get.locale?.languageCode ?? 'en';

    filteredDoctors.value = _allDoctors.where((d) =>
      d.nameEn.toLowerCase().contains(q) ||
      d.nameAr.toLowerCase().contains(q) ||
      d.specialty.toLowerCase().contains(q) ||
      d.titleEn.toLowerCase().contains(q) ||
      d.titleAr.toLowerCase().contains(q)
    ).toList();

    filteredSpecialties.value = _allSpecialties.where((s) =>
      (s.nameEn ?? '').toLowerCase().contains(q) ||
      (s.nameAr ?? '').toLowerCase().contains(q)
    ).toList();

    filteredRadiology.value = _allRadiology.where((r) =>
      r.getName(langCode).toLowerCase().contains(q) ||
      r.getDesc(langCode).toLowerCase().contains(q)
    ).toList();

    filteredCosmetics.value = _allCosmetics.where((c) =>
      c.getName(langCode).toLowerCase().contains(q) ||
      c.getDesc(langCode).toLowerCase().contains(q)
    ).toList();
  }
}

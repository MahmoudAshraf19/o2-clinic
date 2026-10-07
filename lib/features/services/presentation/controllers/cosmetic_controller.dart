import 'package:flutter/material.dart';

import '../../data/services/fs_cosmetic_cache_service.dart';
import '../../data/models/cosmetic_model.dart';
import '../../data/services/cosmetic_service.dart';

class CosmeticController extends ChangeNotifier {
  List<CosmeticModel> _cosmetics = [];
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  List<CosmeticModel> get cosmetics => _cosmetics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CosmeticController() {
    loadCosmetics();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> loadCosmetics() async {
    _setLoading(true);
    try {
      final categories = await CosmeticCacheService.getCategories();

      _cosmetics = categories.map((cat) {
        return CosmeticModel(
          id: cat.id,
          titleEn: cat.titleEn,
          titleAr: cat.titleAr,
          image: cat.image,
          itemsEn: cat.descriptionsEn,
          itemsAr: cat.descriptionsAr,
          buttonTextEn: cat.buttonTextEn,
          buttonTextAr: cat.buttonTextAr,
          price: cat.price.toDouble(),
          availabilityDay: cat.availabilityDay,
        );
      }).toList();

      if (_cosmetics.isEmpty) {
        _cosmetics =
            CosmeticService.getAllCosmetics(); // fallback to demo data if empty
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load cosmetics: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshCosmetics() async {
    await loadCosmetics();
  }

  List<CosmeticModel> searchCosmetics(String searchTerm) {
    if (searchTerm.isEmpty) {
      return _cosmetics;
    }
    return CosmeticService.getCosmeticsByTitle(searchTerm);
  }

  CosmeticModel? getCosmeticByIndex(int index) {
    return CosmeticService.getCosmeticByIndex(index);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

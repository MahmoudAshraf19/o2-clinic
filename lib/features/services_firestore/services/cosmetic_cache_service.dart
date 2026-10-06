import '../models/cosmetic_category_model.dart';
import 'cosmetic_firestore_service.dart';

class CosmeticCacheService {
  static final CosmeticFirestoreService _service = CosmeticFirestoreService();

  static List<CosmeticCategoryModel>? _cache;

  /// ⚡ GET FROM CACHE
  static Future<List<CosmeticCategoryModel>> getCategories() async {
    try {
      if (_cache != null) {
        return _cache!;
      }


      _cache = await _service.getCosmeticCategories();

      return _cache!;
    } catch (e) {
      return [];
    }
  }

  /// 🧹 CLEAR CACHE
  static void clearCache() {
    _cache = null;
  }
}

import '../models/cosmetic_category_model.dart';
import 'cosmetic_firestore_service.dart';

class CosmeticCacheService {
  static final CosmeticFirestoreService _service = CosmeticFirestoreService();

  static List<CosmeticCategoryModel>? _cache;

  /// ⚡ GET FROM CACHE
  static Future<List<CosmeticCategoryModel>> getCategories() async {
    try {
      if (_cache != null) {
        print("⚡ RETURNING COSMETIC FROM CACHE");
        return _cache!;
      }

      print("🌐 FETCHING COSMETIC FROM FIRESTORE");

      _cache = await _service.getCosmeticCategories();

      return _cache!;
    } catch (e) {
      print("💥 COSMETIC CACHE ERROR: $e");
      return [];
    }
  }

  /// 🧹 CLEAR CACHE
  static void clearCache() {
    print("🧹 COSMETIC CACHE CLEARED");
    _cache = null;
  }
}

import '../models/radiology_item_model.dart';
import 'radiology_firestore_service.dart';

class RadiologyCache {
  static final RadiologyFirestoreService _service =
      RadiologyFirestoreService.instance;

  static List<RadiologyItemModel>? _cache;

  static Future<List<RadiologyItemModel>> getData({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _cache != null && _cache!.isNotEmpty) {
        print("⚡ [RadiologyCache] HIT (${_cache!.length})");
        return _cache!;
      }

      print("🌐 [RadiologyCache] FETCHING FROM FIRESTORE");
      _cache = await _service.getAllRadiology();

      return _cache ?? [];
    } catch (e) {
      print("💥 [RadiologyCache] ERROR: $e");
      return _cache ?? [];
    }
  }

  static void clear() {
    print("🧹 [RadiologyCache] CLEARED");
    _cache = null;
  }
}

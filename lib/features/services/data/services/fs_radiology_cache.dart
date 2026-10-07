import '../models/fs_radiology_item_model.dart';
import 'fs_radiology_firestore_service.dart';

class RadiologyCache {
  static final RadiologyFirestoreService _service =
      RadiologyFirestoreService.instance;

  static List<RadiologyItemModel>? _cache;

  static Future<List<RadiologyItemModel>> getData({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _cache != null && _cache!.isNotEmpty) {
        return _cache!;
      }

      _cache = await _service.getAllRadiology();

      return _cache ?? [];
    } catch (e) {
      return _cache ?? [];
    }
  }

  static void clear() {
    _cache = null;
  }
}

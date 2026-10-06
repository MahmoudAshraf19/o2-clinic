import '../models/xray_data_model.dart';
import 'xray_data_firestore_service.dart';

class XrayDataCacheService {
  XrayDataCacheService._();

  static final XrayDataFirestoreService _service = XrayDataFirestoreService();
  static XrayCatalog? _cache;

  static Future<XrayCatalog> getCatalog({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cache != null) {
        return _cache!;
      }

      _cache = await _service.getCatalog();
      return _cache!;
    } catch (_) {
      return XrayCatalog.empty();
    }
  }

  static Future<List<XrayServiceModel>> getAllXrayData({
    bool forceRefresh = false,
  }) async {
    final catalog = await getCatalog(forceRefresh: forceRefresh);
    return catalog.services;
  }

  static Future<List<XrayServiceModel>> getXrayByCategory(
    String categoryId, {
    bool forceRefresh = false,
  }) async {
    final catalog = await getCatalog(forceRefresh: forceRefresh);
    return catalog.servicesByCategory[categoryId] ?? const <XrayServiceModel>[];
  }

  static void clearCache() {
    _cache = null;
  }
}

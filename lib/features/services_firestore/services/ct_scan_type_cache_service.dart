import '../models/ct_scan_type_model.dart';
import 'ct_scan_type_firestore_service.dart';

class CtScanTypeCacheService {
  static final CtScanTypeFirestoreService _service =
      CtScanTypeFirestoreService();

  static List<CtScanTypeModel>? _cache;

  /// ⚡ FAST CACHE FETCH
  static Future<List<CtScanTypeModel>> getCtScanTypes() async {
    try {
      if (_cache != null) {
        print("⚡ RETURNING CT SCAN TYPES FROM CACHE");

        return _cache!;
      }

      print("🌐 FETCHING CT SCAN TYPES FROM FIRESTORE");

      _cache = await _service.getCtScanTypes();

      return _cache!;
    } catch (e) {
      print("💥 CT SCAN TYPE CACHE ERROR: $e");

      return [];
    }
  }

  /// 🧹 CLEAR CACHE
  static void clearCache() {
    print("🧹 CT SCAN TYPE CACHE CLEARED");

    _cache = null;
  }
}

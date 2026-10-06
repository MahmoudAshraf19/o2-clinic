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

        return _cache!;
      }


      _cache = await _service.getCtScanTypes();

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

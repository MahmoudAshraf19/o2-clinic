import '../models/ct_icon_model.dart';
import '../models/radiology_ct_model.dart';
import '../models/radiology_ultrasound_model.dart';
import '../models/radiology_xray_model.dart';
import 'radiology_firestore_service.dart';

class RadiologyCacheService {
  static final RadiologyFirestoreService _service =
      RadiologyFirestoreService.instance;

  static List<RadiologyCtModel>? _ctCache;
  static List<RadiologyXrayModel>? _xrayCache;
  static List<RadiologyUltrasoundModel>? _ultrasoundCache;

  static List<CtIconModel>? _ctIconsCache;

  static Future<List<RadiologyCtModel>> getCtCategories({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _ctCache != null) {
        print("⚡ [RadiologyCache] CT HIT (${_ctCache!.length})");
        return _ctCache!;
      }

      print("🌐 [RadiologyCache] CT FETCH");
      _ctCache = await _service.getCtCategories();
      return _ctCache ?? [];
    } catch (e) {
      print("💥 [RadiologyCache] CT ERROR: $e");
      return _ctCache ?? [];
    }
  }

  static Future<List<CtIconModel>> getCtIcons({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _ctIconsCache != null) {
        print("⚡ [RadiologyCache] CT ICONS HIT (${_ctIconsCache!.length})");
        return _ctIconsCache!;
      }

      print("🌐 [RadiologyCache] CT ICONS FETCH");
      _ctIconsCache = await _service.getCtIcons();
      return _ctIconsCache ?? [];
    } catch (e) {
      print("💥 [RadiologyCache] CT ICONS ERROR: $e");
      return _ctIconsCache ?? [];
    }
  }

  static Future<List<RadiologyXrayModel>> getXrayCategories({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _xrayCache != null) {
        print("⚡ [RadiologyCache] X-RAY HIT (${_xrayCache!.length})");
        return _xrayCache!;
      }

      print("🌐 [RadiologyCache] X-RAY FETCH");
      _xrayCache = await _service.getXrayCategories();
      return _xrayCache ?? [];
    } catch (e) {
      print("💥 [RadiologyCache] X-RAY ERROR: $e");
      return _xrayCache ?? [];
    }
  }

  static Future<List<RadiologyUltrasoundModel>> getUltrasoundCategories({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _ultrasoundCache != null) {
        print(
          "⚡ [RadiologyCache] ULTRASOUND HIT (${_ultrasoundCache!.length})",
        );
        return _ultrasoundCache!;
      }

      print("🌐 [RadiologyCache] ULTRASOUND FETCH");
      _ultrasoundCache = await _service.getUltrasoundCategories();
      return _ultrasoundCache ?? [];
    } catch (e) {
      print("💥 [RadiologyCache] ULTRASOUND ERROR: $e");
      return _ultrasoundCache ?? [];
    }
  }

  static void clearCache() {
    print("🧹 [RadiologyCache] CLEARED");
    _ctCache = null;
    _xrayCache = null;
    _ultrasoundCache = null;
    _ctIconsCache = null;
  }
}

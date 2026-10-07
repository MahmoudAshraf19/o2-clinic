import '../models/fs_ct_icon_model.dart';
import '../models/fs_radiology_ct_model.dart';
import '../models/fs_radiology_ultrasound_model.dart';
import '../models/fs_radiology_xray_model.dart';
import 'fs_radiology_firestore_service.dart';

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
        return _ctCache!;
      }

      _ctCache = await _service.getCtCategories();
      return _ctCache ?? [];
    } catch (e) {
      return _ctCache ?? [];
    }
  }

  static Future<List<CtIconModel>> getCtIcons({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _ctIconsCache != null) {
        return _ctIconsCache!;
      }

      _ctIconsCache = await _service.getCtIcons();
      return _ctIconsCache ?? [];
    } catch (e) {
      return _ctIconsCache ?? [];
    }
  }

  static Future<List<RadiologyXrayModel>> getXrayCategories({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _xrayCache != null) {
        return _xrayCache!;
      }

      _xrayCache = await _service.getXrayCategories();
      return _xrayCache ?? [];
    } catch (e) {
      return _xrayCache ?? [];
    }
  }

  static Future<List<RadiologyUltrasoundModel>> getUltrasoundCategories({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _ultrasoundCache != null) {
        return _ultrasoundCache!;
      }

      _ultrasoundCache = await _service.getUltrasoundCategories();
      return _ultrasoundCache ?? [];
    } catch (e) {
      return _ultrasoundCache ?? [];
    }
  }

  static void clearCache() {
    _ctCache = null;
    _xrayCache = null;
    _ultrasoundCache = null;
    _ctIconsCache = null;
  }
}

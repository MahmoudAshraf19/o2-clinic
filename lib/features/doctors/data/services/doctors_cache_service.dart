import '../../../../common/models/fs_doctor_model.dart';
import 'doctors_firestore_service.dart';

class DoctorsCacheService {
  static final DoctorsFirestoreService _service = DoctorsFirestoreService();

  static List<DoctorModel>? _cache;

  /// ⚡ FAST CACHE FETCH
  static Future<List<DoctorModel>> getDoctors() async {
    try {
      if (_cache != null) {
        return _cache!;
      }

      _cache = await _service.getAllDoctors();

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

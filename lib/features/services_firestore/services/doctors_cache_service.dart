import '../models/doctor_model.dart';
import 'doctors_firestore_service.dart';

class DoctorsCacheService {
  static final DoctorsFirestoreService _service = DoctorsFirestoreService();

  static List<DoctorModel>? _cache;

  /// ⚡ FAST CACHE FETCH
  static Future<List<DoctorModel>> getDoctors() async {
    try {
      if (_cache != null) {
        print("⚡ RETURNING FROM CACHE");
        return _cache!;
      }

      print("🌐 FETCHING FROM FIRESTORE");

      _cache = await _service.getAllDoctors();

      return _cache!;
    } catch (e) {
      print("💥 CACHE ERROR: $e");
      return [];
    }
  }

  /// 🧹 CLEAR CACHE
  static void clearCache() {
    print("🧹 CACHE CLEARED");
    _cache = null;
  }
}

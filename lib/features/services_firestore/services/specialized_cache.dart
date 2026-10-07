import '../models/specialized_service_model.dart';
import 'specialized_firestore_service.dart';

class SpecializedCache {
  static final SpecializedFirestoreService _service =
      SpecializedFirestoreService.instance;

  static List<SpecializedServiceModel>? _cache;

  static Future<List<SpecializedServiceModel>> getData() async {
    try {
      if (_cache != null && _cache!.isNotEmpty) {
        return _cache!;
      }

      _cache = await _service.getAllSpecialized();

      return _cache ?? [];
    } catch (e) {
      return _cache ?? [];
    }
  }

  static void clear() {
    _cache = null;
  }
}

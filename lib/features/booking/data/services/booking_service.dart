import '../../../services/data/services/fs_services_firestore_service.dart';
import '../models/booking_service_model.dart';

class BookingService {
  static final ServicesFirestoreService _service = ServicesFirestoreService();

  /// 🧠 MEMORY CACHE (instant load)
  static List<BookingServiceModel>? _cache;

  static Future<List<BookingServiceModel>> getServices({
    bool forceRefresh = false,
  }) async {
    try {
      /// ⚡ لو موجود في الكاش → رجعه فورًا
      if (!forceRefresh && _cache != null) {
        return _cache!;
      }

      final firestoreServices = await _service.getAllServices(
        forceRefresh: forceRefresh,
      );

      final result = firestoreServices.map((e) {
        return BookingServiceModel(
          id: e.id,
          titleEn: e.titleEn,
          titleAr: e.titleAr,
          titleHe: e.titleHe,
          descriptionEn: e.descriptionEn,
          descriptionAr: e.descriptionAr,
          descriptionHe: e.descriptionHe,
          category: _mapCategory(e.id),
          image: e.image,
          price: e.price,
        );
      }).toList();

      /// 💾 خزّن في الكاش
      _cache = result;

      return result;
    } catch (e) {
      return _cache ?? [];
    }
  }

  /// 🧹 لو عايز تعمل refresh
  static void clearCache() {
    _cache = null;
  }

  static String _mapCategory(String id) {
    switch (id) {
      case 'svc_radiology':
        return 'Diagnostics';
      case 'svc_cosmetic':
        return 'Aesthetics';
      case 'svc_clinics':
        return 'Internal Medicine';
      default:
        return 'General';
    }
  }
}

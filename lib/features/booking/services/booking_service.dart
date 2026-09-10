import 'package:get/get.dart';

import '../../services_firestore/services/services_firestore_service.dart';
import '../models/booking_service_model.dart';

class BookingService {
  static final ServicesFirestoreService _service = ServicesFirestoreService();

  /// 🧠 MEMORY CACHE (instant load)
  static List<BookingServiceModel>? _cache;

  static Future<List<BookingServiceModel>> getServices({bool forceRefresh = false}) async {
    try {
      print("🚀 [BookingService] REQUEST SERVICES");

      /// ⚡ لو موجود في الكاش → رجعه فورًا
      if (!forceRefresh && _cache != null) {
        print("⚡ RETURNING FROM CACHE (${_cache!.length})");
        return _cache!;
      }

      print("🌐 FETCHING FROM FIREBASE...");

      final firestoreServices = await _service.getAllServices(forceRefresh: forceRefresh);

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

      print("💾 CACHE SAVED (${result.length})");

      return result;
    } catch (e) {
      print("💥 ERROR: $e");
      return _cache ?? [];
    }
  }

  /// 🧹 لو عايز تعمل refresh
  static void clearCache() {
    print("🧹 CACHE CLEARED");
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

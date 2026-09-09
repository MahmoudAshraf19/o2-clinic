import '../models/booking_model.dart';
import 'bookings_firestore_service.dart';

class BookingsCacheService {
  static final BookingsFirestoreService _service = BookingsFirestoreService();

  static List<BookingModel>? _cache;

  /// ⚡ FAST CACHE FETCH
  static Future<List<BookingModel>> getBookings() async {
    try {
      if (_cache != null) {
        print("⚡ RETURNING BOOKINGS FROM CACHE");

        return _cache!;
      }

      print("🌐 FETCHING BOOKINGS FROM FIRESTORE");

      _cache = await _service.getAllBookings();

      return _cache!;
    } catch (e) {
      print("💥 BOOKINGS CACHE ERROR: $e");

      return [];
    }
  }

  /// 🧹 CLEAR CACHE
  static void clearCache() {
    print("🧹 BOOKINGS CACHE CLEARED");

    _cache = null;
  }
}

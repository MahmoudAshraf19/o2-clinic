import '../../data/models/fs_booking_model.dart';
import 'fs_bookings_firestore_service.dart';

class BookingsCacheService {
  static final BookingsFirestoreService _service = BookingsFirestoreService();

  static List<BookingModel>? _cache;

  /// ⚡ FAST CACHE FETCH
  static Future<List<BookingModel>> getBookings() async {
    try {
      if (_cache != null) {
        return _cache!;
      }

      _cache = await _service.getAllBookings();

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

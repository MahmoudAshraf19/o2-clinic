import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_paths.dart';

class BookingFirestoreService {
  BookingFirestoreService._();

  static final BookingFirestoreService instance = BookingFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBooking({
    required String bookingId,
    required Map<String, dynamic> bookingData,
  }) async {
    await _firestore
        .collection(FirestorePaths.bookings)
        .doc(bookingId)
        .set(bookingData);
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    final result = await _firestore
        .collection(FirestorePaths.bookings)
        .where("user_id", isEqualTo: userId)
        .orderBy("created_at", descending: true)
        .get();

    return result.docs.map((e) => e.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getDoctorBookings(String doctorId) async {
    final result = await _firestore
        .collection(FirestorePaths.bookings)
        .where("doctor_id", isEqualTo: doctorId)
        .get();

    return result.docs.map((e) => e.data()).toList();
  }

  Future<bool> isSlotAvailable({
    required String doctorId,
    required String dayId,
    required String from,
    required String to,
    required int maxBookings,
  }) async {
    final result = await _firestore
        .collection(FirestorePaths.bookings)
        .where("doctor_id", isEqualTo: doctorId)
        .where("day_id", isEqualTo: dayId)
        .where("from", isEqualTo: from)
        .where("to", isEqualTo: to)
        .where("status", isEqualTo: "confirmed")
        .get();

    return result.docs.length < maxBookings;
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await _firestore.collection(FirestorePaths.bookings).doc(bookingId).update({
      "status": status,
      "updated_at": FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBooking(String bookingId) async {
    await _firestore
        .collection(FirestorePaths.bookings)
        .doc(bookingId)
        .delete();
  }

  Future<void> cancelBooking(Map<String, dynamic> bookingData) async {
    final bookingId = bookingData['id'];
    if (bookingId == null) {
      debugPrint("⚠️ [Firebase] Cannot cancel booking: ID is null ❌");
      return;
    }
    
    debugPrint("🚀 [Firebase] Starting cancellation for booking: $bookingId ⏳");

    try {
      await _firestore.runTransaction((tx) async {
        final bookingRef = _firestore.collection(FirestorePaths.bookings).doc(bookingId);
        final bookingSnap = await tx.get(bookingRef);
        if (!bookingSnap.exists) {
          debugPrint("⚠️ [Firebase] Booking not found! $bookingId ❌");
          return;
        }

        final data = bookingSnap.data()!;
        final type = data['type'];
        final doctor = data['doctor'];
        final schedule = data['schedule'];

        if ((type == 'clinical' || data['serviceType'] == 'clinical') && 
            doctor != null && (doctor['id'] != null || doctor['doctorId'] != null) && 
            schedule != null && schedule['date'] != null) {
          
          final doctorId = doctor['id'] ?? doctor['doctorId'];
          final dateKey = schedule['date'];
          final statsId = "${doctorId}_$dateKey";
          final statsRef = _firestore.collection('doctor_booking_stats').doc(statsId);
          
          final statsSnap = await tx.get(statsRef);
          if (statsSnap.exists) {
            final count = ((statsSnap.data()?['count'] ?? 0) as num).toInt();
            if (count > 0) {
              tx.update(statsRef, {'count': count - 1});
              debugPrint("✅ [Firebase] Decremented doctor stats for $statsId 📉");
            } else {
              debugPrint("⚠️ [Firebase] Doctor stats count is already 0 for $statsId 🤔");
            }
          } else {
            debugPrint("⚠️ [Firebase] Doctor stats document not found! $statsId ❌");
          }
        }

        final currentStatus = data['status'] as Map<String, dynamic>? ?? {};
        final rawHistory = currentStatus['history'] as List<dynamic>? ?? [];
        final history = rawHistory.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        
        history.add({
          "status": "cancelled",
          "changed_at": FieldValue.serverTimestamp(),
          "changed_by": "user",
          "note": "Cancelled by user via app"
        });

        tx.update(bookingRef, {
          "status.current": "cancelled",
          "status.history": history,
          "timeline.cancelledAt": FieldValue.serverTimestamp(),
        });
        
        debugPrint("✅ [Firebase] Booking $bookingId updated successfully to 'cancelled'! 🎉");
      });
    } catch (e, stackTrace) {
      debugPrint("🔥 [Firebase] FATAL ERROR during cancellation 😭: $e");
      debugPrint("🔥 [Firebase] STACKTRACE 🩸:\n$stackTrace");
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> streamBookings() {
    return _firestore
        .collection(FirestorePaths.bookings)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());
  }
}

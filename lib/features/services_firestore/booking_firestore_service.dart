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

  Stream<List<Map<String, dynamic>>> streamBookings() {
    return _firestore
        .collection(FirestorePaths.bookings)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());
  }
}

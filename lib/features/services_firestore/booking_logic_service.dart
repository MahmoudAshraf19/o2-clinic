import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_paths.dart';

class BookingLogicService {
  BookingLogicService._();

  static final BookingLogicService instance = BookingLogicService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> createDoctorBooking({
    required String bookingId,
    required String doctorId,
    required String userId,
    required String dayId,
    required String from,
    required String to,
    required int maxBookings,
    required Map<String, dynamic> bookingData,
  }) async {
    return await _firestore.runTransaction<bool>((transaction) async {
      final query = await _firestore
          .collection(FirestorePaths.bookings)
          .where("doctor_id", isEqualTo: doctorId)
          .where("day_id", isEqualTo: dayId)
          .where("from", isEqualTo: from)
          .where("to", isEqualTo: to)
          .where("status", isEqualTo: "confirmed")
          .get();

      if (query.docs.length >= maxBookings) {
        return false;
      }

      final bookingRef = _firestore
          .collection(FirestorePaths.bookings)
          .doc(bookingId);

      transaction.set(bookingRef, bookingData);

      return true;
    });
  }
}

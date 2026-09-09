import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../models/booking_model.dart';

class BookingsFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BookingsFirestoreService();

  /// 🚀 GET ALL BOOKINGS
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final snapshot = await _firestore
          .collection("bookings")
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) return [];

      final List<BookingModel> bookings = [];
      for (final doc in snapshot.docs) {
        try {
          bookings.add(BookingModel.fromMap(id: doc.id, map: doc.data()));
        } catch (e) {
          debugPrint("💥 BOOKING PARSE ERROR [${doc.id}]: $e");
        }
      }
      return bookings;
    } catch (e) {
      debugPrint("💥 BOOKINGS ERROR: $e");
      return [];
    }
  }

  /// 🚀 GET BOOKINGS BY USER ID
  Future<List<BookingModel>> getBookingsByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection("bookings")
          .where("user.userId", isEqualTo: userId)
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs.map((doc) {
        return BookingModel.fromMap(id: doc.id, map: doc.data());
      }).toList();
    } catch (e) {
      debugPrint("💥 USER BOOKINGS ERROR: $e");
      return [];
    }
  }

  /// 🚀 GET BOOKINGS BY TYPE
  Future<List<BookingModel>> getBookingsByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection("bookings")
          .where("type", isEqualTo: type)
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs.map((doc) {
        return BookingModel.fromMap(id: doc.id, map: doc.data());
      }).toList();
    } catch (e) {
      debugPrint("💥 TYPE BOOKINGS ERROR: $e");
      return [];
    }
  }

  /// 🚀 STREAM BOOKINGS BY USER ID
  /// Also syncs local reminders each time data changes.
  Stream<List<BookingModel>> streamBookingsByUserId(String userId) {
    return _firestore
        .collection("bookings")
        .where("user.userId", isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs.map((doc) {
        return BookingModel.fromMap(id: doc.id, map: doc.data());
      }).toList();

      // ✅ Sync local reminders asynchronously — doesn't block the UI stream
      _syncLocalReminders(bookings);

      return bookings;
    });
  }

  /// ✅ Schedules local on-device reminders for all upcoming bookings.
  /// These work even when the device is offline.
  /// Safely cancels + re-schedules to avoid duplicate or stale reminders.
  void _syncLocalReminders(List<BookingModel> bookings) {
    // Run async without blocking the stream
    Future.microtask(() async {
      try {
        final langCode = Get.locale?.languageCode ?? 'en';

        for (final booking in bookings) {
          final status = booking.status.current.toLowerCase();

          // Only schedule for active/upcoming bookings
          final isActive = status == 'upcoming' ||
              status == 'confirmed' ||
              status == 'pending';

          if (!isActive) {
            // ✅ Cancel reminders for cancelled/completed bookings
            if (status == 'cancelled' || status == 'completed') {
              await NotificationService.instance
                  .cancelAppointmentReminders(booking.id);
            }
            continue;
          }

          final appointmentDate = booking.schedule.timestamp?.toDate();

          // Must have a valid future date to schedule
          if (appointmentDate == null ||
              appointmentDate.isBefore(DateTime.now())) {
            continue;
          }

          // Schedule both 12h and 3h reminders
          await NotificationService.instance.scheduleAppointmentReminders(
            bookingId: booking.id,
            appointmentDate: appointmentDate,
            langCode: langCode,
            userId: booking.user.userId,
          );
        }
      } catch (e) {
        debugPrint("⚠️ Failed to sync local reminders: $e");
      }
    });
  }
}

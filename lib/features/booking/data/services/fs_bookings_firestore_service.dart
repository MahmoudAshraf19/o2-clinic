import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/services/notification_service.dart';
import '../../data/models/fs_booking_model.dart';

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
          final isActive =
              status == 'upcoming' ||
              status == 'confirmed' ||
              status == 'pending';

          if (!isActive) {
            // ✅ Cancel reminders for cancelled/completed bookings
            if (status == 'cancelled' || status == 'completed') {
              await NotificationService.instance.cancelAppointmentReminders(
                booking.id,
              );
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

  /// 🚀 UPDATE BOOKING STATUS
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      // 1. Update the booking status
      await _firestore.collection('bookings').doc(bookingId).update({
        'status.current': status,
      });

      // 2. Fetch the booking to get user details for the notification
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      final userMap = data['user'] as Map<String, dynamic>?;
      if (userMap == null) return;
      final userId = userMap['userId'] ?? userMap['auth_uid'];
      if (userId == null || userId.toString().isEmpty) return;

      // 3. Prepare notification details based on status
      String titleEn = 'Booking Update';
      String titleAr = 'تحديث الحجز';
      String bodyEn = 'Your booking has been updated.';
      String bodyAr = 'تم تحديث حالة حجزك.';

      if (status == 'completed') {
        bodyEn =
            'Your appointment has been completed. You can now rate your experience!';
        bodyAr = 'تم الانتهاء من موعدك. يمكنك الآن تقييم تجربتك!';
      } else if (status == 'under_investigation') {
        titleEn = 'Issue Reported';
        titleAr = 'تم الإبلاغ عن مشكلة';
        bodyEn =
            'An issue was reported for your booking. We are investigating it.';
        bodyAr = 'تم الإبلاغ عن مشكلة في حجزك. نحن نقوم بالتحقيق فيها.';
      }

      // 4. Create the notification document
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'booking',
        'title': {'en': titleEn, 'ar': titleAr},
        'body': {'en': bodyEn, 'ar': bodyAr},
        'data': {'bookingId': bookingId},
        'priority': 'high',
        'status': {'read': false},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("💥 Failed to update booking status: $e");
      rethrow;
    }
  }

  Future<void> cancelBooking(BookingModel booking) async {
    final bookingId = booking.id;
    debugPrint("🚀 [Firebase] Starting cancellation for booking: $bookingId ⏳");

    try {
      await _firestore.runTransaction((tx) async {
        final bookingRef = _firestore.collection("bookings").doc(bookingId);
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
            doctor != null &&
            (doctor['id'] != null || doctor['doctorId'] != null) &&
            schedule != null &&
            schedule['date'] != null) {
          final doctorId = doctor['id'] ?? doctor['doctorId'];
          final dateKey = schedule['date'];
          final statsId = "${doctorId}_$dateKey";
          final statsRef = _firestore
              .collection('doctor_booking_stats')
              .doc(statsId);

          final statsSnap = await tx.get(statsRef);
          if (statsSnap.exists) {
            final count = ((statsSnap.data()?['count'] ?? 0) as num).toInt();
            if (count > 0) {
              tx.update(statsRef, {'count': count - 1});
              debugPrint(
                "✅ [Firebase] Decremented doctor stats for $statsId 📉",
              );
            } else {
              debugPrint(
                "⚠️ [Firebase] Doctor stats count is already 0 for $statsId 🤔",
              );
            }
          } else {
            debugPrint(
              "⚠️ [Firebase] Doctor stats document not found! $statsId ❌",
            );
          }
        }

        final currentStatus = data['status'] as Map<String, dynamic>? ?? {};
        final rawHistory = currentStatus['history'] as List<dynamic>? ?? [];
        final history = rawHistory
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        history.add({
          "status": "cancelled",
          "changed_at": Timestamp.now(),
          "changed_by": "user",
          "note": "Cancelled by user via app",
        });

        tx.update(bookingRef, {
          "status.current": "cancelled",
          "status.label": "Cancelled",
          "status.history": history,
          "timeline.cancelledAt": FieldValue.serverTimestamp(),
        });

        debugPrint(
          "✅ [Firebase] Booking $bookingId updated successfully to 'cancelled'! 🎉",
        );

        // Prepare User Notification
        final userMap = data['user'] as Map<String, dynamic>?;
        final userId = userMap?['userId'] ?? userMap?['auth_uid'];
        if (userId != null && userId.toString().isNotEmpty) {
          final userNotifRef = _firestore.collection('notifications').doc();
          tx.set(userNotifRef, {
            'userId': userId,
            'type': 'booking_cancelled',
            'title': {'en': 'Booking Cancelled', 'ar': 'تم إلغاء الحجز'},
            'body': {
              'en': 'Your booking has been successfully cancelled.',
              'ar': 'تم إلغاء حجزك بنجاح بناءً على طلبك.',
            },
            'data': {'bookingId': bookingId},
            'priority': 'high',
            'status': {'read': false},
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Prepare Admin Notification
        final adminNotifRef = _firestore
            .collection('admin_notifications')
            .doc();
        tx.set(adminNotifRef, {
          'kind': 'booking.deleted',
          'tone': 'danger',
          'title': {
            'en': 'Booking Cancelled by User',
            'ar': 'قام المريض بإلغاء حجزه',
          },
          'body': {
            'en': 'A user has cancelled their booking (ID: $bookingId).',
            'ar': 'قام المريض بإلغاء حجزه (رقم: $bookingId).',
          },
          'bookingId': bookingId,
          'link': '/bookings/$bookingId',
          'actor': userId ?? 'user',
          'read': false,
          'readAt': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e, stackTrace) {
      debugPrint("🔥 [Firebase] FATAL ERROR during cancellation 😭: $e");
      debugPrint("🔥 [Firebase] STACKTRACE 🩸:\n$stackTrace");
      rethrow;
    }
  }
}

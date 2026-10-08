import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/services/notification_service.dart';
import '../../data/models/fs_booking_model.dart';
import '../../../../common/models/fs_doctor_model.dart';
import '../models/booking_request_models.dart';


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


  // --- CREATION METHODS MOVED FROM booking.dart ---
  String _getDiscountErrorMessage(String key) {
      final lang = Get.locale?.languageCode ?? 'ar';
      if (key == 'not_active') {
        if (lang == 'en') return "Discount code is no longer active.";
        if (lang == 'he') return "קוד ההנחה אינו פעיל יותר.";
        return "كود الخصم لم يعد فعالاً.";
      }
      if (key == 'limit_reached') {
        if (lang == 'en') return "Discount code usage limit reached.";
        if (lang == 'he') return "הגעת להגבלת השימוש בקוד ההנחה.";
        return "تم الوصول للحد الأقصى لاستخدام كود الخصم.";
      }
      return key;
    }
  
    static String formatDate(DateTime d) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return "$y-$m-$day";
    }
  
    static Timestamp buildTimestamp(DateTime date, String time) {
      try {
        // time could be: "14:00", "01:00 PM", or "14:00 - 17:00"
        final clean = time.split('-').first.trim();
        final parts = clean.split(':');
  
        var h = int.tryParse(parts[0].trim()) ?? 0;
        final rest = parts.length > 1 ? parts[1].trim() : '00';
  
        var min = 0;
        bool isPM = clean.toLowerCase().contains('pm');
        bool isAM = clean.toLowerCase().contains('am');
  
        if (isPM || isAM) {
          min = int.tryParse(rest.split(' ')[0]) ?? 0;
          if (isPM && h < 12) h += 12;
          if (isAM && h == 12) h = 0;
        } else {
          min = int.tryParse(rest) ?? 0;
        }
  
        final dt = DateTime(date.year, date.month, date.day, h, min);
        return Timestamp.fromDate(dt);
      } catch (_) {
        return Timestamp.fromDate(date);
      }
    }
  
    /// stats doc id => Doctor_1_2026-05-23
    static String statsDocId(String doctorId, String dateKey) =>
        "${doctorId}_$dateKey";
  
    /// ===============================
    /// CREATE CLINICAL BOOKING (SAFE)
    /// ===============================
    Future<BookingResult> createClinicalBooking({
      required BookingUserInfo user,
      required DoctorModel doctor,
      required DateTime selectedDate,
      required String selectedTime,
      int durationMinutes = 30,
      String clinicName = "O2 Clinic - Main Branch",
      String floor = "4",
      String room = "",
      String paymentStatus = "pending",
      String paymentMethod = "cash",
      String currency = "EGP",
      num? amountOverride,
      String appVersion = "8.8",
      Map<String, dynamic>? discountData,
      bool isOnline = false,
    }) async {
      try {
        final maxBookings = doctor.maxBooking <= 0 ? 1 : doctor.maxBooking;
  
        final dateKey = formatDate(selectedDate);
        final statsId = statsDocId(doctor.id, dateKey);
  
        final statsRef = _firestore
            .collection("doctor_booking_stats")
            .doc(statsId);
        final ts = buildTimestamp(selectedDate, selectedTime);
        final counterRef = _firestore.collection("counters").doc("bookings");
  
        return await _firestore.runTransaction<BookingResult>((tx) async {
          // ✅ 1. ALL READS FIRST!
          final statsSnap = await tx.get(statsRef);
          final counterSnap = await tx.get(counterRef);
  
          DocumentReference? discountRef;
          DocumentSnapshot? discountSnap;
          if (discountData != null && discountData['code_id'] != null) {
            discountRef = _firestore
                .collection("discount_codes")
                .doc(discountData['code_id']);
            discountSnap = await tx.get(discountRef);
  
            if (discountSnap.exists) {
              final data = discountSnap.data() as Map<String, dynamic>? ?? {};
              final status = data['status'] as String?;
              final usageLimit = (data['usage_limit'] ?? -1) as int;
              final usedCount = (data['used_count'] ?? 0) as int;
  
              if (status != 'active') {
                return BookingResult(
                  success: false,
                  message: _getDiscountErrorMessage('not_active'),
                  bookingId: null,
                  bookedCount: 0,
                  maxBookings: 0,
                );
              }
              if (usageLimit != -1 && usedCount >= usageLimit) {
                return BookingResult(
                  success: false,
                  message: _getDiscountErrorMessage('limit_reached'),
                  bookingId: null,
                  bookedCount: 0,
                  maxBookings: 0,
                );
              }
            }
          }
  
          final int currentCount = statsSnap.exists
              ? ((statsSnap.data()?['count'] ?? 0) as num).toInt()
              : 0;
  
          if (currentCount >= maxBookings) {
            return BookingResult(
              success: false,
              message: "This slot is full",
              bookingId: null,
              bookedCount: currentCount,
              maxBookings: maxBookings,
            );
          }
  
          final newCount = currentCount + 1;
  
          // ✅ Sequential ID logic
          int currentSeq = 1000;
          if (counterSnap.exists) {
            currentSeq = ((counterSnap.data()?['clinical'] ?? 1000) as num)
                .toInt();
          }
          final newSeq = currentSeq + 1;
  
          // ✅ 2. ALL WRITES AFTER READS
          if (!statsSnap.exists) {
            tx.set(statsRef, {
              "id": statsId,
              "doctorId": doctor.id,
              "date": dateKey,
              "count": newCount,
              "maxBooking": maxBookings,
              "createdAt": FieldValue.serverTimestamp(),
              "updatedAt": FieldValue.serverTimestamp(),
            });
          } else {
            tx.update(statsRef, {
              "count": newCount,
              "updatedAt": FieldValue.serverTimestamp(),
            });
          }
  
          tx.set(counterRef, {'clinical': newSeq}, SetOptions(merge: true));
  
          if (discountRef != null &&
              discountSnap != null &&
              discountSnap.exists) {
            final data = discountSnap.data() as Map<String, dynamic>? ?? {};
            final usageLimit = (data['usage_limit'] ?? -1) as int;
            final usedCount = (data['used_count'] ?? 0) as int;
  
            final newUsedCount = usedCount + 1;
            final updates = <String, dynamic>{"used_count": newUsedCount};
            if (usageLimit != -1 && newUsedCount >= usageLimit) {
              updates["status"] = "expired";
            }
            tx.update(discountRef, updates);
          }
  
          final bookingId = "O2-SPC-$newSeq";
          final bookingRef = _firestore.collection("bookings").doc(bookingId);
  
          // ✅ create booking doc (matching your schema)
          final bookingData = <String, dynamic>{
            "id": bookingId,
  
            "user": user.toMap(),
  
            // ✅ type: clinical | imaging | cosmetic | online
            "type": isOnline ? "online" : "clinical",
  
            "service": {
              "serviceId": "svc_clinics",
              "serviceName_en": "Specialized Clinics",
              "serviceName_ar": "العيادات التخصصية",
            },
  
            "doctor": {
              "doctorId": doctor.id,
              "name_en": doctor.nameEn,
              "name_ar": doctor.nameAr,
              "specialty": doctor.specialty,
              "image": doctor.image,
            },
  
            // null لأن ده clinical
            "imaging": null,
            "cosmetic": null,
  
            "schedule": {
              "date": dateKey,
              "time": selectedTime,
              "timestamp": ts,
              "duration_minutes": durationMinutes,
            },
  
            "location": {"clinic": clinicName, "floor": floor, "room": room},
  
            "payment": {
              "status": paymentStatus,
              "method": paymentMethod,
              "amount": amountOverride ?? doctor.price,
              "currency": currency,
              "discount": ?discountData,
            },
  
            "status": {
              "current": isOnline ? "pending" : "upcoming",
              "label": isOnline ? "Pending" : "Confirmed",
            },
  
            "timeline": {
              "createdAt": FieldValue.serverTimestamp(),
              "confirmedAt": FieldValue.serverTimestamp(),
              "cancelledAt": null,
              "completedAt": null,
            },
  
            "reminders": {
              "12h_before": {"sent": false, "sentAt": null},
              "3h_before": {"sent": false, "sentAt": null},
            },
  
            "meta": {"source": "mobile_app", "version": appVersion},
  
            // ✅ helpful index key
            "doctor_date_key": statsId,
          };
  
          tx.set(bookingRef, bookingData);
  
          // Prepare Admin Notification
          final adminNotifRef = _firestore
              .collection('admin_notifications')
              .doc();
          tx.set(adminNotifRef, {
            'kind': 'booking.created',
            'tone': 'success',
            'title': {'en': 'New Clinical Booking', 'ar': 'حجز عيادة جديد'},
            'body': {
              'en':
                  'A new clinical booking has been created by ${user.name} for Doctor ${doctor.nameEn} (ID: $bookingId).',
              'ar':
                  'قام ${user.name} بحجز جديد لدى الطبيب ${doctor.nameAr} (رقم: $bookingId).',
            },
            'bookingId': bookingId,
            'link': '/bookings/$bookingId',
            'actor': user.userId,
            'read': false,
            'readAt': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
  
          return BookingResult(
            success: true,
            message: "Booking confirmed",
            bookingId: bookingId,
            bookedCount: newCount,
            maxBookings: maxBookings,
          );
        });
      } catch (e) {
        return BookingResult(
          success: false,
          message: "Booking failed: $e",
          bookingId: null,
          bookedCount: 0,
          maxBookings: doctor.maxBooking <= 0 ? 1 : doctor.maxBooking,
        );
      }
    }
  
    /// ===============================
    /// CREATE IMAGING BOOKING
    /// ===============================
    Future<BookingResult> createImagingBooking({
      required BookingUserInfo user,
      required String categoryId,
      required String subcategoryId,
      required String nameEn,
      required String nameAr,
      required DateTime selectedDate,
      required String selectedTime,
      int durationMinutes = 30,
      String clinicName = "O2 Imaging Center",
      String floor = "1",
      String room = "Radiology",
      String paymentStatus = "pending",
      String paymentMethod = "cash",
      String currency = "USD",
      num amount = 0,
      String appVersion = "1.0",
      Map<String, dynamic>? discountData,
    }) async {
      try {
        final ts = buildTimestamp(selectedDate, selectedTime);
        final dateKey = formatDate(selectedDate);
        final counterRef = _firestore.collection("counters").doc("bookings");
  
        return await _firestore.runTransaction<BookingResult>((tx) async {
          final counterSnap = await tx.get(counterRef);
  
          DocumentReference? discountRef;
          DocumentSnapshot? discountSnap;
          if (discountData != null && discountData['code_id'] != null) {
            discountRef = _firestore
                .collection("discount_codes")
                .doc(discountData['code_id']);
            discountSnap = await tx.get(discountRef);
  
            if (discountSnap.exists) {
              final data = discountSnap.data() as Map<String, dynamic>? ?? {};
              final status = data['status'] as String?;
              final usageLimit = (data['usage_limit'] ?? -1) as int;
              final usedCount = (data['used_count'] ?? 0) as int;
  
              if (status != 'active') {
                return BookingResult(
                  success: false,
                  message: _getDiscountErrorMessage('not_active'),
                  bookingId: null,
                  bookedCount: 0,
                  maxBookings: 0,
                );
              }
              if (usageLimit != -1 && usedCount >= usageLimit) {
                return BookingResult(
                  success: false,
                  message: _getDiscountErrorMessage('limit_reached'),
                  bookingId: null,
                  bookedCount: 0,
                  maxBookings: 0,
                );
              }
            }
          }
  
          int currentSeq = 1000;
          if (counterSnap.exists) {
            currentSeq = ((counterSnap.data()?['imaging'] ?? 1000) as num)
                .toInt();
          }
          final newSeq = currentSeq + 1;
          tx.set(counterRef, {'imaging': newSeq}, SetOptions(merge: true));
  
          if (discountRef != null &&
              discountSnap != null &&
              discountSnap.exists) {
            final data = discountSnap.data() as Map<String, dynamic>? ?? {};
            final usageLimit = (data['usage_limit'] ?? -1) as int;
            final usedCount = (data['used_count'] ?? 0) as int;
  
            final newUsedCount = usedCount + 1;
            final updates = <String, dynamic>{"used_count": newUsedCount};
            if (usageLimit != -1 && newUsedCount >= usageLimit) {
              updates["status"] = "expired";
            }
            tx.update(discountRef, updates);
          }
  
          final bookingId = "O2-RAD-$newSeq";
          final bookingRef = _firestore.collection("bookings").doc(bookingId);
  
          final bookingData = <String, dynamic>{
            "id": bookingId,
            "user": user.toMap(),
            "type": "imaging",
            "service": null,
            "doctor": null,
            "imaging": {
              "categoryId": categoryId,
              "subcategoryId": subcategoryId,
              "name_en": nameEn,
              "name_ar": nameAr,
            },
            "cosmetic": null,
            "schedule": {
              "date": dateKey,
              "time": selectedTime,
              "timestamp": ts,
              "duration_minutes": durationMinutes,
            },
            "location": {"clinic": clinicName, "floor": floor, "room": room},
            "payment": {
              "status": paymentStatus,
              "method": paymentMethod,
              "amount": amount,
              "currency": currency,
              "discount": ?discountData,
            },
            "status": {"current": "upcoming", "label": "Upcoming"},
            "timeline": {
              "createdAt": FieldValue.serverTimestamp(),
              "confirmedAt": FieldValue.serverTimestamp(),
              "cancelledAt": null,
              "completedAt": null,
            },
            "reminders": {
              "12h_before": {"sent": false, "sentAt": null},
              "3h_before": {"sent": false, "sentAt": null},
            },
            "meta": {"source": "mobile_app", "version": appVersion},
          };
  
          tx.set(bookingRef, bookingData);
  
          // Prepare Admin Notification
          final adminNotifRef = _firestore
              .collection('admin_notifications')
              .doc();
          tx.set(adminNotifRef, {
            'kind': 'booking.created',
            'tone': 'success',
            'title': {'en': 'New Imaging Booking', 'ar': 'حجز أشعة جديد'},
            'body': {
              'en':
                  'A new imaging booking ($nameEn) has been created by ${user.name} (ID: $bookingId).',
              'ar':
                  'قام ${user.name} بحجز أشعة جديد ($nameAr) (رقم: $bookingId).',
            },
            'bookingId': bookingId,
            'link': '/bookings/$bookingId',
            'actor': user.userId,
            'read': false,
            'readAt': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
  
          return BookingResult(
            success: true,
            message: "Booking confirmed",
            bookingId: bookingId,
            bookedCount: 0,
            maxBookings: 0,
          );
        });
      } catch (e) {
        return BookingResult(
          success: false,
          message: "Booking failed: $e",
          bookingId: null,
          bookedCount: 0,
          maxBookings: 0,
        );
      }
    }
  
    /// ===============================
    /// CREATE COSMETIC BOOKING
    /// ===============================
    Future<BookingResult> createCosmeticBooking({
      required BookingUserInfo user,
      required String cosmeticId,
      required String nameEn,
      required String nameAr,
      required DateTime selectedDate,
      required String selectedTime,
      int durationMinutes = 30,
      String clinicName = "O2 Cosmetic Center",
      String floor = "2",
      String room = "Cosmetic Room",
      String paymentStatus = "pending",
      String paymentMethod = "cash",
      String currency = "USD",
      num amount = 0,
      String appVersion = "1.0",
      Map<String, dynamic>? discountData,
    }) async {
      try {
        final ts = buildTimestamp(selectedDate, selectedTime);
        final dateKey = formatDate(selectedDate);
        final counterRef = _firestore.collection("counters").doc("bookings");
  
        return await _firestore.runTransaction<BookingResult>((tx) async {
          final counterSnap = await tx.get(counterRef);
  
          DocumentReference? discountRef;
          DocumentSnapshot? discountSnap;
          if (discountData != null && discountData['code_id'] != null) {
            discountRef = _firestore
                .collection("discount_codes")
                .doc(discountData['code_id']);
            discountSnap = await tx.get(discountRef);
  
            if (discountSnap.exists) {
              final data = discountSnap.data() as Map<String, dynamic>? ?? {};
              final status = data['status'] as String?;
              final usageLimit = (data['usage_limit'] ?? -1) as int;
              final usedCount = (data['used_count'] ?? 0) as int;
  
              if (status != 'active') {
                return BookingResult(
                  success: false,
                  message: _getDiscountErrorMessage('not_active'),
                  bookingId: null,
                  bookedCount: 0,
                  maxBookings: 0,
                );
              }
              if (usageLimit != -1 && usedCount >= usageLimit) {
                return BookingResult(
                  success: false,
                  message: _getDiscountErrorMessage('limit_reached'),
                  bookingId: null,
                  bookedCount: 0,
                  maxBookings: 0,
                );
              }
            }
          }
  
          int currentSeq = 1000;
          if (counterSnap.exists) {
            currentSeq = ((counterSnap.data()?['cosmetic'] ?? 1000) as num)
                .toInt();
          }
          final newSeq = currentSeq + 1;
          tx.set(counterRef, {'cosmetic': newSeq}, SetOptions(merge: true));
  
          if (discountRef != null &&
              discountSnap != null &&
              discountSnap.exists) {
            final data = discountSnap.data() as Map<String, dynamic>? ?? {};
            final usageLimit = (data['usage_limit'] ?? -1) as int;
            final usedCount = (data['used_count'] ?? 0) as int;
  
            final newUsedCount = usedCount + 1;
            final updates = <String, dynamic>{"used_count": newUsedCount};
            if (usageLimit != -1 && newUsedCount >= usageLimit) {
              updates["status"] = "expired";
            }
            tx.update(discountRef, updates);
          }
  
          final bookingId = "O2-COS-$newSeq";
          final bookingRef = _firestore.collection("bookings").doc(bookingId);
  
          final bookingData = <String, dynamic>{
            "id": bookingId,
            "user": user.toMap(),
            "type": "cosmetic",
            "service": null,
            "doctor": null,
            "imaging": null,
            "cosmetic": {
              "cosmeticId": cosmeticId,
              "name_en": nameEn,
              "name_ar": nameAr,
            },
            "schedule": {
              "date": dateKey,
              "time": selectedTime,
              "timestamp": ts,
              "duration_minutes": durationMinutes,
            },
            "location": {"clinic": clinicName, "floor": floor, "room": room},
            "payment": {
              "status": paymentStatus,
              "method": paymentMethod,
              "amount": amount,
              "currency": currency,
              "discount": ?discountData,
            },
            "status": {"current": "upcoming", "label": "Upcoming"},
            "timeline": {
              "createdAt": FieldValue.serverTimestamp(),
              "confirmedAt": FieldValue.serverTimestamp(),
              "cancelledAt": null,
              "completedAt": null,
            },
            "reminders": {
              "12h_before": {"sent": false, "sentAt": null},
              "3h_before": {"sent": false, "sentAt": null},
            },
            "meta": {"source": "mobile_app", "version": appVersion},
          };
  
          tx.set(bookingRef, bookingData);
  
          // Prepare Admin Notification
          final adminNotifRef = _firestore
              .collection('admin_notifications')
              .doc();
          tx.set(adminNotifRef, {
            'kind': 'booking.created',
            'tone': 'success',
            'title': {'en': 'New Cosmetic Booking', 'ar': 'حجز تجميل جديد'},
            'body': {
              'en':
                  'A new cosmetic booking ($nameEn) has been created by ${user.name} (ID: $bookingId).',
              'ar':
                  'قام ${user.name} بحجز تجميل جديد ($nameAr) (رقم: $bookingId).',
            },
            'bookingId': bookingId,
            'link': '/bookings/$bookingId',
            'actor': user.userId,
            'read': false,
            'readAt': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
  
          return BookingResult(
            success: true,
            message: "Booking confirmed",
            bookingId: bookingId,
            bookedCount: 0,
            maxBookings: 0,
          );
        });
      } catch (e) {
        return BookingResult(
          success: false,
          message: "Booking failed: $e",
          bookingId: null,
          bookedCount: 0,
          maxBookings: 0,
        );
      }
    }
  
    /// ===============================
    /// CREATE DIRECT BOOKING (Sleep study, etc.)
    /// ===============================
    Future<BookingResult> createDirectBooking({
      required BookingUserInfo user,
      required String serviceId,
      required String nameEn,
      required String nameAr,
      required DateTime selectedDate,
      required String selectedTime,
      int durationMinutes = 30,
      String clinicName = "O2 Clinic Headquarters",
      String floor = "1",
      String room = "Direct Services Room",
      String paymentStatus = "pending",
      String paymentMethod = "cash",
      String currency = "ILS",
      num amount = 0,
      String appVersion = "1.0",
      Map<String, dynamic>? discountData,
    }) async {
      try {
        final ts = buildTimestamp(selectedDate, selectedTime);
        final dateKey = formatDate(selectedDate);
        final counterRef = _firestore.collection("counters").doc("bookings");
  
        return await _firestore.runTransaction<BookingResult>((tx) async {
          final counterSnap = await tx.get(counterRef);
  
          DocumentReference? discountRef;
          DocumentSnapshot? discountSnap;
          if (discountData != null && discountData['code_id'] != null) {
            discountRef = _firestore
                .collection("discount_codes")
                .doc(discountData['code_id']);
            discountSnap = await tx.get(discountRef);
  
            if (discountSnap.exists) {
              final data = discountSnap.data() as Map<String, dynamic>? ?? {};
              final status = data['status'] as String?;
              final usageLimit = (data['usage_limit'] ?? -1) as int;
              final usedCount = (data['used_count'] ?? 0) as int;
  
              if (status != 'active') {
                return BookingResult(
                  success: false,
                  message: _getDiscountErrorMessage('not_active'),
                  bookingId: null,
                  bookedCount: 0,
                  maxBookings: 0,
                );
              }
              if (usageLimit != -1 && usedCount >= usageLimit) {
                return BookingResult(
                  success: false,
                  message: _getDiscountErrorMessage('limit_reached'),
                  bookingId: null,
                  bookedCount: 0,
                  maxBookings: 0,
                );
              }
            }
          }
  
          int currentSeq = 1000;
          if (counterSnap.exists) {
            currentSeq = ((counterSnap.data()?['direct'] ?? 1000) as num).toInt();
          }
          final newSeq = currentSeq + 1;
          tx.set(counterRef, {'direct': newSeq}, SetOptions(merge: true));
  
          if (discountRef != null &&
              discountSnap != null &&
              discountSnap.exists) {
            final data = discountSnap.data() as Map<String, dynamic>? ?? {};
            final usageLimit = (data['usage_limit'] ?? -1) as int;
            final usedCount = (data['used_count'] ?? 0) as int;
  
            final newUsedCount = usedCount + 1;
            final updates = <String, dynamic>{"used_count": newUsedCount};
            if (usageLimit != -1 && newUsedCount >= usageLimit) {
              updates["status"] = "expired";
            }
            tx.update(discountRef, updates);
          }
  
          final bookingId = "O2-DIR-$newSeq";
          final bookingRef = _firestore.collection("bookings").doc(bookingId);
  
          final bookingData = <String, dynamic>{
            "id": bookingId,
            "user": user.toMap(),
            "type": "direct",
            "service": null,
            "doctor": null,
            "imaging": null,
            "direct": {
              "serviceId": serviceId,
              "name_en": nameEn,
              "name_ar": nameAr,
            },
            "schedule": {
              "date": dateKey,
              "time": selectedTime,
              "timestamp": ts,
              "duration_minutes": durationMinutes,
            },
            "location": {"clinic": clinicName, "floor": floor, "room": room},
            "payment": {
              "status": paymentStatus,
              "method": paymentMethod,
              "amount": amount,
              "currency": currency,
              "discount": ?discountData,
            },
            "status": {"current": "upcoming", "label": "Upcoming"},
            "timeline": {
              "createdAt": FieldValue.serverTimestamp(),
              "confirmedAt": FieldValue.serverTimestamp(),
              "cancelledAt": null,
              "completedAt": null,
            },
            "reminders": {
              "12h_before": {"sent": false, "sentAt": null},
              "3h_before": {"sent": false, "sentAt": null},
            },
            "meta": {"source": "mobile_app", "version": appVersion},
          };
  
          tx.set(bookingRef, bookingData);
  
          return BookingResult(
            success: true,
            message: "Booking confirmed",
            bookingId: bookingId,
            bookedCount: 0,
            maxBookings: 0,
          );
        });
      } catch (e) {
        return BookingResult(
          success: false,
          message: "Booking failed: $e",
          bookingId: null,
          bookedCount: 0,
          maxBookings: 0,
        );
      }
    }
  
    /// ===============================
    /// WATCH CAPACITY (LIVE)
    /// ===============================
    Stream<int> watchBookedCount({
      required String doctorId,
      required DateTime date,
    }) {
      final dateKey = formatDate(date);
      final statsId = statsDocId(doctorId, dateKey);
  
      return _firestore
          .collection("doctor_booking_stats")
          .doc(statsId)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return 0;
            final data = doc.data();
            return ((data?['count'] ?? 0) as num).toInt();
          });
    }
}

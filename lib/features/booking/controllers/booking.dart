import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../services_firestore/models/doctor_model.dart';

class BookingResult {
  final bool success;
  final String message;
  final String? bookingId;
  final int bookedCount;
  final int maxBookings;

  BookingResult({
    required this.success,
    required this.message,
    required this.bookingId,
    required this.bookedCount,
    required this.maxBookings,
  });
}

/// ===============================
/// USER INFO (المفروض يجي من Auth/Profile)
/// ===============================
class BookingUserInfo {
  final String userId;
  final String name;
  final String countryCode;
  final String number;

  const BookingUserInfo({
    required this.userId,
    required this.name,
    required this.countryCode,
    required this.number,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "name": name,
      "phone": {
        "countryCode": countryCode,
        "number": number,
        "full": "$countryCode $number",
      },
    };
  }
}

/// ===============================
/// FIRESTORE BOOKING SERVICE
/// - يحفظ Booking في bookings
/// - يعمل capacity stats في doctor_booking_stats
/// ===============================
class BookingFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          discountRef = _firestore.collection("discount_codes").doc(discountData['code_id']);
          discountSnap = await tx.get(discountRef);
          
          if (discountSnap.exists) {
            final data = discountSnap.data() as Map<String, dynamic>? ?? {};
            final status = data['status'] as String?;
            final usageLimit = (data['usage_limit'] ?? -1) as int;
            final usedCount = (data['used_count'] ?? 0) as int;
            
            if (status != 'active') {
              return BookingResult(success: false, message: _getDiscountErrorMessage('not_active'), bookingId: null, bookedCount: 0, maxBookings: 0);
            }
            if (usageLimit != -1 && usedCount >= usageLimit) {
              return BookingResult(success: false, message: _getDiscountErrorMessage('limit_reached'), bookingId: null, bookedCount: 0, maxBookings: 0);
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
          currentSeq = ((counterSnap.data()?['clinical'] ?? 1000) as num).toInt();
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
        
        if (discountRef != null && discountSnap != null && discountSnap.exists) {
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
            if (discountData != null) "discount": discountData,
          },

          "status": {"current": isOnline ? "pending" : "upcoming", "label": isOnline ? "Pending" : "Confirmed"},

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
          discountRef = _firestore.collection("discount_codes").doc(discountData['code_id']);
          discountSnap = await tx.get(discountRef);
          
          if (discountSnap.exists) {
            final data = discountSnap.data() as Map<String, dynamic>? ?? {};
            final status = data['status'] as String?;
            final usageLimit = (data['usage_limit'] ?? -1) as int;
            final usedCount = (data['used_count'] ?? 0) as int;
            
            if (status != 'active') {
              return BookingResult(success: false, message: _getDiscountErrorMessage('not_active'), bookingId: null, bookedCount: 0, maxBookings: 0);
            }
            if (usageLimit != -1 && usedCount >= usageLimit) {
              return BookingResult(success: false, message: _getDiscountErrorMessage('limit_reached'), bookingId: null, bookedCount: 0, maxBookings: 0);
            }
          }
        }

        int currentSeq = 1000;
        if (counterSnap.exists) {
          currentSeq = ((counterSnap.data()?['imaging'] ?? 1000) as num).toInt();
        }
        final newSeq = currentSeq + 1;
        tx.set(counterRef, {'imaging': newSeq}, SetOptions(merge: true));
        
        if (discountRef != null && discountSnap != null && discountSnap.exists) {
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
            if (discountData != null) "discount": discountData,
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
          discountRef = _firestore.collection("discount_codes").doc(discountData['code_id']);
          discountSnap = await tx.get(discountRef);
          
          if (discountSnap.exists) {
            final data = discountSnap.data() as Map<String, dynamic>? ?? {};
            final status = data['status'] as String?;
            final usageLimit = (data['usage_limit'] ?? -1) as int;
            final usedCount = (data['used_count'] ?? 0) as int;
            
            if (status != 'active') {
              return BookingResult(success: false, message: _getDiscountErrorMessage('not_active'), bookingId: null, bookedCount: 0, maxBookings: 0);
            }
            if (usageLimit != -1 && usedCount >= usageLimit) {
              return BookingResult(success: false, message: _getDiscountErrorMessage('limit_reached'), bookingId: null, bookedCount: 0, maxBookings: 0);
            }
          }
        }

        int currentSeq = 1000;
        if (counterSnap.exists) {
          currentSeq = ((counterSnap.data()?['cosmetic'] ?? 1000) as num).toInt();
        }
        final newSeq = currentSeq + 1;
        tx.set(counterRef, {'cosmetic': newSeq}, SetOptions(merge: true));
        
        if (discountRef != null && discountSnap != null && discountSnap.exists) {
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
          if (discountData != null) "discount": discountData,
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

        print("✅ [Cosmetic Booking] Created: $bookingId");

        return BookingResult(
          success: true,
          message: "Booking confirmed",
          bookingId: bookingId,
          bookedCount: 0,
          maxBookings: 0,
        );
      });
    } catch (e) {
      print("❌ [Cosmetic Booking] Failed: $e");
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

/// ===============================
/// LOCAL HELPERS FOR AVAILABILITY
/// ===============================
class BookingService {
  /// map weekday int -> "monday" ...
  static String weekdayKeyLower(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "monday";
      case DateTime.tuesday:
        return "tuesday";
      case DateTime.wednesday:
        return "wednesday";
      case DateTime.thursday:
        return "thursday";
      case DateTime.friday:
        return "friday";
      case DateTime.saturday:
        return "saturday";
      case DateTime.sunday:
        return "sunday";
      default:
        return "monday";
    }
  }

  static String weekdayShort(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  int _dayToNumber(String dayLower) {
    switch (dayLower.trim().toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  /// ✅ Generate next 7 available dates using lowercase day keys
  List<DateTime> generateNextAvailableDates(List<String> availableDaysLower) {
    final cleaned = availableDaysLower
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    if (cleaned.isEmpty) return [];

    final now = DateTime.now();
    final availableNumbers = cleaned.map(_dayToNumber).toSet();

    final List<DateTime> result = [];
    int i = 0;

    while (result.length < 7 && i < 60) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: i));
      if (availableNumbers.contains(date.weekday)) {
        result.add(date);
      }
      i++;
    }

    return result;
  }

  /// availability_day values are usually String "14:00 - 17:00"
  String extractTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      final keys = [
        'time',
        'slot',
        'startTime',
        'start_time',
        'availableTime',
        'available_time',
      ];

      for (final k in keys) {
        final v = map[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }

    return '';
  }

  /// ✅ Convert time string from 24h to 12h format (e.g. "14:00 - 17:00" -> "02:00 PM - 05:00 PM")
  String convertTo12HourFormat(String timeStr) {
    if (timeStr.isEmpty) return timeStr;
    
    final parts = timeStr.split('-');
    List<String> formattedParts = [];
    
    for (var part in parts) {
      part = part.trim();
      final timeParts = part.split(':');
      if (timeParts.length == 2) {
        final hStr = timeParts[0].replaceAll(RegExp(r'[^0-9]'), '');
        final mStr = timeParts[1].replaceAll(RegExp(r'[^0-9]'), '');
        
        final h = int.tryParse(hStr);
        final m = int.tryParse(mStr);
        
        if (h != null && m != null) {
          // Check if am/pm already exists
          if (part.toLowerCase().contains('am') || part.toLowerCase().contains('pm')) {
            formattedParts.add(part);
            continue;
          }
          
          final suffix = h >= 12 ? 'PM' : 'AM';
          var hour12 = h % 12;
          if (hour12 == 0) hour12 = 12;
          
          final newH = hour12.toString().padLeft(2, '0');
          final newM = m.toString().padLeft(2, '0');
          formattedParts.add("$newH:$newM $suffix");
          continue;
        }
      }
      // fallback
      formattedParts.add(part);
    }
    
    return formattedParts.join(' - ');
  }

  /// Adjusts the time slot if the selected date is today, moving the start time to the next full hour.
  /// If the next full hour is past the end of the slot, returns an empty string.
  String adjustTimeForToday(String rawTime, DateTime selectedDate) {
    if (rawTime.trim().isEmpty) return rawTime;
    
    final now = DateTime.now();
    
    if (selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day) {
      final parts = rawTime.split('-');
      if (parts.isNotEmpty) {
        final startPart = parts[0].trim();
        int h = 0;
        int m = 0;
        
        final timeParts = startPart.split(':');
        if (timeParts.isNotEmpty) {
          final hStr = timeParts[0].replaceAll(RegExp(r'[^0-9]'), '');
          final mStr = timeParts.length > 1 ? timeParts[1].replaceAll(RegExp(r'[^0-9]'), '') : '00';
          h = int.tryParse(hStr) ?? 0;
          m = int.tryParse(mStr) ?? 0;
          
          if (startPart.toLowerCase().contains('pm') && h < 12) h += 12;
          if (startPart.toLowerCase().contains('am') && h == 12) h = 0;
        }
        
        final slotStart = DateTime(now.year, now.month, now.day, h, m);
        
        int nextHour = now.hour;
        if (now.minute > 0 || now.second > 0) {
          nextHour += 1;
        }
        
        final currentNextHourTime = DateTime(now.year, now.month, now.day, nextHour, 0);
        
        if (currentNextHourTime.isAfter(slotStart)) {
          if (parts.length > 1) {
            final endPart = parts[1].trim();
            final endParts = endPart.split(':');
            if (endParts.isNotEmpty) {
               final endHStr = endParts[0].replaceAll(RegExp(r'[^0-9]'), '');
               final endMStr = endParts.length > 1 ? endParts[1].replaceAll(RegExp(r'[^0-9]'), '') : '00';
               int endH = int.tryParse(endHStr) ?? 0;
               int endM = int.tryParse(endMStr) ?? 0;
               if (endPart.toLowerCase().contains('pm') && endH < 12) endH += 12;
               if (endPart.toLowerCase().contains('am') && endH == 12) endH = 0;
               
               final slotEnd = DateTime(now.year, now.month, now.day, endH, endM);
               
               if (currentNextHourTime.isAfter(slotEnd) || currentNextHourTime.isAtSameMomentAs(slotEnd)) {
                 return ""; // Empty string indicates no valid time remaining for today
               }
            }
          } else {
             return "";
          }
          
          final newH = nextHour.toString().padLeft(2, '0');
          return "$newH:00 - ${parts[1].trim()}";
        }
      }
    }
    return rawTime;
  }
}

/// ===============================
/// CONTROLLER (USED IN BookingPage)
/// ===============================
class AppointmentBookingController extends GetxController {
  final DoctorModel doctor;

  AppointmentBookingController(this.doctor);

  final BookingService _service = BookingService();
  final BookingFirestoreService _firestoreService = BookingFirestoreService();

  final selectedDate = Rxn<DateTime>();
  final selectedTime = RxnString();

  /// ✅ Firestore capacity (LIVE)
  final bookedCountRx = 0.obs;

  late final int maxBookings;
  late final List<DateTime> availableDates;

  StreamSubscription<int>? _capacitySub;

  Map<String, dynamic> get _availability =>
      Map<String, dynamic>.from(doctor.availabilityDay);

  int _dayStringToNumber(String day) {
    switch (day.toLowerCase()) {
      case 'monday': return DateTime.monday;
      case 'tuesday': return DateTime.tuesday;
      case 'wednesday': return DateTime.wednesday;
      case 'thursday': return DateTime.thursday;
      case 'friday': return DateTime.friday;
      case 'saturday': return DateTime.saturday;
      case 'sunday': return DateTime.sunday;
      default: return DateTime.friday;
    }
  }

  List<DateTime> _generateMonthlyDates(int weekIndex, int targetWeekday) {
    List<DateTime> dates = [];
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    for (int i = 0; i < 6; i++) {
      DateTime firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
      int daysToFirstTarget = (targetWeekday - firstDayOfMonth.weekday + 7) % 7;
      DateTime firstOccurrence = firstDayOfMonth.add(Duration(days: daysToFirstTarget));
      DateTime targetDate = firstOccurrence.add(Duration(days: 7 * (weekIndex - 1)));
      
      if (targetDate.month == currentMonth) {
        if (targetDate.isAfter(DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)))) {
           dates.add(targetDate);
        }
      }

      currentMonth++;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      }
    }
    return dates;
  }

  @override
  void onInit() {
    super.onInit();

    maxBookings = doctor.maxBooking <= 0 ? 1 : doctor.maxBooking;

    List<DateTime> rawDates = [];
    
    if (doctor.scheduleType == 'monthly' && doctor.monthlySchedule != null) {
      final weekIndex = doctor.monthlySchedule!['week_of_month'] as int? ?? 1;
      final dayString = doctor.monthlySchedule!['day'] as String? ?? 'friday';
      final targetWeekday = _dayStringToNumber(dayString);
      rawDates = _generateMonthlyDates(weekIndex, targetWeekday);
    } else {
      final availableDayKeysLower = _availability.keys
          .map((e) => e.toString().trim().toLowerCase())
          .toList();
      rawDates = _service.generateNextAvailableDates(availableDayKeysLower);
    }

    final now = DateTime.now();
    
    rawDates.removeWhere((date) {
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        final weekdayKey = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'][date.weekday - 1];
        final timeRange = _availability[weekdayKey]?.toString() ?? '';
        if (timeRange.contains('-')) {
          final endTimeStr = timeRange.split('-').last.trim();
          try {
             final endTs = BookingFirestoreService.buildTimestamp(date, endTimeStr).toDate();
             return endTs.isBefore(now);
          } catch(e) {
             return false;
          }
        }
      }
      return false;
    });

    availableDates = rawDates;

    if (availableDates.isNotEmpty) {
      selectDate(availableDates.first);
    }
  }

  @override
  void onClose() {
    _capacitySub?.cancel();
    super.onClose();
  }

  /// UI helper
  String getDayShort(int weekday) => BookingService.weekdayShort(weekday);

  /// ✅ Select date + set selectedTime from availability_day + start watching capacity from Firestore
  void selectDate(DateTime date) {
    selectedDate.value = date;

    final dayKey = BookingService.weekdayKeyLower(date.weekday);
    final rawTime = _service.extractTime(_availability[dayKey]);
    
    // Adjust time if it's today
    final adjustedTime = _service.adjustTimeForToday(rawTime, date);
    selectedTime.value = _service.convertTo12HourFormat(adjustedTime);

    _listenCapacityForDate(date);
  }

  void _listenCapacityForDate(DateTime date) {
    _capacitySub?.cancel();

    _capacitySub = _firestoreService
        .watchBookedCount(doctorId: doctor.id, date: date)
        .listen(
          (count) {
            bookedCountRx.value = count;
          },
          onError: (_) {
            bookedCountRx.value = 0;
          },
        );
  }

  /// ✅ used by your BookingPage (capacity)
  int get bookedCount => bookedCountRx.value;

  /// ✅ availability
  bool get isTimeValid => (selectedTime.value ?? '').trim().isNotEmpty;

  /// ✅ slot availability check
  bool get isAvailable {
    return maxBookings > 0 ? bookedCount < maxBookings : true;
  }

  /// ===============================
  /// ✅ FINAL: confirm booking and save to Firestore (call this from ConfirmBookingScreen)
  /// ===============================
  Future<BookingResult> confirmBooking({
    required BookingUserInfo user,
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
    final date = selectedDate.value;
    final time = (selectedTime.value ?? '').trim();

    if (date == null) {
      return BookingResult(
        success: false,
        message: "Select date first",
        bookingId: null,
        bookedCount: bookedCount,
        maxBookings: maxBookings,
      );
    }

    if (time.isEmpty) {
      return BookingResult(
        success: false,
        message: "Time is not available for this day",
        bookingId: null,
        bookedCount: bookedCount,
        maxBookings: maxBookings,
      );
    }

    // ✅ use Firestore transaction (safe)
    final res = await _firestoreService.createClinicalBooking(
      user: user,
      doctor: doctor,
      selectedDate: selectedDate.value!,
      selectedTime: selectedTime.value!,
      durationMinutes: durationMinutes,
      clinicName: clinicName,
      floor: floor,
      room: room,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      currency: currency,
      amountOverride: amountOverride,
      appVersion: appVersion,
      discountData: discountData,
      isOnline: isOnline,
    );

    // ✅ refresh UI count immediately
    if (res.success) {
      bookedCountRx.value = res.bookedCount;
    }

    return res;
  }
}

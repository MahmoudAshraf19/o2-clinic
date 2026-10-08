import 'dart:async';

import 'package:get/get.dart';


import '../../../../common/models/fs_doctor_model.dart';
import '../../data/models/booking_request_models.dart';
import '../../data/services/fs_bookings_firestore_service.dart';


/// ===============================
/// USER INFO (المفروض يجي من Auth/Profile)
/// ===============================
/// ===============================
/// FIRESTORE BOOKING SERVICE
/// - يحفظ Booking في bookings
/// - يعمل capacity stats في doctor_booking_stats
/// ===============================
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
          if (part.toLowerCase().contains('am') ||
              part.toLowerCase().contains('pm')) {
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

    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      final parts = rawTime.split('-');
      if (parts.isNotEmpty) {
        final startPart = parts[0].trim();
        int h = 0;
        int m = 0;

        final timeParts = startPart.split(':');
        if (timeParts.isNotEmpty) {
          final hStr = timeParts[0].replaceAll(RegExp(r'[^0-9]'), '');
          final mStr = timeParts.length > 1
              ? timeParts[1].replaceAll(RegExp(r'[^0-9]'), '')
              : '00';
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

        final currentNextHourTime = DateTime(
          now.year,
          now.month,
          now.day,
          nextHour,
          0,
        );

        if (currentNextHourTime.isAfter(slotStart)) {
          if (parts.length > 1) {
            final endPart = parts[1].trim();
            final endParts = endPart.split(':');
            if (endParts.isNotEmpty) {
              final endHStr = endParts[0].replaceAll(RegExp(r'[^0-9]'), '');
              final endMStr = endParts.length > 1
                  ? endParts[1].replaceAll(RegExp(r'[^0-9]'), '')
                  : '00';
              int endH = int.tryParse(endHStr) ?? 0;
              int endM = int.tryParse(endMStr) ?? 0;
              if (endPart.toLowerCase().contains('pm') && endH < 12) endH += 12;
              if (endPart.toLowerCase().contains('am') && endH == 12) endH = 0;

              final slotEnd = DateTime(
                now.year,
                now.month,
                now.day,
                endH,
                endM,
              );

              if (currentNextHourTime.isAfter(slotEnd) ||
                  currentNextHourTime.isAtSameMomentAs(slotEnd)) {
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
  final BookingsFirestoreService _firestoreService = BookingsFirestoreService();

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
        return DateTime.friday;
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
      DateTime firstOccurrence = firstDayOfMonth.add(
        Duration(days: daysToFirstTarget),
      );
      DateTime targetDate = firstOccurrence.add(
        Duration(days: 7 * (weekIndex - 1)),
      );

      if (targetDate.month == currentMonth) {
        if (targetDate.isAfter(
          DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 1)),
        )) {
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
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        final weekdayKey = [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
          'sunday',
        ][date.weekday - 1];
        final timeRange = _availability[weekdayKey]?.toString() ?? '';
        if (timeRange.contains('-')) {
          final endTimeStr = timeRange.split('-').last.trim();
          try {
            final endTs = BookingsFirestoreService.buildTimestamp(
              date,
              endTimeStr,
            ).toDate();
            return endTs.isBefore(now);
          } catch (e) {
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
          // ignore: avoid_types_as_parameter_names
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
      bookedCountRx.value = res.bookedCount ?? 0;
    }

    return res;
  }
}

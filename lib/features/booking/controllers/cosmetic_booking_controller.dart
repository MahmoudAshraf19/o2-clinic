import 'package:get/get.dart';

import '../../../../common/controllers/app_constants_controller.dart';
import '../../services/models/cosmetic_category_model.dart';
import 'booking.dart';

class CosmeticAppointmentBookingController extends GetxController {
  final CosmeticCategoryModel service;
  
  CosmeticAppointmentBookingController(this.service);

  final selectedDate = Rx<DateTime?>(null);
  final selectedTime = ''.obs;

  final availableDates = <DateTime>[].obs;
  final availableTimes = <String>[].obs;

  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAvailableDates();
  }

  void _loadAvailableDates() {
    final List<String> daysLower = service.availabilityDay.keys.toList();
    List<DateTime> dates = BookingService().generateNextAvailableDates(daysLower);
    
    final now = DateTime.now();
    dates.removeWhere((date) {
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        final weekdayKey = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'][date.weekday - 1];
        final timeRange = service.availabilityDay[weekdayKey]?.toString() ?? '';
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

    availableDates.assignAll(dates);

    if (availableDates.isNotEmpty) {
      selectDate(availableDates.first);
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedTime.value = '';

    final dayLower = BookingService.weekdayKeyLower(date.weekday);
    final timeRange = service.availabilityDay[dayLower] ?? "";
    
    // We will generate 30 min slots based on the timeRange string
    final slots = _generateSlotsFromRange(timeRange.toString(), date);
    availableTimes.assignAll(slots);
  }

  void selectTime(String time) {
    selectedTime.value = time;
  }

  List<String> _generateSlotsFromRange(String range, DateTime selectedDate) {
    if (range.isEmpty) return [];
    
    try {
      final parts = range.split('-');
      if (parts.length != 2) return [range];
      
      final startStr = parts[0].trim();
      final endStr = parts[1].trim();
      
      final startH = int.parse(startStr.split(':')[0]);
      final startM = int.parse(startStr.split(':')[1]);
      
      final endH = int.parse(endStr.split(':')[0]);
      final endM = int.parse(endStr.split(':')[1]);
      
      List<String> slots = [];
      DateTime current = DateTime(2000, 1, 1, startH, startM);
      DateTime end = DateTime(2000, 1, 1, endH, endM);
      
      final now = DateTime.now();
      if (selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day) {
        int nextHour = now.hour;
        if (now.minute > 0 || now.second > 0) nextHour++;
        DateTime nextHourTime = DateTime(2000, 1, 1, nextHour, 0);
        if (nextHourTime.isAfter(current)) {
          current = nextHourTime;
        }
      }
      
      while (current.isBefore(end)) {
        int displayHour = current.hour;
        String amPm = "AM";
        
        if (displayHour >= 12) {
          amPm = "PM";
          if (displayHour > 12) {
            displayHour -= 12;
          }
        }
        if (displayHour == 0) {
          displayHour = 12;
        }

        final h = displayHour.toString().padLeft(2, '0');
        final m = current.minute.toString().padLeft(2, '0');
        slots.add("$h:$m $amPm");
        
        final appConstants = Get.isRegistered<AppConstantsController>() ? Get.find<AppConstantsController>() : null;
        final interval = appConstants?.slotIntervalHours.value ?? 1;
        current = current.add(Duration(hours: interval));
      }
      
      return slots;
    } catch (e) {
      return [range]; // Fallback to raw string
    }
  }
}


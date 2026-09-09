import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../../common/app_constants.dart';
import '../../../../common/controllers/app_constants_controller.dart';
import '../../services/models/radiology_category_model.dart';
import 'booking.dart';

class RadiologyAppointmentBookingController extends GetxController {
  final RadiologyCategoryModel service;
  
  RadiologyAppointmentBookingController(this.service);

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

  Future<BookingResult> confirmBooking({
    num? finalAmount,
    Map<String, dynamic>? discountData,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return BookingResult(
        success: false,
        message: "You must be logged in to book.",
        bookingId: null,
        bookedCount: 0,
        maxBookings: 0,
      );
    }

    if (selectedDate.value == null || selectedTime.value.isEmpty) {
      return BookingResult(
        success: false,
        message: "Please select a date and time.",
        bookingId: null,
        bookedCount: 0,
        maxBookings: 0,
      );
    }

    isSubmitting.value = true;

    try {
      final userInfo = BookingUserInfo(
        userId: user.uid,
        name: user.displayName ?? "Patient",
        countryCode: "+20",
        number: user.phoneNumber?.replaceAll("+20", "") ?? "1234567890",
      );

      final serviceApi = BookingFirestoreService();
      final result = await serviceApi.createImagingBooking(
        user: userInfo,
        categoryId: service.id,
        subcategoryId: "", // Add logic if there are subcategories
        nameEn: service.getName('en'),
        nameAr: service.getName('ar'),
        selectedDate: selectedDate.value!,
        selectedTime: selectedTime.value,
        amount: finalAmount ?? (num.tryParse(service.price?.toString() ?? '0') ?? 0),
        currency: AppConstants.currencyName,
        discountData: discountData,
      );

      // Removed local notification to prevent duplicate notification with backend

      return result;
    } catch (e) {
      return BookingResult(
        success: false,
        message: "Booking error: $e",
        bookingId: null,
        bookedCount: 0,
        maxBookings: 0,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}

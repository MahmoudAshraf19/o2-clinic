import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'doctor_appointments_controller.dart';

enum StatFilter { allTime, thisYear, thisMonth, thisWeek, today, customDay, customRange }

class DoctorStatisticsController extends GetxController {
  final Rx<StatFilter> selectedFilter = StatFilter.allTime.obs;
  
  final Rx<DateTime?> customSelectedDate = Rx<DateTime?>(null);
  final Rx<DateTimeRange?> customSelectedDateRange = Rx<DateTimeRange?>(null);

  final RxDouble totalEarnings = 0.0.obs;
  final RxInt totalAppointments = 0.obs;
  final RxInt uniquePatients = 0.obs;
  final RxDouble averageEarnings = 0.0.obs;
  
  // Status Breakdown
  final RxInt completedCount = 0.obs;
  final RxInt pendingCount = 0.obs;
  final RxInt cancelledCount = 0.obs;

  // Top Services
  final RxMap<String, int> topServices = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Whenever bookings update or filter changes, recalculate stats
    final apptsCtrl = Get.put(DoctorAppointmentsController());
    ever(apptsCtrl.bookings, (_) => _calculateStats());
    ever(selectedFilter, (_) => _calculateStats());
    _calculateStats();
  }

  void setFilter(StatFilter filter) {
    selectedFilter.value = filter;
  }

  void _calculateStats() {
    final apptsCtrl = Get.put(DoctorAppointmentsController());
    final allDocs = apptsCtrl.bookings;
    final now = DateTime.now();

    double tempEarnings = 0.0;
    int tempAppts = 0;
    Set<String> patientIds = {};
    
    int tempCompleted = 0;
    int tempPending = 0;
    int tempCancelled = 0;
    
    Map<String, int> servicesCount = {};

    for (var doc in allDocs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      // Only count ONLINE appointments
      final type = data['type'] as String? ?? 'clinical';
      if (type != 'online') continue;

      DateTime? appointmentDate;
      if (data['schedule'] != null && data['schedule']['date'] != null) {
        try {
          appointmentDate = DateTime.parse(data['schedule']['date']);
        } catch (_) {}
      }

      // Default to created at if schedule date is missing
      if (appointmentDate == null && data['timeline'] != null && data['timeline']['createdAt'] != null) {
        appointmentDate = (data['timeline']['createdAt'] as Timestamp).toDate();
      }

      if (appointmentDate == null) continue;

      // Filter Logic
      bool include = true;
      switch (selectedFilter.value) {
        case StatFilter.today:
          include = appointmentDate.year == now.year && appointmentDate.month == now.month && appointmentDate.day == now.day;
          break;
        case StatFilter.thisWeek:
          final weekAgo = now.subtract(const Duration(days: 7));
          include = appointmentDate.isAfter(weekAgo) && appointmentDate.isBefore(now.add(const Duration(days: 1)));
          break;
        case StatFilter.thisMonth:
          include = appointmentDate.year == now.year && appointmentDate.month == now.month;
          break;
        case StatFilter.thisYear:
          include = appointmentDate.year == now.year;
          break;
        case StatFilter.customDay:
          if (customSelectedDate.value != null) {
            final custom = customSelectedDate.value!;
            include = appointmentDate.year == custom.year && appointmentDate.month == custom.month && appointmentDate.day == custom.day;
          } else {
            include = false;
          }
          break;
        case StatFilter.customRange:
          if (customSelectedDateRange.value != null) {
            final start = customSelectedDateRange.value!.start;
            // add 1 day to end to include the entire end day
            final end = customSelectedDateRange.value!.end.add(const Duration(days: 1));
            include = appointmentDate.isAfter(start.subtract(const Duration(seconds: 1))) && appointmentDate.isBefore(end);
          } else {
            include = false;
          }
          break;
        case StatFilter.allTime:
        default:
          include = true;
          break;
      }

      if (!include) continue;

      // Aggregate Stats
      tempAppts++;
      
      final userId = (data['user'] as Map<String, dynamic>?)?['userId'] as String?;
      if (userId != null && userId.isNotEmpty) patientIds.add(userId);

      final status = (data['status'] as Map<String, dynamic>?)?['current'] as String? ?? 'pending';
      if (status == 'completed') tempCompleted++;
      else if (status == 'cancelled') tempCancelled++;
      else tempPending++;

      // Earnings
      if (status == 'completed') {
        final paymentAmount = (data['payment'] as Map<String, dynamic>?)?['amount']?.toString() ?? '0';
        tempEarnings += double.tryParse(paymentAmount) ?? 0.0;
      }

      // Services
      final serviceName = (data['service'] as Map<String, dynamic>?)?['nameEn'] as String? ?? 'General Consultation';
      servicesCount[serviceName] = (servicesCount[serviceName] ?? 0) + 1;
    }

    totalEarnings.value = tempEarnings;
    totalAppointments.value = tempAppts;
    uniquePatients.value = patientIds.length;
    averageEarnings.value = tempCompleted > 0 ? (tempEarnings / tempCompleted) : 0.0;
    
    completedCount.value = tempCompleted;
    pendingCount.value = tempPending;
    cancelledCount.value = tempCancelled;

    topServices.value = servicesCount;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../booking/data/models/fs_booking_model.dart';
import '../../../../booking/data/services/fs_bookings_firestore_service.dart';
import '../../../dashboard/presentation/controllers/dashboard_pending_actions_controller.dart';
import 'package:o2_clinic/common/widgets/common_dialogs.dart';
import 'package:o2_clinic/common/widgets/common_snackbar.dart';

enum AppointmentStatusFilter {
  all,
  upcoming,
  pending,
  completed,
  cancelled,
  requiresAction,
}

enum AppointmentTypeFilter { all, doctor, online, imaging, cosmetic }

enum AppointmentTimeFilter { all, thisWeek, thisMonth, last30Days }

class AppointmentsController extends GetxController {
  final BookingsFirestoreService _service = BookingsFirestoreService();
  final searchController = TextEditingController();

  final statusFilter = AppointmentStatusFilter.all.obs;
  final typeFilter = AppointmentTypeFilter.all.obs;
  final timeFilter = AppointmentTimeFilter.all.obs;

  final searchText = ''.obs;
  final bookings = <BookingModel>[].obs;
  final isLoading = true.obs;
  final error = Rx<String?>(null);

  final showFilters = false.obs;

  String? _showBookingId;

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchText.value = searchController.text.trim();
    });

    if (Get.arguments is Map) {
      _showBookingId = Get.arguments['showBookingId']?.toString();

      final filterArg = Get.arguments['filter']?.toString();
      if (filterArg == 'requiresAction') {
        statusFilter.value = AppointmentStatusFilter.requiresAction;
        showFilters.value = true;
      }
    }

    _loadBookings();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadBookings() {
    if (user != null) {
      isLoading.value = true;
      _service.streamBookingsByUserId(user.uid).listen((data) {
        bookings.value = data;
        isLoading.value = false;
        
        if (_showBookingId != null && data.isNotEmpty) {
           // We keep _showBookingId to potentially open it via UI later,
           // or we can just leave it to the view to observe
        }
      }, onError: (err) {
        error.value = err.toString();
        isLoading.value = false;
      });
    } else {
      isLoading.value = false;
    }
  }

  Future<void> refreshBookings() async {
    _loadBookings();
  }

  void setStatusFilter(AppointmentStatusFilter filter) {
    statusFilter.value = filter;
  }

  void setTypeFilter(AppointmentTypeFilter filter) {
    typeFilter.value = filter;
  }

  void setTimeFilter(AppointmentTimeFilter filter) {
    timeFilter.value = filter;
  }

  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  List<BookingModel> get filteredBookings {
    final query = searchText.value.toLowerCase().trim();

    return bookings.where((booking) {
      final matchesSearch = query.isEmpty || _matchesSearch(booking, query);
      final matchesStatus = _matchesStatus(booking, statusFilter.value);
      final matchesType = _matchesType(booking, typeFilter.value);
      final matchesTime = _matchesTime(booking, timeFilter.value);
      return matchesSearch && matchesStatus && matchesType && matchesTime;
    }).toList();
  }

  bool _matchesSearch(BookingModel booking, String query) {
    final text = [
      booking.user.name,
      booking.user.phone.full,
      booking.type,
      booking.service?.serviceNameAr,
      booking.service?.serviceNameEn,
      booking.doctor?.nameAr,
      booking.doctor?.nameEn,
      booking.doctor?.specialty,
      booking.imaging?.nameAr,
      booking.imaging?.nameEn,
      booking.cosmetic?.serviceName,
      booking.location.clinic,
      booking.status.current,
      booking.status.label,
    ].whereType<String>().join(' ').toLowerCase();

    return text.contains(query);
  }

  bool _matchesStatus(BookingModel booking, AppointmentStatusFilter filter) {
    final status = booking.status.current.toLowerCase();
    switch (filter) {
      case AppointmentStatusFilter.all:
        return true;
      case AppointmentStatusFilter.upcoming:
        return isUpcoming(booking);
      case AppointmentStatusFilter.pending:
        return status == 'pending' || status == 'pending_price';
      case AppointmentStatusFilter.completed:
        return status == 'completed';
      case AppointmentStatusFilter.cancelled:
        return status == 'cancelled';
      case AppointmentStatusFilter.requiresAction:
        if (Get.isRegistered<DashboardPendingActionsController>()) {
          final pendingCtrl = Get.find<DashboardPendingActionsController>();
          return pendingCtrl.pendingBookings.any((b) => b.id == booking.id);
        }
        return false;
    }
  }

  bool _matchesType(BookingModel booking, AppointmentTypeFilter filter) {
    final type = booking.type.toLowerCase();
    switch (filter) {
      case AppointmentTypeFilter.all:
        return true;
      case AppointmentTypeFilter.doctor:
        return type == 'clinical';
      case AppointmentTypeFilter.online:
        return type == 'online';
      case AppointmentTypeFilter.imaging:
        return type == 'imaging';
      case AppointmentTypeFilter.cosmetic:
        return type == 'cosmetic';
    }
  }

  bool _matchesTime(BookingModel booking, AppointmentTimeFilter filter) {
    if (filter == AppointmentTimeFilter.all) return true;
    final date = booking.schedule.timestamp?.toDate() ??
        booking.timeline.createdAt?.toDate();
    if (date == null) return false;

    final now = DateTime.now();
    final diffDays = now.difference(date).inDays;

    switch (filter) {
      case AppointmentTimeFilter.all:
        return true;
      case AppointmentTimeFilter.thisWeek:
        return date.isAfter(now.subtract(Duration(days: now.weekday - 1))) &&
            date.isBefore(now.add(Duration(days: 7 - now.weekday + 1)));
      case AppointmentTimeFilter.thisMonth:
        return date.month == now.month && date.year == now.year;
      case AppointmentTimeFilter.last30Days:
        return diffDays >= 0 && diffDays <= 30;
    }
  }

  BookingModel? get nextAppointment {
    final upcomingBookings = bookings.where(isUpcoming).toList();
    upcomingBookings.sort((a, b) {
      final aDate = a.schedule.timestamp?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.schedule.timestamp?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });
    return upcomingBookings.isEmpty ? null : upcomingBookings.first;
  }

  bool isUpcoming(BookingModel booking) {
    final status = booking.status.current.toLowerCase();
    if (status == 'completed' || status == 'cancelled') return false;
    final date = booking.schedule.timestamp?.toDate();
    if (date == null) return status == 'confirmed' || status == 'upcoming';
    return date.isAfter(DateTime.now().subtract(const Duration(hours: 1))) ||
        status == 'confirmed' ||
        status == 'upcoming';
  }
}

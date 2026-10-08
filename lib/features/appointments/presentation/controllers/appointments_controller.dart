import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../booking/data/models/fs_booking_model.dart';
import '../../../booking/data/services/fs_bookings_firestore_service.dart';
import '../../../dashboard/presentation/controllers/dashboard_pending_actions_controller.dart';

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

  StreamSubscription<List<BookingModel>>? _subscription;

  final statusFilter = AppointmentStatusFilter.all.obs;
  final typeFilter = AppointmentTypeFilter.all.obs;
  final timeFilter = AppointmentTimeFilter.all.obs;

  final searchText = ''.obs;
  final bookings = <BookingModel>[].obs;
  final isLoading = true.obs;
  final error = Rx<String?>(null);
  final showFilters = false.obs;

  /// Set when a deep-link (`showBookingId`) matches a loaded booking.
  /// The screen listens to it, opens the details sheet and resets it.
  final bookingToOpen = Rxn<BookingModel>();

  String? _pendingOpenId;

  /// Statuses after which a booking is no longer "upcoming".
  static const Set<String> closedStatuses = {
    'completed',
    'cancelled',
    'no_show',
    'under_investigation',
  };

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchText.value = searchController.text.trim();
    });

    final args = Get.arguments;
    if (args is Map) {
      _pendingOpenId = args['showBookingId']?.toString();

      if (args['filter']?.toString() == 'requiresAction') {
        statusFilter.value = AppointmentStatusFilter.requiresAction;
      }
    }

    _subscribe();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------

  void _subscribe({Completer<void>? firstEvent}) {
    void completeFirst() {
      if (firstEvent != null && !firstEvent.isCompleted) firstEvent.complete();
    }

    _subscription?.cancel();
    _subscription = null;

    final currentUser = user;
    if (currentUser == null) {
      isLoading.value = false;
      completeFirst();
      return;
    }

    // Do not flash the skeleton when refreshing an already loaded list.
    if (bookings.isEmpty) isLoading.value = true;
    error.value = null;

    _subscription = _service.streamBookingsByUserId(currentUser.uid).listen(
      (data) {
        bookings.value = data;
        isLoading.value = false;
        error.value = null;
        _tryOpenPendingBooking(data);
        completeFirst();
      },
      onError: (Object err) {
        error.value = err.toString();
        isLoading.value = false;
        completeFirst();
      },
    );
  }

  void _tryOpenPendingBooking(List<BookingModel> data) {
    final id = _pendingOpenId;
    if (id == null) return;
    for (final booking in data) {
      if (booking.id == id) {
        _pendingOpenId = null;
        bookingToOpen.value = booking;
        return;
      }
    }
  }

  /// Re-subscribes and completes when the first fresh event arrives
  /// (so the pull-to-refresh spinner reflects real loading).
  Future<void> refreshBookings() async {
    final firstEvent = Completer<void>();
    _subscribe(firstEvent: firstEvent);
    await firstEvent.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {},
    );
  }

  // ---------------------------------------------------------------------------
  // Filter setters
  // ---------------------------------------------------------------------------

  void setStatusFilter(AppointmentStatusFilter filter) =>
      statusFilter.value = filter;

  void setTypeFilter(AppointmentTypeFilter filter) =>
      typeFilter.value = filter;

  void setTimeFilter(AppointmentTimeFilter filter) =>
      timeFilter.value = filter;

  void toggleFilters() => showFilters.value = !showFilters.value;

  void clearFilters() {
    statusFilter.value = AppointmentStatusFilter.all;
    typeFilter.value = AppointmentTypeFilter.all;
    timeFilter.value = AppointmentTimeFilter.all;
    searchController.clear();
  }

  /// Number of active filters inside the "advanced" panel (type + time).
  int get activeAdvancedFiltersCount =>
      (typeFilter.value != AppointmentTypeFilter.all ? 1 : 0) +
      (timeFilter.value != AppointmentTimeFilter.all ? 1 : 0);

  bool get hasActiveFilters =>
      statusFilter.value != AppointmentStatusFilter.all ||
      activeAdvancedFiltersCount > 0 ||
      searchText.value.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Derived data
  // ---------------------------------------------------------------------------

  int countFor(AppointmentStatusFilter filter) =>
      bookings.where((b) => _matchesStatus(b, filter)).length;

  List<BookingModel> get filteredBookings {
    final query = searchText.value.toLowerCase().trim();

    final list = bookings.where((booking) {
      return (query.isEmpty || _matchesSearch(booking, query)) &&
          _matchesStatus(booking, statusFilter.value) &&
          _matchesType(booking, typeFilter.value) &&
          _matchesTime(booking, timeFilter.value);
    }).toList();

    // Upcoming first (soonest first), then past (most recent first).
    list.sort((a, b) {
      final aUp = isUpcoming(a);
      final bUp = isUpcoming(b);
      if (aUp != bUp) return aUp ? -1 : 1;
      final aDate = _dateOf(a);
      final bDate = _dateOf(b);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aUp ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
    });
    return list;
  }

  BookingModel? get nextAppointment {
    final upcoming = bookings.where(isUpcoming).toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) {
      final aDate = a.schedule.timestamp?.toDate();
      final bDate = b.schedule.timestamp?.toDate();
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });
    return upcoming.first;
  }

  DateTime? _dateOf(BookingModel b) =>
      b.schedule.timestamp?.toDate() ?? b.timeline.createdAt?.toDate();

  bool isUpcoming(BookingModel booking) {
    final status = booking.status.current.toLowerCase();
    if (closedStatuses.contains(status)) return false;

    final date = booking.schedule.timestamp?.toDate();
    if (date == null) return status == 'confirmed' || status == 'upcoming';

    // 1h grace so a booking that just started is still shown as upcoming.
    return date.isAfter(DateTime.now().subtract(const Duration(hours: 1)));
  }

  // ---------------------------------------------------------------------------
  // Matchers
  // ---------------------------------------------------------------------------

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
    final date = _dateOf(booking);
    if (date == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case AppointmentTimeFilter.all:
        return true;
      case AppointmentTimeFilter.thisWeek:
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return !date.isBefore(startOfWeek) && date.isBefore(endOfWeek);
      case AppointmentTimeFilter.thisMonth:
        return date.month == now.month && date.year == now.year;
      case AppointmentTimeFilter.last30Days:
        final from = today.subtract(const Duration(days: 30));
        final to = today.add(const Duration(days: 1));
        return !date.isBefore(from) && date.isBefore(to);
    }
  }
}

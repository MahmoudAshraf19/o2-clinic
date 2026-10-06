import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../services_firestore/models/booking_model.dart';
import '../../../services_firestore/services/bookings_firestore_service.dart';
import '../../../dashboard/controllers/dashboard_pending_actions_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/models/radiology_category_model.dart';
import '../../../booking/presentation/pages/radiology_confirm_booking_screen.dart';
import 'dart:ui';

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

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BookingsFirestoreService _service = BookingsFirestoreService();

  AppointmentStatusFilter _statusFilter = AppointmentStatusFilter.all;
  AppointmentTypeFilter _typeFilter = AppointmentTypeFilter.all;
  AppointmentTimeFilter _timeFilter = AppointmentTimeFilter.all;

  String _searchText = '';
  Stream<List<BookingModel>>? _bookingsStream;
  String? _showBookingId;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim();
      });
    });

    if (Get.arguments is Map) {
      _showBookingId = Get.arguments['showBookingId']?.toString();

      final filterArg = Get.arguments['filter']?.toString();
      if (filterArg == 'requiresAction') {
        _statusFilter = AppointmentStatusFilter.requiresAction;
        _showFilters =
            true; // Show filters so the user knows a filter is active
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _user;

    if (user != null && _bookingsStream == null) {
      _bookingsStream = _service.streamBookingsByUserId(user.uid);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      body: SafeArea(
        child: user == null
            ? _buildNotLoggedInView(context)
            : StreamBuilder<List<BookingModel>>(
                stream: _bookingsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorView(context, snapshot.error.toString());
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final allBookings = snapshot.data ?? [];
                  final filteredBookings = _applyFilters(allBookings);
                  final nextAppointment = _getNextUpcomingBooking(allBookings);

                  if (_showBookingId != null && allBookings.isNotEmpty) {
                    final bookingId = _showBookingId;
                    _showBookingId = null;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final booking = allBookings.firstWhereOrNull(
                        (b) => b.id == bookingId,
                      );
                      if (booking != null && mounted) {
                        _showBookingDetails(context, booking);
                      }
                    });
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      setState(() {
                        if (user != null) {
                          _bookingsStream = _service.streamBookingsByUserId(
                            user.uid,
                          );
                        }
                      });
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(context),
                                const SizedBox(height: 20),
                                _buildNextAppointmentCard(
                                  context,
                                  nextAppointment: nextAppointment,
                                ),
                                const SizedBox(height: 24),
                                _buildSearchBar(),
                                const SizedBox(height: 12),
                                _buildFilterToggle(),
                                if (_showFilters) ...[
                                  const SizedBox(height: 16),
                                  _buildAdvancedFilters(),
                                ],
                                const SizedBox(height: 24),
                                _buildSectionTitle(
                                  context,
                                  filteredBookings.length,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (filteredBookings.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 40,
                              ),
                              child: _buildEmptyState(),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ).copyWith(bottom: 40),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final booking = filteredBookings[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _AppointmentCard(
                                    booking: booking,
                                    onTap: () =>
                                        _showBookingDetails(context, booking),
                                  ),
                                );
                              }, childCount: filteredBookings.length),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.myAppointments,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: AppFonts.dancingScript,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppLocalizations.of(context)!.manageYourBookingsEasily,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextAppointmentCard(
    BuildContext context, {
    required BookingModel? nextAppointment,
  }) {
    if (nextAppointment == null) return const SizedBox.shrink();

    final date = nextAppointment.schedule.timestamp?.toDate();
    final title = _BookingHelper.title(context, nextAppointment);
    final subtitle = _BookingHelper.subtitle(context, nextAppointment);
    final whenText = date == null
        ? '${nextAppointment.schedule.date} • ${nextAppointment.schedule.time}'
        : '${MaterialLocalizations.of(context).formatMediumDate(date)} • '
              '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E877B), Color(0xFF0F5A51)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E877B).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _DoctorAvatar(
                        imageUrl: nextAppointment.doctor?.image,
                        fallbackIcon: Icons.calendar_month_rounded,
                        isHero: true,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.85),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          _daysLeftText(context, date),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            whenText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          text: AppLocalizations.of(context)!.viewDetails,
                          icon: Icons.visibility_rounded,
                          filled: true,
                          onTap: () =>
                              _showBookingDetails(context, nextAppointment),
                        ),
                      ),
                      if (nextAppointment.type == 'online') ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            text: AppLocalizations.of(
                              context,
                            )!.onlineConsultation,
                            icon: Icons.videocam_rounded,
                            filled: false,
                            onTap: () =>
                                _showBookingDetails(context, nextAppointment),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _daysLeftText(BuildContext context, DateTime? date) {
    if (date == null)
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'قريباً'
          : 'Soon';
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (diff == 0) return isAr ? 'اليوم' : 'Today';
    if (diff == 1) return isAr ? 'غداً' : 'Tomorrow';
    if (diff < 0) return isAr ? 'انتهى' : 'Passed';
    return isAr ? 'بعد $diff أيام' : 'In $diff days';
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchDoctorServiceClinic,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showFilters = !_showFilters),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list_rounded,
            size: 20,
            color: _showFilters ? AppColors.primary : Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'خيارات التصفية المتقدمة'
                : 'Advanced Filters',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _showFilters ? AppColors.primary : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            _showFilters
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: _showFilters ? AppColors.primary : Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'حالة الحجز' : 'Status',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppointmentStatusFilter.values.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChipWidget(
                    label: _statusLabel(context, f, isAr),
                    isSelected: _statusFilter == f,
                    onTap: () => setState(() => _statusFilter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isAr ? 'نوع الخدمة' : 'Type',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppointmentTypeFilter.values.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChipWidget(
                    label: _typeLabel(f, isAr),
                    isSelected: _typeFilter == f,
                    onTap: () => setState(() => _typeFilter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isAr ? 'الفترة الزمنية' : 'Time Period',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppointmentTimeFilter.values.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChipWidget(
                    label: _timeLabel(f, isAr),
                    isSelected: _timeFilter == f,
                    onTap: () => setState(() => _timeFilter = f),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context, AppointmentStatusFilter filter, bool isAr) {
    switch (filter) {
      case AppointmentStatusFilter.all:
        return isAr ? 'الكل' : 'All';
      case AppointmentStatusFilter.upcoming:
        return isAr ? 'قادم' : 'Upcoming';
      case AppointmentStatusFilter.pending:
        return isAr ? 'معلق' : 'Pending';
      case AppointmentStatusFilter.completed:
        return isAr ? 'مكتمل' : 'Completed';
      case AppointmentStatusFilter.cancelled:
        return isAr ? 'ملغي' : 'Cancelled';
      case AppointmentStatusFilter.requiresAction:
        return AppLocalizations.of(context)!.requiresActionFilter;
    }
  }

  String _typeLabel(AppointmentTypeFilter filter, bool isAr) {
    switch (filter) {
      case AppointmentTypeFilter.all:
        return isAr ? 'الكل' : 'All';
      case AppointmentTypeFilter.doctor:
        return isAr ? 'كشف عيادة' : 'Clinical';
      case AppointmentTypeFilter.online:
        return isAr ? 'استشارة عن بعد' : 'Online';
      case AppointmentTypeFilter.imaging:
        return isAr ? 'أشعة' : 'Imaging';
      case AppointmentTypeFilter.cosmetic:
        return isAr ? 'تجميل' : 'Cosmetic';
    }
  }

  String _timeLabel(AppointmentTimeFilter filter, bool isAr) {
    switch (filter) {
      case AppointmentTimeFilter.all:
        return isAr ? 'كل الوقت' : 'All Time';
      case AppointmentTimeFilter.thisWeek:
        return isAr ? 'هذا الأسبوع' : 'This Week';
      case AppointmentTimeFilter.thisMonth:
        return isAr ? 'هذا الشهر' : 'This Month';
      case AppointmentTimeFilter.last30Days:
        return isAr ? 'آخر 30 يوم' : 'Last 30 Days';
    }
  }

  Widget _buildSectionTitle(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.myAppointments,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  List<BookingModel> _applyFilters(List<BookingModel> bookings) {
    final query = _searchText.toLowerCase().trim();

    return bookings.where((booking) {
      final matchesSearch = query.isEmpty || _matchesSearch(booking, query);
      final matchesStatus = _matchesStatus(booking, _statusFilter);
      final matchesType = _matchesType(booking, _typeFilter);
      final matchesTime = _matchesTime(booking, _timeFilter);
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
        return _isUpcoming(booking);
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
    final date =
        booking.schedule.timestamp?.toDate() ??
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

  BookingModel? _getNextUpcomingBooking(List<BookingModel> bookings) {
    final upcomingBookings = bookings.where(_isUpcoming).toList();
    upcomingBookings.sort((a, b) {
      final aDate =
          a.schedule.timestamp?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate =
          b.schedule.timestamp?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });
    return upcomingBookings.isEmpty ? null : upcomingBookings.first;
  }

  bool _isUpcoming(BookingModel booking) {
    final status = booking.status.current.toLowerCase();
    if (status == 'completed' || status == 'cancelled') return false;
    final date = booking.schedule.timestamp?.toDate();
    if (date == null) return status == 'confirmed' || status == 'upcoming';
    return date.isAfter(DateTime.now().subtract(const Duration(hours: 1))) ||
        status == 'confirmed' ||
        status == 'upcoming';
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.noAppointmentsFound,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tryChangingTheFilterOr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.signInToContinue,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.pleaseLoginOrCreateAn,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.somethingWentWrong,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingDetailsSheet(booking: booking),
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const _AppointmentCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = booking.schedule.timestamp?.toDate();
    final status = booking.status.current.toLowerCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DoctorAvatar(
                  imageUrl: booking.doctor?.image,
                  fallbackIcon: Icons.local_hospital_rounded,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _BookingHelper.title(context, booking),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _BookingHelper.subtitle(context, booking),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  status: status,
                  isAr: Localizations.localeOf(context).languageCode == 'ar',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      date == null
                          ? '${booking.schedule.date} • ${booking.schedule.time}'
                          : '${MaterialLocalizations.of(context).formatMediumDate(date)} • ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isAr;

  const _StatusBadge({required this.status, required this.isAr});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    if (status == 'completed') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
      label = isAr ? 'مكتمل' : 'Completed';
    } else if (status == 'cancelled') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
      label = isAr ? 'ملغي' : 'Cancelled';
    } else if (status == 'pending' || status == 'pending_price') {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade700;
      label = isAr ? 'معلق' : 'Pending';
    } else {
      bg = AppColors.primary.withOpacity(0.1);
      fg = AppColors.primary;
      label = isAr ? 'قادم' : 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final bool isHero;

  const _DoctorAvatar({
    this.imageUrl,
    required this.fallbackIcon,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isHero ? 60 : 50;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isHero
            ? Colors.white.withOpacity(0.15)
            : AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl != null && imageUrl!.trim().isNotEmpty)
          ? CachedImageWidget(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                fallbackIcon,
                color: isHero ? Colors.white : AppColors.primary,
              ),
            )
          : Icon(
              fallbackIcon,
              color: isHero ? Colors.white : AppColors.primary,
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? Colors.white : Colors.white.withOpacity(0.15);
    final fg = filled ? AppColors.primary : Colors.white;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingDetailsSheet extends StatelessWidget {
  final BookingModel booking;
  const _BookingDetailsSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final date = booking.schedule.timestamp?.toDate();
    final now = DateTime.now();
    
    // Can cancel if status is not cancelled/completed/no_show
    final currentStatus = booking.status.current.toLowerCase();
    final bool canCancel = currentStatus != 'cancelled' &&
        currentStatus != 'completed' &&
        currentStatus != 'no_show';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _DoctorAvatar(
                imageUrl: booking.doctor?.image,
                fallbackIcon: Icons.medical_services_rounded,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _BookingHelper.title(context, booking),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _BookingHelper.subtitle(context, booking),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                status: booking.status.current.toLowerCase(),
                isAr: isAr,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(
            context,
            Icons.calendar_today_rounded,
            isAr ? 'التاريخ' : 'Date',
            date == null
                ? booking.schedule.date
                : MaterialLocalizations.of(context).formatMediumDate(date),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            Icons.access_time_rounded,
            isAr ? 'الوقت' : 'Time',
            date == null
                ? booking.schedule.time
                : MaterialLocalizations.of(
                    context,
                  ).formatTimeOfDay(TimeOfDay.fromDateTime(date)),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            Icons.location_on_rounded,
            isAr ? 'المكان' : 'Location',
            '${booking.location.clinic} - ${isAr ? 'طابق' : 'Floor'} ${booking.location.floor} - ${isAr ? 'غرفة' : 'Room'} ${booking.location.room}',
          ),
          const SizedBox(height: 32),
          if (booking.type == 'imaging' &&
              (booking.status.current == 'pending_price' ||
                  booking.status.current == 'pending')) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Get.dialog(
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    barrierDismissible: false,
                  );
                  try {
                    final catDoc = await FirebaseFirestore.instance
                        .collection('radiology')
                        .doc(booking.imaging!.categoryId)
                        .get();
                    Get.back(); // close loading
                    if (catDoc.exists) {
                      final service = RadiologyCategoryModel.fromMap(
                        catDoc.id,
                        catDoc.data()!,
                      );
                      Get.back(); // close bottom sheet
                      
                      Get.to(
                        () => RadiologyConfirmBookingScreen(
                          service: service,
                          selectedDate:
                              booking.schedule.timestamp?.toDate() ??
                              DateTime.now(),
                          selectedTime: booking.schedule.time,
                          controllerTag: service.id,
                          bookingId: booking.id,
                        ),
                      );
                    } else {
                      Get.snackbar('Error', 'Service not found');
                    }
                  } catch (e) {
                    Get.back(); // close loading
                    Get.snackbar('Error', 'Failed to load details');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.continueBookingOrChat,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isAr ? 'إغلاق' : 'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isAr ? 'إغلاق' : 'Close',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          if (canCancel) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  final confirm = await Get.dialog<bool>(
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        isAr ? 'إلغاء الحجز' : 'Cancel Booking',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        isAr 
                          ? 'هل أنت متأكد من إلغاء حجزك؟' 
                          : 'Are you sure you want to cancel your booking?',
                        style: const TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                          ),
                          child: Text(
                            isAr ? 'لا' : 'No',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isAr ? 'نعم' : 'Yes',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    Get.dialog(
                      const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                      barrierDismissible: false,
                    );
                    try {
                      final service = BookingsFirestoreService();
                      await service.cancelBooking(booking);
                      Get.back(); // close loading
                      Get.back(); // close sheet
                      Get.snackbar(
                        isAr ? 'تم الإلغاء' : 'Cancelled',
                        isAr ? 'تم إلغاء حجزك بنجاح.' : 'Your booking has been cancelled successfully.',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } catch (e) {
                      Get.back(); // close loading
                      Get.snackbar('Error', 'Failed to cancel booking');
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isAr ? 'إلغاء الحجز' : 'Cancel Booking',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingHelper {
  static String title(BuildContext context, BookingModel booking) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (booking.doctor != null)
      return isArabic ? booking.doctor!.nameAr : booking.doctor!.nameEn;
    if (booking.service != null)
      return isArabic
          ? booking.service!.serviceNameAr
          : booking.service!.serviceNameEn;
    if (booking.imaging != null)
      return isArabic ? booking.imaging!.nameAr : booking.imaging!.nameEn;
    if (booking.cosmetic != null && booking.cosmetic!.serviceName.isNotEmpty)
      return booking.cosmetic!.serviceName;
    return AppLocalizations.of(context)!.appointmentOnly;
  }

  static String subtitle(BuildContext context, BookingModel booking) {
    if (booking.doctor?.specialty.isNotEmpty == true)
      return booking.doctor!.specialty;
    if (booking.location.clinic.isNotEmpty) return booking.location.clinic;
    return typeFriendly(context, booking.type);
  }

  static String typeFriendly(BuildContext context, String type) {
    final t = type.toLowerCase();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (t.contains('doctor')) return isAr ? 'طبيب' : 'Doctor';
    if (t.contains('service')) return isAr ? 'خدمة' : 'Service';
    if (t.contains('imaging')) return isAr ? 'أشعة' : 'Imaging';
    if (t.contains('cosmetic')) return isAr ? 'تجميل' : 'Cosmetic';
    if (t == 'online') return isAr ? 'عن بعد' : 'Online';
    return isAr ? 'حجز' : 'Booking';
  }
}

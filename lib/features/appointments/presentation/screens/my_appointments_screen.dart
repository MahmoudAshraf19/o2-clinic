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

enum AppointmentFilter { all, upcoming, completed, cancelled }

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BookingsFirestoreService _service = BookingsFirestoreService();

  AppointmentFilter _selectedFilter = AppointmentFilter.all;
  String _searchText = '';
  Stream<List<BookingModel>>? _bookingsStream;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim();
      });
    });
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
      backgroundColor: const Color(0xFFF8FAFA),
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
                      child: CircularProgressIndicator(),
                    );
                  }

                  final allBookings = snapshot.data ?? [];
                  final filteredBookings = _applyFilters(allBookings);
                  final nextAppointment = _getNextUpcomingBooking(allBookings);

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        if (user != null) {
                          _bookingsStream = _service.streamBookingsByUserId(user.uid);
                        }
                      });
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 16),

                            _buildNextAppointmentCard(
                              context,
                              nextAppointment: nextAppointment,
                            ),
                            const SizedBox(height: 16),

                            _buildSearchBar(),
                            const SizedBox(height: 12),

                            _buildFilters(),
                            const SizedBox(height: 22),

                            _SectionTitle(
                              title: AppLocalizations.of(context)!.myAppointments,
                              subtitle: AppLocalizations.of(context)!.bookingFound(filteredBookings.length.toString()),
                            ),
                            const SizedBox(height: 12),

                            if (filteredBookings.isEmpty)
                              _buildEmptyState()
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredBookings.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final booking = filteredBookings[index];
                                  return _AppointmentCard(
                                    booking: booking,
                                    onTap: () => _showBookingDetails(context, booking),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.myAppointments,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFamily: AppFonts.dancingScript,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.manageYourBookingsEasily,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.75),
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
    if (nextAppointment == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF21897E), Color(0xFF3BA99C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF21897E).withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.noUpcomingAppointment,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.yourNextBookingWillAppear,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.92),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final date = nextAppointment.schedule.timestamp?.toDate();
    final title = _displayTitle(context, nextAppointment);
    final subtitle = _displaySubtitle(context, nextAppointment);
    final whenText = date == null
        ? '${nextAppointment.schedule.date} • ${nextAppointment.schedule.time}'
        : '${MaterialLocalizations.of(context).formatMediumDate(date)} • '
            '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF005049)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -15,
            bottom: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DoctorAvatar(
                    imageUrl: nextAppointment.doctor?.image,
                    fallbackIcon: Icons.calendar_month_rounded,
                    isHero: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _daysLeftText(context, date),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        whenText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      text: AppLocalizations.of(context)!.viewDetails,
                      icon: Icons.visibility_rounded,
                      filled: true,
                      onTap: () => _showBookingDetails(context, nextAppointment),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      text: AppLocalizations.of(context)!.directions,
                      icon: Icons.directions_rounded,
                      filled: false,
                      onTap: () => _showBookingDetails(context, nextAppointment),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.searchDoctorServiceClinic,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE6ECEC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AppointmentFilter.values.map((filter) {
          final selected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(_filterLabel(context, filter)),
              selected: selected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF546868),
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE6ECEC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6ECEC)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noAppointmentsFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2020),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tryChangingTheFilterOr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF546868),
            ),
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
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppLocalizations.of(context)!.signInToContinue,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.pleaseLoginOrCreateAn,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.toNamed(AppRoutes.login),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.somethingWentWrong,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF546868)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<BookingModel> _applyFilters(List<BookingModel> bookings) {
    final query = _searchText.toLowerCase().trim();

    return bookings.where((booking) {
      final matchesSearch = query.isEmpty || _matchesSearch(booking, query);
      final matchesFilter = _matchesFilter(booking, _selectedFilter);
      return matchesSearch && matchesFilter;
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
      booking.location.floor,
      booking.location.room,
      booking.status.current,
      booking.status.label,
      booking.payment.method,
    ].whereType<String>().join(' ').toLowerCase();

    return text.contains(query);
  }

  bool _matchesFilter(BookingModel booking, AppointmentFilter filter) {
    switch (filter) {
      case AppointmentFilter.all:
        return true;
      case AppointmentFilter.upcoming:
        return _isUpcoming(booking);
      case AppointmentFilter.completed:
        return booking.status.current.toLowerCase() == 'completed';
      case AppointmentFilter.cancelled:
        return booking.status.current.toLowerCase() == 'cancelled';
    }
  }

  BookingModel? _getNextUpcomingBooking(List<BookingModel> bookings) {
    final upcomingBookings = bookings.where(_isUpcoming).toList();

    upcomingBookings.sort((a, b) {
      final aDate = _bookingDate(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = _bookingDate(b) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });

    return upcomingBookings.isEmpty ? null : upcomingBookings.first;
  }

  bool _isUpcoming(BookingModel booking) {
    final status = booking.status.current.toLowerCase();
    if (status == 'completed' || status == 'cancelled') return false;

    final date = _bookingDate(booking);
    if (date == null) return status == 'confirmed' || status == 'pending';

    return date.isAfter(DateTime.now()) ||
        status == 'confirmed' ||
        status == 'pending';
  }

  DateTime? _bookingDate(BookingModel booking) {
    return booking.schedule.timestamp?.toDate() ??
        booking.timeline.createdAt?.toDate();
  }

  String _filterLabel(BuildContext context, AppointmentFilter filter) {
    switch (filter) {
      case AppointmentFilter.all:
        return AppLocalizations.of(context)!.allAppointments;
      case AppointmentFilter.upcoming:
        return AppLocalizations.of(context)!.upcoming;
      case AppointmentFilter.completed:
        return AppLocalizations.of(context)!.completed;
      case AppointmentFilter.cancelled:
        return AppLocalizations.of(context)!.cancelled;
    }
  }

  void _showBookingDetails(BuildContext context, BookingModel booking) {
    final date = booking.schedule.timestamp?.toDate() ??
        booking.timeline.createdAt?.toDate();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8FAFA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BottomSheetHeader(booking: booking),
                  const SizedBox(height: 20),
                  _DetailSection(
                    title: AppLocalizations.of(context)!.appointmentInfo,
                    items: [
                      _DetailRow(
                        label: AppLocalizations.of(context)!.type,
                        value: _bookingTypeLabel(context, booking),
                      ),
                      _DetailRow(
                        label: AppLocalizations.of(context)!.status,
                        value: booking.status.label.isNotEmpty
                            ? booking.status.label
                            : booking.status.current,
                      ),
                      _DetailRow(
                        label: AppLocalizations.of(context)!.date,
                        value: date == null
                            ? '-'
                            : MaterialLocalizations.of(context).formatMediumDate(date),
                      ),
                      _DetailRow(
                        label: AppLocalizations.of(context)!.time,
                        value: date == null
                            ? booking.schedule.time
                            : MaterialLocalizations.of(context).formatTimeOfDay(
                                TimeOfDay.fromDateTime(date),
                              ),
                      ),
                      _DetailRow(
                        label: AppLocalizations.of(context)!.duration,
                        value: '${booking.schedule.durationMinutes} min',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailSection(
                    title: AppLocalizations.of(context)!.patient,
                    items: [
                      _DetailRow(label: AppLocalizations.of(context)!.name, value: booking.user.name),
                      _DetailRow(label: AppLocalizations.of(context)!.phone, value: booking.user.phone.full),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailSection(
                    title: AppLocalizations.of(context)!.location,
                    items: [
                      _DetailRow(label: AppLocalizations.of(context)!.clinic, value: booking.location.clinic),
                      _DetailRow(label: AppLocalizations.of(context)!.floor, value: booking.location.floor),
                      _DetailRow(label: AppLocalizations.of(context)!.room, value: booking.location.room),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailSection(
                    title: AppLocalizations.of(context)!.payment,
                    items: [
                      _DetailRow(label: AppLocalizations.of(context)!.status, value: booking.payment.status),
                      _DetailRow(label: AppLocalizations.of(context)!.method, value: booking.payment.method),
                      _DetailRow(
                        label: AppLocalizations.of(context)!.amount,
                        value: '${booking.payment.amount} ${booking.payment.currency}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailSection(
                    title: AppLocalizations.of(context)!.meta,
                    items: [
                      _DetailRow(label: AppLocalizations.of(context)!.source, value: booking.meta.source),
                      _DetailRow(label: AppLocalizations.of(context)!.version, value: booking.meta.version),
                      _DetailRow(label: AppLocalizations.of(context)!.bookingId, value: booking.id),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(AppLocalizations.of(context)!.done),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _bookingTypeLabel(BuildContext context, BookingModel booking) {
    final type = booking.type.toLowerCase().trim();

    if (type.contains('doctor')) return AppLocalizations.of(context)!.doctorAppointment;
    if (type.contains('service')) return AppLocalizations.of(context)!.serviceAppointment;
    if (type.contains('imaging')) return AppLocalizations.of(context)!.imagingAppointment;
    if (type.contains('cosmetic')) return AppLocalizations.of(context)!.cosmeticAppointment;

    return booking.type.isEmpty ? AppLocalizations.of(context)!.appointmentOnly : booking.type;
  }

  String _displayTitle(BuildContext context, BookingModel booking) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final doctor = booking.doctor;
    if (doctor != null) {
      if (isArabic && doctor.nameAr.trim().isNotEmpty) return doctor.nameAr;
      if (!isArabic && doctor.nameEn.trim().isNotEmpty) return doctor.nameEn;
      return doctor.nameAr.trim().isNotEmpty ? doctor.nameAr : doctor.nameEn;
    }

    final service = booking.service;
    if (service != null) {
      if (isArabic && service.serviceNameAr.trim().isNotEmpty) return service.serviceNameAr;
      if (!isArabic && service.serviceNameEn.trim().isNotEmpty) return service.serviceNameEn;
      return service.serviceNameAr.trim().isNotEmpty ? service.serviceNameAr : service.serviceNameEn;
    }

    final imaging = booking.imaging;
    if (imaging != null) {
      if (isArabic && imaging.nameAr.trim().isNotEmpty) return imaging.nameAr;
      if (!isArabic && imaging.nameEn.trim().isNotEmpty) return imaging.nameEn;
      return imaging.nameAr.trim().isNotEmpty ? imaging.nameAr : imaging.nameEn;
    }

    final cosmetic = booking.cosmetic;
    if (cosmetic != null && cosmetic.serviceName.trim().isNotEmpty) {
      return cosmetic.serviceName;
    }

    return AppLocalizations.of(context)!.appointmentOnly;
  }

  String _displaySubtitle(BuildContext context, BookingModel booking) {
    if (booking.doctor?.specialty.trim().isNotEmpty == true) {
      return booking.doctor!.specialty;
    }

    if (booking.location.clinic.trim().isNotEmpty) {
      return booking.location.clinic;
    }

    return booking._typeFriendly(context);
  }

  String _daysLeftText(BuildContext context, DateTime? date) {
    if (date == null) return AppLocalizations.of(context)!.upcoming;

    final diff = date.difference(DateTime.now()).inDays;
    if (diff <= 0) return AppLocalizations.of(context)!.todayOnly;
    if (diff == 1) return AppLocalizations.of(context)!.inOneDay;
    return AppLocalizations.of(context)!.inDays(diff.toString());
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2020),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF546868),
          ),
        ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = booking.schedule.timestamp?.toDate();
    final isCompleted = booking.status.current.toLowerCase() == 'completed';
    final isCancelled = booking.status.current.toLowerCase() == 'cancelled';
    final isUpcoming = !isCompleted && !isCancelled;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF162525).withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F5), width: 1.5),
            ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DoctorAvatar(
                    imageUrl: booking.doctor?.image,
                    fallbackIcon: _typeIcon(booking.type),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title(context, booking),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A2020),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtitle(context, booking),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF546868),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    label: booking.status.label.isNotEmpty
                        ? booking.status.label
                        : booking.status.current,
                    isUpcoming: isUpcoming,
                    isCancelled: isCancelled,
                    isCompleted: isCompleted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        date == null
                            ? '${booking.schedule.date} • ${booking.schedule.time}'
                            : '${MaterialLocalizations.of(context).formatMediumDate(date)} • '
                                '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2020),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF8FA3A3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  static String _title(BuildContext context, BookingModel booking) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final doctor = booking.doctor;
    if (doctor != null) {
      if (isArabic && doctor.nameAr.trim().isNotEmpty) return doctor.nameAr;
      if (!isArabic && doctor.nameEn.trim().isNotEmpty) return doctor.nameEn;
      return doctor.nameAr.trim().isNotEmpty ? doctor.nameAr : doctor.nameEn;
    }

    final service = booking.service;
    if (service != null) {
      if (isArabic && service.serviceNameAr.trim().isNotEmpty) return service.serviceNameAr;
      if (!isArabic && service.serviceNameEn.trim().isNotEmpty) return service.serviceNameEn;
      return service.serviceNameAr.trim().isNotEmpty ? service.serviceNameAr : service.serviceNameEn;
    }

    final imaging = booking.imaging;
    if (imaging != null) {
      if (isArabic && imaging.nameAr.trim().isNotEmpty) return imaging.nameAr;
      if (!isArabic && imaging.nameEn.trim().isNotEmpty) return imaging.nameEn;
      return imaging.nameAr.trim().isNotEmpty ? imaging.nameAr : imaging.nameEn;
    }

    final cosmetic = booking.cosmetic;
    if (cosmetic != null && cosmetic.serviceName.trim().isNotEmpty) {
      return cosmetic.serviceName;
    }

    return AppLocalizations.of(context)!.appointmentOnly;
  }

  static String _subtitle(BuildContext context, BookingModel booking) {
    if (booking.doctor?.specialty.trim().isNotEmpty == true) {
      return booking.doctor!.specialty;
    }

    if (booking.location.clinic.trim().isNotEmpty) {
      return booking.location.clinic;
    }

    return booking._typeFriendly(context);
  }

  static IconData _typeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('doctor')) return Icons.medical_services_rounded;
    if (t.contains('imaging')) return Icons.scanner_rounded;
    if (t.contains('cosmetic')) return Icons.spa_rounded;
    return Icons.event_note_rounded;
  }
}

class _DoctorAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final bool isHero;

  const _DoctorAvatar({
    required this.imageUrl,
    required this.fallbackIcon,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isHero ? 56 : 56;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isHero ? 0.16 : 1),
        borderRadius: BorderRadius.circular(isHero ? 18 : 18),
        border: Border.all(
          color: isHero ? Colors.white.withOpacity(0.24) : const Color(0xFFE6ECEC),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl != null && imageUrl!.trim().isNotEmpty)
          ? CachedImageWidget(imageUrl: 
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Icon(
                  fallbackIcon,
                  color: isHero ? Colors.white : AppColors.primary,
                );
              },
            )
          : Icon(
              fallbackIcon,
              color: isHero ? Colors.white : AppColors.primary,
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isUpcoming;
  final bool isCancelled;
  final bool isCompleted;

  const _StatusBadge({
    required this.label,
    required this.isUpcoming,
    required this.isCancelled,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (isCancelled) {
      bg = const Color(0xFFE53E3E).withOpacity(0.12);
      fg = const Color(0xFFE53E3E);
    } else if (isCompleted) {
      bg = const Color(0xFF2D3737).withOpacity(0.10);
      fg = const Color(0xFF2D3737);
    } else if (isUpcoming) {
      bg = const Color(0xFF21897E).withOpacity(0.12);
      fg = const Color(0xFF21897E);
    } else {
      bg = const Color(0xFF7EBCE6).withOpacity(0.14);
      fg = const Color(0xFF21897E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
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
    final bg = filled ? Colors.white : Colors.white.withOpacity(0.14);
    final fg = filled ? const Color(0xFF21897E) : Colors.white;

    return SizedBox(
      height: 46,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
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

class _BottomSheetHeader extends StatelessWidget {
  final BookingModel booking;

  const _BottomSheetHeader({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DoctorAvatar(
          imageUrl: booking.doctor?.image,
          fallbackIcon: Icons.person_rounded,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.doctor?.nameAr.isNotEmpty == true
                    ? booking.doctor!.nameAr
                    : (booking.doctor?.nameEn.isNotEmpty == true
                        ? booking.doctor!.nameEn
                        : 'Booking Details'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2020),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                booking.doctor?.specialty ?? booking.location.clinic,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF546868),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailRow> items;

  const _DetailSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6ECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2020),
            ),
          ),
          const SizedBox(height: 14),
          ...items.expand((row) => [
                row,
                if (row != items.last) const SizedBox(height: 12),
              ]),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF546868),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2020),
            ),
          ),
        ),
      ],
    );
  }
}

extension on BookingModel {
  String _typeFriendly(BuildContext context) {
    final t = type.toLowerCase();
    if (t.contains('doctor')) return AppLocalizations.of(context)!.doctor;
    if (t.contains('service')) return AppLocalizations.of(context)!.service;
    if (t.contains('imaging')) return AppLocalizations.of(context)!.imaging;
    if (t.contains('cosmetic')) return AppLocalizations.of(context)!.cosmetic;
    return type.isEmpty ? AppLocalizations.of(context)!.appointmentOnly : type;
  }
}

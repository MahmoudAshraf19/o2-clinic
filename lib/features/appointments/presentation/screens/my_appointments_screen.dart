import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../../common/widgets/common_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../booking/data/models/fs_booking_model.dart';
import '../controllers/appointments_controller.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_skeleton.dart';
import '../widgets/appointments_filters_panel.dart';
import '../controllers/appointments_states.dart';
import '../widgets/booking_details_sheet.dart';
import '../widgets/booking_helper.dart';
import '../widgets/next_appointment_card.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  late final AppointmentsController _controller;
  Worker? _openWorker;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AppointmentsController());

    // Deep link support: opens the details sheet for `showBookingId`.
    _openWorker = ever<BookingModel?>(_controller.bookingToOpen, (booking) {
      if (booking == null) return;
      _controller.bookingToOpen.value = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) BookingDetailsSheet.show(context, booking);
      });
    });
  }

  @override
  void dispose() {
    _openWorker?.dispose();
    super.dispose();
  }

  void _openDetails(BookingModel booking) =>
      BookingDetailsSheet.show(context, booking);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _controller.user == null
            ? _StateLayout(child: const AppointmentsLoginRequired())
            : Obx(_buildContent),
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.error.value != null && _controller.bookings.isEmpty) {
      return _StateLayout(
        child: AppointmentsErrorState(onRetry: _controller.refreshBookings),
      );
    }

    if (_controller.isLoading.value) {
      return const _StateLayout(
        expandChild: true,
        child: AppointmentsLoadingView(),
      );
    }

    final filtered = _controller.filteredBookings;
    final next = _controller.nextAppointment;
    final hasFilters = _controller.hasActiveFilters;
    final items = _buildItems(filtered);

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: _controller.refreshBookings,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ScreenHeader(),
                  if (next != null && !hasFilters) ...[
                    const SizedBox(height: 20),
                    NextAppointmentCard(
                      booking: next,
                      onViewDetails: () => _openDetails(next),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildSearchRow(context),
                  AppointmentAdvancedFilters(controller: _controller),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AppointmentStatusChips(controller: _controller),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: _buildSectionTitle(context, filtered.length),
            ),
          ),
          if (items.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: AppointmentsEmptyState(
                  hasActiveFilters: hasFilters,
                  onClearFilters: _controller.clearFilters,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  if (item is _GroupHeader) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? 0 : 8,
                        bottom: 12,
                      ),
                      child: _GroupLabel(label: item.label(context)),
                    );
                  }
                  final booking = item as BookingModel;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppointmentCard(
                      key: ValueKey(booking.id),
                      booking: booking,
                      onTap: () => _openDetails(booking),
                    ),
                  );
                }, childCount: items.length),
              ),
            ),
        ],
      ),
    );
  }

  /// Flattens bookings into list items. When no status filter is applied the
  /// list is split into "Upcoming" and "Past" groups.
  List<Object> _buildItems(List<BookingModel> filtered) {
    if (_controller.statusFilter.value != AppointmentStatusFilter.all) {
      return List<Object>.from(filtered);
    }

    final upcoming = filtered.where(_controller.isUpcoming).toList();
    final past = filtered.where((b) => !_controller.isUpcoming(b)).toList();

    return <Object>[
      if (upcoming.isNotEmpty) ...[const _GroupHeader(isUpcoming: true), ...upcoming],
      if (past.isNotEmpty) ...[const _GroupHeader(isUpcoming: false), ...past],
    ];
  }

  Widget _buildSearchRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.white.withValues(alpha: 0.03) 
                      : AppColors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CommonTextField(
              controller: _controller.searchController,
              hint: AppLocalizations.of(context)!.searchDoctorServiceClinic,
              prefixIcon: Icons.search_rounded,
              type: CommonTextFieldType.search,
              showBorder: false,
              filled: false,
            ),
          ),
        ),
        const SizedBox(width: 12),
        AppointmentFilterButton(controller: _controller),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, int count) {
    final l10n = AppLocalizations.of(context)!;
    final status = _controller.statusFilter.value;
    final title = status == AppointmentStatusFilter.all
        ? l10n.allAppointmentsFilter
        : AppointmentFilterLabels.status(context, status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
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
}

// -----------------------------------------------------------------------------
// Private building blocks
// -----------------------------------------------------------------------------

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Semantics(
          button: true,
          label: MaterialLocalizations.of(context).backButtonTooltip,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.white.withValues(alpha: 0.04) 
                        : AppColors.black.withValues(alpha: 0.04),
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
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.myAppointments,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: AppFonts.dancingScript,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.manageYourBookingsEasily,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.white54 : AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Header + centered state (login required / error / loading).
class _StateLayout extends StatelessWidget {
  final Widget child;
  final bool expandChild;

  const _StateLayout({required this.child, this.expandChild = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: _ScreenHeader(),
        ),
        Expanded(
          child: expandChild
              ? child
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: child,
                ),
        ),
      ],
    );
  }
}

class _GroupHeader {
  final bool isUpcoming;
  const _GroupHeader({required this.isUpcoming});

  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isUpcoming) return l10n.upcomingAppointmentsFilter;
    return l10n.pastAppointmentsFilter;
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.4,
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.white54 
            : AppColors.grey600,
      ),
    );
  }
}

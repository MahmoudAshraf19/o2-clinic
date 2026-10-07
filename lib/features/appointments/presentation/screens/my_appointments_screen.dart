import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../../common/widgets/common_text_field.dart';
import '../../../../common/widgets/common_loading_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../booking/data/models/fs_booking_model.dart';
import '../controllers/appointments_controller.dart';
import '../widgets/appointment_card.dart';
import '../widgets/booking_details_sheet.dart';
import '../widgets/booking_helper.dart';
import '../widgets/doctor_avatar.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/action_button.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentsController());

    return Scaffold(
      backgroundColor: AppColors.colorFFF4F7F9,
      body: SafeArea(
        child: controller.user == null
            ? _buildNotLoggedInView(context)
            : Obx(() {
                if (controller.error.value != null) {
                  return _buildErrorView(controller.error.value!, controller);
                }
                if (controller.isLoading.value) {
                  return const Center(
                    child: CommonLoadingIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                final filteredBookings = controller.filteredBookings;
                final nextAppointment = controller.nextAppointment;

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.white,
                  onRefresh: controller.refreshBookings,
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
                                nextAppointment,
                                controller,
                              ),
                              const SizedBox(height: 24),
                              _buildSearchBar(controller, context),
                              const SizedBox(height: 12),
                              _buildFilterToggle(controller, context),
                              if (controller.showFilters.value) ...[
                                const SizedBox(height: 16),
                                _buildAdvancedFilters(controller, context),
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
                            child: _buildEmptyState(context),
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
                                child: AppointmentCard(
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
              }),
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
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
                  color: AppColors.grey600,
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
    BuildContext context,
    BookingModel? nextAppointment,
    AppointmentsController controller,
  ) {
    if (nextAppointment == null) return const SizedBox.shrink();

    final date = nextAppointment.schedule.timestamp?.toDate();
    final title = BookingHelper.title(context, nextAppointment);
    final subtitle = BookingHelper.subtitle(context, nextAppointment);
    final whenText = date == null
        ? '${nextAppointment.schedule.date} • ${nextAppointment.schedule.time}'
        : '${MaterialLocalizations.of(context).formatMediumDate(date)} • '
              '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.colorFF1E877B, AppColors.colorFF0F5A51],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorFF1E877B.withValues(alpha: 0.3),
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
                  color: AppColors.white.withValues(alpha: 0.05),
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
                  color: AppColors.white.withValues(alpha: 0.05),
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
                      DoctorAvatar(
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
                                color: AppColors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.white.withValues(alpha: 0.85),
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
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          _daysLeftText(context, date),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          size: 20,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            whenText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
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
                        child: ActionButton(
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
                          child: ActionButton(
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
    if (date == null) {
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'قريباً'
          : 'Soon';
    }

    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (diff == 0) return isAr ? 'اليوم' : 'Today';
    if (diff == 1) return isAr ? 'غداً' : 'Tomorrow';
    if (diff < 0) return isAr ? 'انتهى' : 'Passed';
    return isAr ? 'بعد $diff أيام' : 'In $diff days';
  }

  Widget _buildSearchBar(AppointmentsController controller, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CommonTextField(
        controller: controller.searchController,
        hint: AppLocalizations.of(context)!.searchDoctorServiceClinic,
        prefixIcon: Icons.search_rounded,
        type: CommonTextFieldType.search,
        showBorder: false,
        filled: false,
      ),
    );
  }

  Widget _buildFilterToggle(AppointmentsController controller, BuildContext context) {
    return GestureDetector(
      onTap: controller.toggleFilters,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list_rounded,
            size: 20,
            color: controller.showFilters.value ? AppColors.primary : AppColors.grey600,
          ),
          const SizedBox(width: 6),
          Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'خيارات التصفية المتقدمة'
                : 'Advanced Filters',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: controller.showFilters.value ? AppColors.primary : AppColors.grey600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            controller.showFilters.value
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: controller.showFilters.value ? AppColors.primary : AppColors.grey600,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters(AppointmentsController controller, BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
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
                  child: FilterChipWidget(
                    label: _statusLabel(context, f, isAr),
                    isSelected: controller.statusFilter.value == f,
                    onTap: () => controller.setStatusFilter(f),
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
                  child: FilterChipWidget(
                    label: _typeLabel(f, isAr),
                    isSelected: controller.typeFilter.value == f,
                    onTap: () => controller.setTypeFilter(f),
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
                  child: FilterChipWidget(
                    label: _timeLabel(f, isAr),
                    isSelected: controller.timeFilter.value == f,
                    onTap: () => controller.setTimeFilter(f),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(
    BuildContext context,
    AppointmentStatusFilter filter,
    bool isAr,
  ) {
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
            color: AppColors.black87,
          ),
        ),
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

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey200, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
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
              color: AppColors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tryChangingTheFilterOr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.grey600),
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
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 20,
              ),
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
                style: TextStyle(fontSize: 14, color: AppColors.grey600),
              ),
              const SizedBox(height: 24),
              CommonButton(
                onPressed: () => Get.toNamed(AppRoutes.login),
                text: 'Login',
                type: CommonButtonType.primary,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                height: 54,
                borderRadius: BorderRadius.circular(16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String error, AppointmentsController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.red,
          ),
          const SizedBox(height: 12),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey600),
          ),
          const SizedBox(height: 16),
          CommonButton(
            onPressed: controller.refreshBookings,
            text: 'Retry',
            type: CommonButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => BookingDetailsSheet(booking: booking),
    );
  }
}

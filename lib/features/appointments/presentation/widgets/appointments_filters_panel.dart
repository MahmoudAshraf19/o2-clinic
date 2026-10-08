import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import '../controllers/appointments_controller.dart';
import 'booking_helper.dart';
import 'filter_chip_widget.dart';

/// Single place for filter labels (shared by chips, panel and section title).
class AppointmentFilterLabels {
  AppointmentFilterLabels._();

  static String status(
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

  static String type(AppointmentTypeFilter filter, bool isAr) {
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

  static String time(AppointmentTimeFilter filter, bool isAr) {
    switch (filter) {
      case AppointmentTimeFilter.all:
        return isAr ? 'كل الوقت' : 'All time';
      case AppointmentTimeFilter.thisWeek:
        return isAr ? 'هذا الأسبوع' : 'This week';
      case AppointmentTimeFilter.thisMonth:
        return isAr ? 'هذا الشهر' : 'This month';
      case AppointmentTimeFilter.last30Days:
        return isAr ? 'آخر 30 يوم' : 'Last 30 days';
    }
  }
}

/// Always-visible, horizontally scrolling status chips with live counters.
class AppointmentStatusChips extends StatelessWidget {
  final AppointmentsController controller;
  const AppointmentStatusChips({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isAr = BookingHelper.isArabic(context);

    return SizedBox(
      height: 44,
      child: Obx(() {
        final selected = controller.statusFilter.value;
        // Counts are read here (inside Obx) so the chips rebuild on changes.
        final counts = {
          for (final f in AppointmentStatusFilter.values)
            f: controller.countFor(f),
        };
        final visible = AppointmentStatusFilter.values.where((f) {
          if (f != AppointmentStatusFilter.requiresAction) return true;
          return (counts[f] ?? 0) > 0 || selected == f;
        }).toList();

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: visible.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final f = visible[index];
            return Center(
              child: FilterChipWidget(
                label: AppointmentFilterLabels.status(context, f, isAr),
                isSelected: selected == f,
                count: f == AppointmentStatusFilter.all ? null : counts[f],
                icon: f == AppointmentStatusFilter.requiresAction
                    ? Icons.priority_high_rounded
                    : null,
                onTap: () => controller.setStatusFilter(f),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Collapsible panel with the secondary filters (type + time period).
class AppointmentAdvancedFilters extends StatelessWidget {
  final AppointmentsController controller;
  const AppointmentAdvancedFilters({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isAr = BookingHelper.isArabic(context);

    return Obx(() {
      final expanded = controller.showFilters.value;
      final selectedType = controller.typeFilter.value;
      final selectedTime = controller.timeFilter.value;
      final hasFilters = controller.hasActiveFilters;

      return AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: !expanded
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.scaffoldDark : AppColors.grey200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(isAr ? 'نوع الخدمة' : 'Service type'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppointmentTypeFilter.values.map((f) {
                          return FilterChipWidget(
                            label: AppointmentFilterLabels.type(f, isAr),
                            isSelected: selectedType == f,
                            onTap: () => controller.setTypeFilter(f),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      _sectionTitle(isAr ? 'الفترة الزمنية' : 'Time period'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppointmentTimeFilter.values.map((f) {
                          return FilterChipWidget(
                            label: AppointmentFilterLabels.time(f, isAr),
                            isSelected: selectedTime == f,
                            onTap: () => controller.setTimeFilter(f),
                          );
                        }).toList(),
                      ),
                      if (hasFilters) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton.icon(
                            onPressed: controller.clearFilters,
                            icon: const Icon(
                              Icons.filter_alt_off_rounded,
                              size: 18,
                            ),
                            label: Text(
                              isAr ? 'مسح الكل' : 'Clear all',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black87,
      ),
    ),
  );
}

/// Square button next to the search field that toggles the advanced panel.
class AppointmentFilterButton extends StatelessWidget {
  final AppointmentsController controller;
  const AppointmentFilterButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isAr = BookingHelper.isArabic(context);

    return Obx(() {
      final expanded = controller.showFilters.value;
      final activeCount = controller.activeAdvancedFiltersCount;

      return Semantics(
        button: true,
        label: isAr ? 'تصفية متقدمة' : 'Advanced filters',
        child: Material(
          color: expanded ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: controller.toggleFilters,
            child: SizedBox(
              width: 54,
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: expanded ? Theme.of(context).cardColor : AppColors.primary,
                  ),
                  if (activeCount > 0)
                    PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).cardColor, width: 1.5),
                        ),
                        child: Text(
                          '$activeCount',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';

import 'package:flutter/material.dart';
import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../chat_support/widgets/support_chat_widgets.dart';
import '../../../services/data/models/radiology_category_model.dart';
import '../controllers/radiology_booking_controller.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';
import 'radiology_confirm_booking_screen.dart'; // To be created

class RadiologyBookingPage extends StatelessWidget {
  final RadiologyCategoryModel service;

  const RadiologyBookingPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      RadiologyAppointmentBookingController(service),
      tag: service.id,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildHeader(context),
              const SizedBox(height: 8),
              if (FirebaseAuth.instance.currentUser == null) ...[
                const Spacer(),
                SupportAuthPrompt(),
                const Spacer(),
              ] else ...[
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _serviceCard(context),
                      const SizedBox(height: 24),
                      _daysSection(context, controller),
                      const SizedBox(height: 24),
                      _timeSection(context, controller),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                _bookButton(context, controller),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.booking,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontFamily: AppFonts.dancingScript,
                letterSpacing: 0.4,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.selectDateTime,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _serviceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: CachedImageWidget(
              imageUrl: service.image,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.asset(
                'assets/images/common/Doctor_avatar.jpg',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.getName('en'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.radiologyDepartment,
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayShort(int weekday, String langCode) {
    if (langCode == 'ar') {
      const days = ['إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'];
      return days[weekday - 1];
    } else if (langCode == 'he') {
      const days = ['ב׳', 'ג׳', 'ד׳', 'ה׳', 'ו׳', 'ש׳', 'א׳'];
      return days[weekday - 1];
    }
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  Widget _daysSection(
    BuildContext context,
    RadiologyAppointmentBookingController controller,
  ) {
    return Obx(() {
      final selected = controller.selectedDate.value;
      final dates = controller.availableDates;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.availableDays,
                style: TextStyle(
                  fontFamily: AppFonts.dancingScript,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (dates.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                AppLocalizations.of(context)!.noAvailableDates,
                style: TextStyle(color: AppColors.grey),
              ),
            )
          else
            SizedBox(
              height: 92,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (_, i) {
                  final date = dates[i];
                  final isSelected = selected == date;

                  return GestureDetector(
                    onTap: () => controller.selectDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 10),
                      width: 72,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayShort(
                              date.weekday,
                              Get.locale?.languageCode ?? 'en',
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.5,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }

  Widget _timeSection(
    BuildContext context,
    RadiologyAppointmentBookingController controller,
  ) {
    return Obx(() {
      if (controller.selectedDate.value == null) {
        return const SizedBox();
      }

      final times = controller.availableTimes;
      if (times.isEmpty) {
        return const Text("No available time slots.");
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.time,
                style: TextStyle(
                  fontFamily: AppFonts.dancingScript,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: times.map((t) {
              final isSelected = controller.selectedTime.value == t;
              return GestureDetector(
                onTap: () => controller.selectTime(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    t
                        .replaceAll('AM', AppLocalizations.of(context)!.am)
                        .replaceAll('PM', AppLocalizations.of(context)!.pm),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _bookButton(
    BuildContext context,
    RadiologyAppointmentBookingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CommonButton(
        onPressed: () async {
          final date = controller.selectedDate.value;
          if (date == null) {
            CommonSnackbar.showError(title: 'Selection Required', message: 'Please select a date first');
            return;
          }

          final time = controller.selectedTime.value;
          if (time.isEmpty) {
            CommonSnackbar.showError(title: 'Selection Required', message: 'Please select a time first');
            return;
          }

          Get.dialog(
            const Center(
              child: CommonLoadingIndicator(color: AppColors.primary),
            ),
            barrierDismissible: false,
          );

          final result = await controller.createPendingBooking();

          Get.back(); // close loading

          if (result.success && result.bookingId != null) {
            Get.to(
              () => RadiologyConfirmBookingScreen(
                service: controller.service,
                selectedDate: date,
                selectedTime: time,
                controllerTag: controller.service.id,
                bookingId: result.bookingId!,
              ),
            );
          } else {
            CommonSnackbar.showError(title: 'Error', message: result.message);
          }
        },
        text: AppLocalizations.of(context)!.bookAppointment,
        type: CommonButtonType.primary,
        backgroundColor: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        height: 55,
        elevation: 8,
        textStyle: TextStyle(fontWeight: FontWeight.w800, color: AppColors.white),
      ),
    );
  }
}

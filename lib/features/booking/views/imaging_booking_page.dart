import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../chat_support/widgets/support_chat_widgets.dart';
import '../controllers/imaging_booking_controller.dart';
import 'imaging_confirm_screen.dart';

class ImagingBookingPage extends StatelessWidget {
  final String title;
  final String? controllerTag;

  const ImagingBookingPage({
    super.key,
    required this.title,
    this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    final tag =
        controllerTag ?? DateTime.now().millisecondsSinceEpoch.toString();

    final controller = Get.put(ImagingBookingController(), tag: tag);
    controller.loadSchedule(title: title);

    final isAuth = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _stageHeader(context),
              const SizedBox(height: 20),
              if (!isAuth) ...[
                const Spacer(),
                const SupportAuthPrompt(),
                const Spacer(),
              ] else ...[
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _imagingCard(context),
                      const SizedBox(height: 26),
                      _daysSection(context, controller),
                      const SizedBox(height: 26),
                      Obx(() => _timeSection(context, controller)),
                    ],
                  ),
                ),
                _continueButton(context, controller, tag),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stageHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          AppLocalizations.of(context)!.selectDateTime,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.2,
            fontFamily: AppFonts.dancingScript,
          ),
        ),
        const Spacer(),
        const CircleAvatar(radius: 20, backgroundColor: Colors.transparent),
      ],
    );
  }

  Widget _imagingCard(BuildContext context) {
    final bool isCT = title == "CT Scan";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColors.primary.withValues(alpha: .1),
            ),
            child: Icon(
              isCT
                  ? Icons.monitor_heart_outlined
                  : Icons.medical_services_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.chooseYourPreferredDateAnd,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: .8),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _daysSection(
    BuildContext context,
    ImagingBookingController controller,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

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
          const SizedBox(height: 14),
          SizedBox(
            height: 92,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.days.length,
              itemBuilder: (_, i) {
                final day = controller.days[i];

                return Obx(() {
                  final isSelected = controller.selectedDay.value == day;

                  return GestureDetector(
                    onTap: () => controller.selectDay(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 10),
                      width: 74,
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
                                    alpha: .25,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat(
                              'E',
                              Get.locale?.languageCode ?? 'en',
                            ).format(day.date).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.4,
                              color: isSelected ? Colors.white : AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${day.date.day}",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _timeSection(
    BuildContext context,
    ImagingBookingController controller,
  ) {
    if (controller.selectedDay.value == null) {
      return const SizedBox();
    }

    final selectedSlot = controller.selectedSlot.value;
    final lang = Get.locale?.languageCode ?? 'en';

    String selectedTime = selectedSlot?.time ?? "";
    if (selectedTime.isNotEmpty) {
      selectedTime = selectedTime
          .replaceAll('AM', AppLocalizations.of(context)!.am)
          .replaceAll('PM', AppLocalizations.of(context)!.pm);
      final dateStr = DateFormat(
        'd MMM',
        lang,
      ).format(controller.selectedDay.value!.date);
      selectedTime = "$selectedTime - $dateStr";
    }

    const Color primary = Color(0xFF00685F);
    const Color secondary = Color(0xFF006A61);
    const Color secondaryFixed = Color(0xFF6FD8CA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.timeSlots,
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
        Obx(
          () => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.slots.map((slot) {
              final isSelected = controller.selectedSlot.value == slot;

              return GestureDetector(
                onTap: () => controller.selectSlot(slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: .25),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    slot.time,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (selectedSlot != null) ...[
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final fade = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              );
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(fade);

              return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: Builder(
              builder: (context) {
                final screenH = MediaQuery.sizeOf(context).height;
                final minH = (screenH * 0.14).clamp(120.0, 160.0);

                return Container(
                  key: ValueKey(selectedTime),
                  constraints: BoxConstraints(minHeight: minH),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [primary, secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: .2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 20,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                selectedTime,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .2),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: secondaryFixed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppLocalizations.of(context)!.available,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.yourImagingAppointmentHasBeen,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: .82),

                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _continueButton(
    BuildContext context,
    ImagingBookingController controller,
    String tag,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          if (controller.selectedDay.value == null) {
            Get.snackbar(
              AppLocalizations.of(context)!.error,
              AppLocalizations.of(context)!.pleaseSelectDateFirst,
              snackPosition: SnackPosition.TOP,
            );
            return;
          }

          if (controller.selectedSlot.value == null) {
            Get.snackbar(
              AppLocalizations.of(context)!.error,
              AppLocalizations.of(context)!.pleaseSelectTimeFirst,
              snackPosition: SnackPosition.TOP,
            );
            return;
          }

          final args = Get.arguments as Map<String, dynamic>? ?? {};
          final totalPrice = args['totalPrice'] ?? 0.0;

          Get.to(
            () => ImagingConfirmScreen(
              imagingType: title,
              selectedDate: controller.selectedDay.value!.date,
              selectedTime: controller.selectedSlot.value!.time,
              controllerTag: tag,
              totalPrice: totalPrice,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 55),
          elevation: 8,
        ),
        child: Text(
          AppLocalizations.of(context)!.continueBooking,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}



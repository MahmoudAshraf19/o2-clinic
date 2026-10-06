import 'dart:ui';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../services_firestore/models/doctor_model.dart';
import '../../controllers/booking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../chat_support/widgets/support_chat_widgets.dart';
import 'confirm_booking_screen.dart';

class BookingPage extends StatelessWidget {
  final DoctorModel doctor;

  const BookingPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AppointmentBookingController(doctor),
      tag: doctor.id,
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
                    children: [
                      _doctorCard(context),
                      const SizedBox(height: 24),
                      _daysSection(context, controller),
                      const SizedBox(height: 32),
                      _timeSection(context, controller),
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
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.transparent : AppColors.surface),
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

  Widget _doctorAvatar() {
    final fallback = Image.asset(
      'assets/images/common/Doctor_avatar.jpg',
      fit: BoxFit.cover,
      width: 56,
      height: 56,
    );

    if (doctor.image.trim().isEmpty) {
      return ClipOval(child: fallback);
    }

    return ClipOval(
      child: CachedImageWidget(
        imageUrl: doctor.image,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }

  Widget _doctorCard(BuildContext context) {
    final lang = Get.locale?.languageCode ?? 'en';
    String doctorName = doctor.nameEn;
    if (lang == 'ar' && doctor.nameAr.isNotEmpty) doctorName = doctor.nameAr;
    if (lang == 'he' && doctor.nameHe.isNotEmpty) doctorName = doctor.nameHe;

    String doctorTitle = doctor.titleEn;
    if (lang == 'ar' && doctor.titleAr.isNotEmpty) doctorTitle = doctor.titleAr;
    if (lang == 'he' && doctor.titleHe.isNotEmpty) doctorTitle = doctor.titleHe;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _doctorAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary),),
                ),
                const SizedBox(height: 4),
                Text(
                  doctorTitle,
                  style: const TextStyle(color: AppColors.grey, fontSize: 13),
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
    AppointmentBookingController controller,
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
          const SizedBox(height: 8),
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
                AppLocalizations.of(context)!.noAvailableDatesForThis,
                style: TextStyle(color: AppColors.grey),
              ),
            )
          else
            SizedBox(
              height: 92,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
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
                            : (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : AppColors.cardBackground),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat(
                              'E',
                              Get.locale?.languageCode ?? 'en',
                            ).format(date).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.5,
                              color: isSelected ? Colors.white : AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary),
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
    AppointmentBookingController controller,
  ) {
    return Obx(() {
      if (controller.selectedDate.value == null) {
        return const SizedBox();
      }

      final booked = controller.bookedCount;
      final max = controller.maxBookings;
      final percent = max == 0 ? 0.0 : booked / max;

      final String selectedTimeStr = controller.selectedTime.value ?? "";
      final lang = Get.locale?.languageCode ?? 'en';
      String translatedTime = selectedTimeStr;
      if (lang == 'ar') {
        translatedTime = translatedTime
            .replaceAll('AM', 'ص')
            .replaceAll('PM', 'م');
      } else if (lang == 'he') {
        translatedTime = translatedTime
            .replaceAll('AM', 'לפנה״צ')
            .replaceAll('PM', 'אחה״צ');
      }

      String displayDate = '';
      if (controller.selectedDate.value != null) {
        displayDate = DateFormat(
          'd MMM yyyy',
          lang,
        ).format(controller.selectedDate.value!);
      }

      final bool isAvailable = max > 0 ? booked < max : true;
      final String percentText = "${(percent * 100).round()}%";

      const Color primary = AppColors.brandBlue;
      const Color secondary = AppColors.brandBlue;
      const Color secondaryFixed = AppColors.vibrantCyan;

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
          const SizedBox(height: 8),
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
            child: GestureDetector(
              onTap: () {},
              child: Builder(
                builder: (context) {
                  final screenH = MediaQuery.sizeOf(context).height;
                  final minH = (screenH * 0.14).clamp(120.0, 160.0);

                  return Container(
                    key: ValueKey("$selectedTimeStr-$booked-$max"),
                    constraints: BoxConstraints(minHeight: minH),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [primary, secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    size: 20,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          translatedTime,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (displayDate.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            displayDate,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white.withValues(
                                                alpha: 0.7,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isAvailable
                                              ? secondaryFixed
                                              : Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isAvailable
                                            ? AppLocalizations.of(
                                                context,
                                              )!.available
                                            : AppLocalizations.of(
                                                context,
                                              )!.full,
                                        style: const TextStyle(
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
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.capacityStatus,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              percentText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth * percent;

                              return Stack(
                                children: [
                                  Container(
                                    height: 6,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  Container(
                                    height: 6,
                                    width: width,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _bookButton(
    BuildContext context,
    AppointmentBookingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          try {
            final date = controller.selectedDate.value;
            if (date == null) {
              Get.snackbar(
                AppLocalizations.of(context)!.selectionRequired,
                AppLocalizations.of(context)!.pleaseSelectDateFirst,
                snackPosition: SnackPosition.TOP,
              );
              return;
            }

            final time = controller.selectedTime.value ?? '';
            if (time.isEmpty) {
              Get.snackbar(
                AppLocalizations.of(context)!.selectionRequired,
                AppLocalizations.of(context)!.pleaseSelectTimeFirst,
                snackPosition: SnackPosition.TOP,
              );
              return;
            }

            final isAvailable = controller.maxBookings > 0
                ? controller.bookedCount < controller.maxBookings
                : true;

            if (!isAvailable) {
              Get.snackbar(
                AppLocalizations.of(context)!.slotFull,
                AppLocalizations.of(
                  context,
                )!.thisSlotHasReachedItsMaximumCapacity,
                snackPosition: SnackPosition.TOP,
              );
              return;
            }

            Get.to(
              () => ConfirmBookingScreen(
                doctor: controller.doctor,
                selectedDate: date,
                selectedTime: time,
                controllerTag: controller.doctor.id,
              ),
            );
          } catch (e, st) {
            debugPrint("❌ [BookingPage] Error: $e");
            debugPrint("❌ [BookingPage] StackTrace: $st");
            Get.snackbar(
              AppLocalizations.of(context)!.error,
              AppLocalizations.of(context)!.anUnexpectedErrorOccurred,
              snackPosition: SnackPosition.TOP,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 55),
          elevation: 0,
        ),
        child: Text(
          AppLocalizations.of(context)!.bookAppointment,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}






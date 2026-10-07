import 'package:flutter/material.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'confirm_booking_screen.dart';
import '../../controllers/booking.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../services_firestore/models/doctor_model.dart';

class OnlineConsultationBookingPage extends StatefulWidget {
  final DoctorModel doctor;

  const OnlineConsultationBookingPage({super.key, required this.doctor});

  @override
  State<OnlineConsultationBookingPage> createState() =>
      _OnlineConsultationBookingPageState();
}

class _OnlineConsultationBookingPageState
    extends State<OnlineConsultationBookingPage> {
  DateTime? selectedDate;
  String? selectedTime;
  List<DateTime> availableDates = [];

  @override
  void initState() {
    super.initState();
    _calculateAvailableDates();
  }

  void _calculateAvailableDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final allowedDays = widget.doctor.availabilityDayOnline.keys
        .map((d) => d.toLowerCase())
        .toList();

    for (int i = 0; i < 30; i++) {
      final date = today.add(Duration(days: i));
      final dayName = DateFormat('EEEE').format(date).toLowerCase();
      if (allowedDays.contains(dayName)) {
        availableDates.add(date);
      }
    }
  }

  List<String> _getAvailableTimeSlots(DateTime date) {
    final dayName = DateFormat('EEEE').format(date).toLowerCase();
    final daySchedules = widget.doctor.availabilityDayOnline[dayName];

    if (daySchedules == null || daySchedules.isEmpty) return [];

    List<String> slots = [];

    for (var daySchedule in daySchedules) {
      final fromStr = daySchedule['from'];
      final toStr = daySchedule['to'];

      if (fromStr == null || toStr == null) continue;

      int? from = int.tryParse(fromStr);
      int? to = int.tryParse(toStr);

      if (from == null || to == null) continue;
      if (to <= from) continue;

      for (int i = from; i < to; i++) {
        final now = DateTime.now();
        final endHour24 = i + 1;

        // Filter out past slots if the selected date is today
        if (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day) {
          // Skip if the slot has already ended (end time is in the past)
          // If current time is 16:25 (4:25 PM), endHour for 3-4 is 16. 16 <= 16 (true), and 25 > 0, so it skips.
          // For 4-5, endHour is 17. 17 <= 16 is false, so it shows.
          if (endHour24 < now.hour ||
              (endHour24 == now.hour && now.minute > 0)) {
            continue;
          }
        }

        final startHour = i > 12 ? i - 12 : (i == 0 ? 12 : i);
        final endHour = endHour24 > 12
            ? endHour24 - 12
            : (endHour24 == 0 ? 12 : endHour24);

        final startAmPm = i >= 12 ? 'PM' : 'AM';
        final endAmPm = endHour24 >= 12 && endHour24 < 24 ? 'PM' : 'AM';

        slots.add("$startHour:00 $startAmPm - $endHour:00 $endAmPm");
      }
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppLocalizations.of(context)!.onlineConsultation,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDoctorCard(),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildWarningMessage(),
                    const SizedBox(height: 24),
                    _buildDaysSection(),
                    const SizedBox(height: 24),
                    if (selectedDate != null) _buildTimeSection(),
                  ],
                ),
              ),
              _buildBookButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard() {
    final lang = Get.locale?.languageCode ?? 'en';
    String doctorName = widget.doctor.nameEn;
    if (lang == 'ar' && widget.doctor.nameAr.isNotEmpty) {
      doctorName = widget.doctor.nameAr;
    }
    if (lang == 'he' && widget.doctor.nameHe.isNotEmpty) {
      doctorName = widget.doctor.nameHe;
    }

    String doctorTitle = widget.doctor.titleEn;
    if (lang == 'ar' && widget.doctor.titleAr.isNotEmpty) {
      doctorTitle = widget.doctor.titleAr;
    }
    if (lang == 'he' && widget.doctor.titleHe.isNotEmpty) {
      doctorTitle = widget.doctor.titleHe;
    }

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
            child: widget.doctor.image.isNotEmpty
                ? CachedImageWidget(
                    imageUrl: widget.doctor.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/common/Doctor_avatar.jpg',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
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

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.amber,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.mustContactDoctorWarning,
              style: const TextStyle(
                color: AppColors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.availableDays,
          style: const TextStyle(
            fontFamily: AppFonts.dancingScript,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (availableDates.isEmpty)
          const Text("No online schedules available")
        else
          SizedBox(
            height: 92,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableDates.length,
              itemBuilder: (_, i) {
                final date = availableDates[i];
                final isSelected = selectedDate == date;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                      selectedTime = null; // Reset time when date changes
                    });
                  },
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
  }

  Widget _buildTimeSection() {
    final slots = _getAvailableTimeSlots(selectedDate!);

    if (slots.isEmpty) {
      return const Text("No available time slots");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.time,
          style: const TextStyle(
            fontFamily: AppFonts.dancingScript,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((slot) {
            final isSelected = selectedTime == slot;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTime = slot;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: CommonButton(
        text: AppLocalizations.of(context)!.bookAppointment,
        onPressed: (selectedDate != null && selectedTime != null)
            ? _processBooking
            : null,
        type: CommonButtonType.primary,
        backgroundColor: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        height: 55,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Future<void> _processBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Please login first');
      return;
    }

    // Initialize controller for the next screen
    final tag = 'online_${widget.doctor.id}';
    if (!Get.isRegistered<AppointmentBookingController>(tag: tag)) {
      Get.put(AppointmentBookingController(widget.doctor), tag: tag);
    }

    Get.to(
      () => ConfirmBookingScreen(
        doctor: widget.doctor,
        selectedDate: selectedDate!,
        selectedTime: selectedTime!,
        controllerTag: tag,
        isOnline: true,
      ),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 350),
    );
  }
}

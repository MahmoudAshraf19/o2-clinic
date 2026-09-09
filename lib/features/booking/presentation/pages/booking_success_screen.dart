import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../services_firestore/models/doctor_model.dart';

class BookingSuccessScreen extends StatelessWidget {
  final DoctorModel doctor;
  final DateTime selectedDate;
  final String selectedTime;
  final String bookingId;
  final bool isOnline;

  const BookingSuccessScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
    required this.bookingId,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [_card(context), const SizedBox(height: 18), _actions(context)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    final lang = Get.locale?.languageCode ?? 'en';
    String doctorName = doctor.nameEn;
    if (lang == 'ar' && doctor.nameAr.isNotEmpty) doctorName = doctor.nameAr;
    if (lang == 'he' && doctor.nameHe.isNotEmpty) doctorName = doctor.nameHe;

    String doctorTitle = doctor.titleEn;
    if (lang == 'ar' && doctor.titleAr.isNotEmpty) doctorTitle = doctor.titleAr;
    if (lang == 'he' && doctor.titleHe.isNotEmpty) doctorTitle = doctor.titleHe;

    String translatedTime = selectedTime;
    if (lang == 'ar') {
      translatedTime = translatedTime.replaceAll('AM', 'ص').replaceAll('PM', 'م');
    } else if (lang == 'he') {
      translatedTime = translatedTime.replaceAll('AM', 'לפנה״צ').replaceAll('PM', 'אחה״צ');
    }
    String displayTime = translatedTime;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isOnline ? Icons.access_time_filled : Icons.check_circle, 
            size: 70, 
            color: isOnline ? Colors.orange.shade700 : Colors.teal
          ),
          const SizedBox(height: 16),
          Text(
            isOnline ? AppLocalizations.of(context)!.pending : AppLocalizations.of(context)!.bookingConfirmed,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isOnline ? Colors.orange.shade800 : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isOnline ? AppLocalizations.of(context)!.mustContactDoctorWarning : AppLocalizations.of(context)!.yourAppointmentHasBeenScheduled,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 18),
          _info(AppLocalizations.of(context)!.doctor, doctorName),
          _info(AppLocalizations.of(context)!.specialty, doctorTitle),
          _info(AppLocalizations.of(context)!.date, _formatDate(selectedDate, context)),
          _info(AppLocalizations.of(context)!.time, displayTime),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isOnline ? Colors.orange.shade700 : Colors.teal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.bookingId,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  bookingId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String t, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t, style: TextStyle(color: AppColors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Get.offAllNamed('/main-navigation'),
          child: Text(AppLocalizations.of(context)!.backToHome),
        ),
      ],
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    return DateFormat('d MMM yyyy', Get.locale?.languageCode ?? 'en').format(date);
  }

  String _formatSpecialty(String specialty) {
    if (specialty.isEmpty) return specialty;
    if (specialty == 'general_bariatric_surgery') {
      return 'General & Bariatric Surgery';
    }
    
    // Fallback formatter: replace underscores with spaces and capitalize
    return specialty.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      if (word == 'and') return '&';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}


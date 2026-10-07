import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';

class ImagingSuccessScreen extends StatelessWidget {
  final String imagingType;
  final DateTime selectedDate;
  final String selectedTime;
  final String bookingId;

  const ImagingSuccessScreen({
    super.key,
    required this.imagingType,
    required this.selectedDate,
    required this.selectedTime,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    try {} catch (e) {
      /* ignore */
    }

    return Scaffold(
      backgroundColor: AppColors.colorFFF6FAF8,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _card(context),
                const SizedBox(height: 18),
                _actions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 70, color: AppColors.brandBlue),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.imagingConfirmed,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.yourImagingAppointmentHasBeen,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey600),
          ),
          const SizedBox(height: 18),
          _info(AppLocalizations.of(context)!.type, imagingType),
          _info(
            AppLocalizations.of(context)!.date,
            _formatDate(selectedDate, context),
          ),
          _info(AppLocalizations.of(context)!.time, selectedTime),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brandBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.bookingId,
                  style: TextStyle(color: AppColors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  bookingId,
                  style: const TextStyle(
                    color: AppColors.white,
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
          Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Get.offAllNamed('/main-navigation'),
          child: Text(AppLocalizations.of(context)!.home),
        ),
      ],
    );
  }

  String _formatDate(DateTime d, BuildContext context) {
    final lang = Get.locale?.languageCode ?? 'en';
    final formatter = DateFormat('d MMM', lang);
    return formatter.format(d);
  }
}

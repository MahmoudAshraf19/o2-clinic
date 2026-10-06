import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class UltrasoundSuccessScreen extends StatelessWidget {
  final String bookingId;
  final String time;
  final DateTime date;
  final dynamic model;

  const UltrasoundSuccessScreen({
    super.key,
    required this.bookingId,
    required this.time,
    required this.date,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Get.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _card(context, lang),
                const SizedBox(height: 18),
                _actions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, String lang) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 70, color: const Color(0xFF03458F)),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.imagingConfirmed,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.yourImagingAppointmentHasBeen,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 18),
          _info(
            AppLocalizations.of(context)!.type,
            model.titleForLanguage(lang),
          ),
          _info(AppLocalizations.of(context)!.date, _formatDate(date, lang)),
          _info(
            AppLocalizations.of(context)!.time,
            time
                .replaceAll('AM', AppLocalizations.of(context)!.am)
                .replaceAll('PM', AppLocalizations.of(context)!.pm),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF03458F),
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

  String _formatDate(DateTime d, String lang) {
    final formatter = DateFormat('d MMM', lang);
    return formatter.format(d);
  }
}

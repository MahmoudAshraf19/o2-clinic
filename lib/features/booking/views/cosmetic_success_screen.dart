import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../services/models/cosmetic_category_model.dart';

class CosmeticSuccessScreen extends StatelessWidget {
  final CosmeticCategoryModel model;
  final DateTime selectedDate;
  final String selectedTime;
  final String bookingId;

  const CosmeticSuccessScreen({
    super.key,
    required this.model,
    required this.selectedDate,
    required this.selectedTime,
    required this.bookingId,
  });

  String _t(String text) {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'ar') {
      switch (text) {
        case "Cosmetic Confirmed!":
          return "تم تأكيد الحجز التجميلي!";
        case "Booking Confirmed!":
          return "تم تأكيد الحجز!";
        case "Your cosmetic appointment has been scheduled successfully.":
          return "تم تحديد موعدك التجميلي بنجاح.";
        case "Your appointment has been scheduled successfully.":
          return "تم تحديد موعدك بنجاح.";
        case "Type":
          return "النوع";
        case "Date":
          return "التاريخ";
        case "Time":
          return "الوقت";
        case "BOOKING ID":
          return "رقم الحجز";
        case "Back to Home":
          return "العودة للرئيسية";
      }
    } else if (lang == 'he') {
      switch (text) {
        case "Cosmetic Confirmed!":
          return "הזמנה קוסמטית אושרה!";
        case "Booking Confirmed!":
          return "ההזמנה אושרה!";
        case "Your cosmetic appointment has been scheduled successfully.":
          return "התור הקוסמטי שלך נקבע בהצלחה.";
        case "Your appointment has been scheduled successfully.":
          return "התור שלך נקבע בהצלחה.";
        case "Type":
          return "סוג";
        case "Date":
          return "תאריך";
        case "Time":
          return "זמן";
        case "BOOKING ID":
          return "מספר הזמנה";
        case "Back to Home":
          return "חזרה לבית";
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    try {
} catch (e) {
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
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
    final langCode = Get.locale?.languageCode ?? 'en';
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
          const Icon(Icons.check_circle, size: 70, color: const Color(0xFF03458F)),
          const SizedBox(height: 16),
          Text(
            (model.id == 'Sleep_study' || model.id == 'pulmonary_function')
                ? _t("Booking Confirmed!")
                : _t("Cosmetic Confirmed!"),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            (model.id == 'Sleep_study' || model.id == 'pulmonary_function')
                ? _t("Your appointment has been scheduled successfully.")
                : _t(
                    "Your cosmetic appointment has been scheduled successfully.",
                  ),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 18),
          _info(_t("Type"), model.getName(langCode)),
          _info(_t("Date"), _formatDate(selectedDate)),
          _info(
            _t("Time"),
            selectedTime
                .replaceAll('AM', _getAm(langCode))
                .replaceAll('PM', _getPm(langCode)),
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
                  _t("BOOKING ID"),
                  style: const TextStyle(color: Colors.white70),
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
          child: Text(_t("Back to Home")),
        ),
      ],
    );
  }

  String _getAm(String lang) {
    if (lang == 'ar') return 'ص';
    if (lang == 'he') return 'לפנה"צ';
    return 'AM';
  }

  String _getPm(String lang) {
    if (lang == 'ar') return 'م';
    if (lang == 'he') return 'אחה"צ';
    return 'PM';
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
